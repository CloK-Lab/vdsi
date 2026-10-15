"""Real-process registry recovery and write-failure tests; temporary data only."""

import copy
import json
from pathlib import Path
import subprocess
import tempfile

from identity_processes import EXECUTABLE, identity, run as identity_run


def run(*args, success=True):
    result = subprocess.run([str(EXECUTABLE), *map(str, args)],
                            capture_output=True, text=True, timeout=20)
    assert (result.returncode == 0) == success, "Unexpected registry process status"
    if not success:
        assert "Import confirmed" not in result.stdout
        assert "Export saved" not in result.stdout
        assert "confirmed on disk" not in result.stdout
        assert "restored and verified" not in result.stdout
        assert "created and saved" not in result.stdout
    return result.stdout


def main():
    with tempfile.TemporaryDirectory(prefix="vdsi-identity-registry-") as tmp:
        root = Path(tmp)
        alice, bob, registry = (root / n for n in ("alice", "bob", "registry"))
        alice_key = identity(identity_run("init", alice))
        bob_key = identity(identity_run("init", bob))
        run("registry-init", registry)
        path = registry / "registry.json"
        assert "0 identities" in run("registry-show", registry)
        assert "1 identities" in run("registry-register", alice, registry)
        saved = path.read_bytes()
        before_stat = path.stat()
        assert alice_key in run("registry-show", registry)
        assert "1 identities" in run("registry-register", alice, registry)
        assert path.read_bytes() == saved
        assert path.stat().st_mtime_ns == before_stat.st_mtime_ns
        assert path.stat().st_ino == before_stat.st_ino
        run("registry-init", registry, success=False)
        assert path.read_bytes() == saved

        # A blocked temporary file prevents acknowledgement and preserves Alice.
        pending = registry / "registry.pending"
        pending.mkdir()
        run("registry-register", bob, registry, success=False)
        assert path.read_bytes() == saved
        assert bob_key not in run("registry-show", registry)
        pending.rmdir()

        # Stale unfinished data is ignored on recovery; a later save replaces it.
        pending.write_bytes(b"interrupted write")
        assert alice_key in run("registry-show", registry)
        assert "2 identities" in run("registry-register", bob, registry)
        restored = run("registry-show", registry)
        assert alice_key in restored and bob_key in restored
        assert not pending.exists()

        original = json.loads(saved)
        variants = []
        def changed(action):
            document = copy.deepcopy(original)
            action(document)
            variants.append(json.dumps(document).encode())
        changed(lambda d: d.update(version=2))
        changed(lambda d: d.update(network="network-B"))
        changed(lambda d: d["records"].append(copy.deepcopy(d["records"][0])))
        changed(lambda d: d["records"][0].update(domain="other"))
        changed(lambda d: d["records"][0].update(version=257))
        changed(lambda d: d["records"][0].update(network="network-B"))
        changed(lambda d: d["records"][0]["signature"].__setitem__(0, d["records"][0]["signature"][0] ^ 1))
        changed(lambda d: d["records"][0]["signature"].pop())
        changed(lambda d: d["records"][0]["publicKey"].__setitem__(0, 256))
        changed(lambda d: d["records"][0]["publicKey"].__setitem__(0, -1))
        variants.extend([b"", b"{", saved + b"garbage", b"\xff", b" " * 65537])
        bad = root / "bad"
        run("registry-init", bad)
        badfile = bad / "registry.json"
        for damaged in variants:
            badfile.write_bytes(damaged)
            run("registry-show", bad, success=False)
            run("registry-register", alice, bad, success=False)
            assert badfile.read_bytes() == damaged

        badfile.unlink()
        run("registry-show", bad, success=False)
        run("registry-register", alice, bad, success=False)
        assert not badfile.exists()
        missing = root / "missing"
        run("registry-show", missing, success=False)
        assert not missing.exists()
        badfile.symlink_to(path)
        run("registry-show", bad, success=False)

        # Failure at final rename also returns no success; incomplete temp data
        # is never interpreted as a committed registry on the next invocation.
        blocked = root / "blocked"
        blocked.mkdir()
        (blocked / "registry.json").mkdir()
        # Direct save failure is exercised in the Lean IO test; init deliberately
        # refuses this already existing directory rather than repairing it.
        run("registry-init", blocked, success=False)
        run("registry-show", blocked, success=False)

    print("[PASS] Identity registry: restart, replay, two identities, corruption, size limits, and failed saves")


if __name__ == "__main__":
    main()
