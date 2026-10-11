"""Exercise the compiled Lean nodes over real loopback TCP; no Python node logic."""

import json
from pathlib import Path
import queue
import socket
import subprocess
import tempfile
import threading
import time


EXECUTABLE = Path(__file__).resolve().parents[1] / ".lake/build/bin/node"


class NodeProcess:
    def __init__(self, node_id, port=0, peers=(), *, directory):
        self.lines = queue.Queue()
        self.errors = []
        self.process = subprocess.Popen(
            [str(EXECUTABLE), str(node_id), str(port), *map(str, peers)],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            text=True, bufsize=1, cwd=directory,
        )
        threading.Thread(target=self.read_stdout, daemon=True).start()
        threading.Thread(target=self.read_stderr, daemon=True).start()
        try:
            ready = self.read()
            assert ready["node"] == node_id, ready
            self.port = ready["ready"]
        except BaseException:
            self.close()
            raise

    def read_stdout(self):
        for line in self.process.stdout:
            self.lines.put(line)
        self.lines.put(None)

    def read_stderr(self):
        self.errors.extend(self.process.stderr)

    def read(self):
        try:
            line = self.lines.get(timeout=5)
        except queue.Empty:
            raise AssertionError(f"Node did not respond: {self.errors}") from None
        if line is None:
            raise AssertionError(f"Node exited unexpectedly: {self.errors}")
        return json.loads(line)

    def command(self, text):
        self.process.stdin.write(text + "\n")
        self.process.stdin.flush()
        return self.read()

    def close(self):
        try:
            if self.process.poll() is None:
                self.process.stdin.write("quit\n")
                self.process.stdin.flush()
                self.process.wait(timeout=5)
            assert self.process.returncode == 0, self.errors
        finally:
            if self.process.poll() is None:
                self.process.kill()
                self.process.wait()
            for stream in (self.process.stdin, self.process.stdout, self.process.stderr):
                stream.close()


def await_ids(nodes, expected):
    deadline = time.monotonic() + 8
    while time.monotonic() < deadline:
        states = [node.command("show")["participants"] for node in nodes]
        for ids in states:
            assert len(ids) == len(set(ids)), f"Duplicate IDs: {ids}"
        if all(set(ids) == expected for ids in states):
            return
        time.sleep(0.1)
    raise AssertionError(f"Nodes did not converge to {expected}: {states}")


def send_snapshot(port, fragments):
    with socket.create_connection(("127.0.0.1", port), timeout=4) as client:
        for fragment in fragments:
            client.sendall(fragment)
            time.sleep(0.02)
        client.shutdown(socket.SHUT_WR)
        result = bytearray()
        while chunk := client.recv(4096):
            result.extend(chunk)
        return bytes(result)


def run_network(directory):
    nodes = []
    try:
        # Reserve B's port until A is listening. A initially sees an offline peer;
        # once B starts, both processes initiate exchanges independently.
        with socket.socket() as reservation:
            reservation.bind(("127.0.0.1", 0))
            b_port = reservation.getsockname()[1]
            a = NodeProcess(1, peers=[b_port], directory=directory)
        nodes.append(a)
        b = NodeProcess(2, port=b_port, peers=[a.port], directory=directory)
        nodes.append(b)
        a.command("register 1")
        b.command("register 2")
        await_ids(nodes, {1, 2})
        a.command("register 7")
        b.command("register 7")
        await_ids(nodes, {1, 2, 7})

        response = json.loads(send_snapshot(a.port, [b"[3,", b"3,4]"]))
        assert set(response) == {1, 2, 3, 4, 7}, response
        await_ids(nodes, {1, 2, 3, 4, 7})
        for malformed in (b"[99,", b"[99,-1]", b"\xff"):
            assert send_snapshot(a.port, [malformed]) == b""
        await_ids(nodes, {1, 2, 3, 4, 7})

        # A restores its snapshot after restarting, then catches up with the
        # registration made on B while A was offline.
        port = a.port
        a.close()
        nodes.remove(a)
        b.command("register 8")
        time.sleep(0.8)
        a = NodeProcess(1, port=port, peers=[b.port], directory=directory)
        nodes.append(a)
        await_ids(nodes, {1, 2, 3, 4, 7, 8})
        print("[PASS] Node processes: exchange, duplicates, framing, rejection, peer restart")
    finally:
        failures = []
        for node in nodes:
            try:
                node.close()
            except Exception as error:
                failures.append(error)
        if failures:
            raise AssertionError(f"Nodes failed to stop: {failures}")


def run_persistence(directory):
    # All peers have stopped. Restore each node independently, without peers.
    data = directory / ".vdsi"
    assert sorted(path.name for path in data.iterdir()) == ["node-1.json", "node-2.json"]
    for node_id in (1, 2):
        node = NodeProcess(node_id, directory=directory)
        try:
            ids = node.command("show")["participants"]
            assert len(ids) == 6 and set(ids) == {1, 2, 3, 4, 7, 8}, ids
            path = data / f"node-{node_id}.json"
            saved = path.stat().st_mtime_ns
            node.command("register 1")
            assert path.stat().st_mtime_ns == saved, "Duplicate registration rewrote the snapshot"
        finally:
            node.close()

    # Invalid snapshots must fail before the node reports readiness and retain
    # the original bytes. In particular, duplicate IDs must not be silently fixed.
    invalid = data / "node-99.json"
    for content in ("", "[99,", "[1,1]", "[-1]"):
        invalid.write_text(content)
        result = subprocess.run(
            [str(EXECUTABLE), "99", "0"], input="", capture_output=True,
            text=True, cwd=directory, timeout=5,
        )
        assert result.returncode != 0 and "Invalid snapshot" in result.stderr, result
        assert not result.stdout, result.stdout
        assert invalid.read_text() == content

    # Force a write failure with a directory at the temporary filename. The
    # command must fail without replacing the previously saved snapshot.
    invalid.write_text("[42]\n")
    invalid.with_suffix(".json.tmp").mkdir()
    result = subprocess.run(
        [str(EXECUTABLE), "99", "0"], input="register 43\nshow\n",
        capture_output=True, text=True, cwd=directory, timeout=5,
    )
    assert result.returncode != 0 and "Could not save snapshot" in result.stderr, result
    assert invalid.read_text() == "[42]\n"
    assert all("participants" not in json.loads(line) for line in result.stdout.splitlines())
    print("[PASS] Persistence: independent restart, bounded files, corruption and write failure")


if __name__ == "__main__":
    # Never read or modify the developer's .vdsi snapshots.
    with tempfile.TemporaryDirectory(prefix="vdsi-nodes-") as temporary:
        directory = Path(temporary)
        run_network(directory)
        run_persistence(directory)
