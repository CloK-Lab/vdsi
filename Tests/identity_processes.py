"""Exercise the real Lean identity executable across separate processes.

Secret test files exist only inside a temporary directory and are never logged.
Python performs assertions and filesystem fault injection, not identity logic.
"""

from concurrent.futures import ThreadPoolExecutor
import os
from pathlib import Path
import shutil
import stat
import subprocess
import tempfile


EXECUTABLE = Path(__file__).resolve().parents[1] / ".lake/build/bin/identity-demo"


def run(*args, success=True):
    result = subprocess.run(
        [str(EXECUTABLE), *map(str, args)], capture_output=True, text=True,
        timeout=20, umask=0,
    )
    assert (result.returncode == 0) == success, "Unexpected identity process status"
    if success:
        assert "Real signature verification: PASS" in result.stdout
        assert "still one identity" in result.stdout
    else:
        assert "Public identity:" not in result.stdout
    return result


def identity(result):
    lines = [s for s in result.stdout.splitlines() if s.startswith("Public identity: ")]
    assert len(lines) == 1
    key = lines[0].split(": ", 1)[1]
    assert len(key) == 64 and all(c in "0123456789abcdef" for c in key)
    return key


def main():
    with tempfile.TemporaryDirectory(prefix="vdsi-identity-") as tmp:
        root = Path(tmp)
        alice = root / "alice"
        created = run("init", alice)
        key = identity(created)
        seedfile = alice / "identity.seed"
        saved = seedfile.read_bytes()
        assert saved.startswith(b"vdsi.identity.seed.v1\n")
        assert len(saved) == len(b"vdsi.identity.seed.v1\n") + 64
        assert saved[-32:].hex() == key
        secret_hex = saved[-64:-32].hex()
        assert secret_hex not in created.stdout + created.stderr
        assert stat.S_IMODE(alice.stat().st_mode) == 0o700
        assert stat.S_IMODE(seedfile.stat().st_mode) == 0o600
        assert not (alice / "identity.pending").exists()

        # New OS processes recover the original identity, without modifying it.
        for _ in range(2):
            resumed = run("resume", alice)
            assert identity(resumed) == key
            assert secret_hex not in resumed.stdout + resumed.stderr
            assert seedfile.read_bytes() == saved
        run("init", alice, success=False)
        assert seedfile.read_bytes() == saved

        # Copying private state copies authority; it does not create a new identity.
        clone = root / "clone"
        shutil.copytree(alice, clone)
        assert identity(run("resume", clone)) == key
        assert identity(run("init", root / "bob")) != key

        missing = root / "missing"
        run("resume", missing, success=False)
        assert not missing.exists()
        empty = root / "empty"
        empty.mkdir()
        run("resume", empty, success=False)
        run("init", empty, success=False)
        assert list(empty.iterdir()) == []

        # Simulate an interrupted initialization before its final rename.
        unfinished = root / "unfinished"
        unfinished.mkdir(mode=0o700)
        (unfinished / "identity.pending").write_bytes(saved)
        run("resume", unfinished, success=False)
        run("init", unfinished, success=False)
        assert not (unfinished / "identity.seed").exists()

        bad = root / "bad"
        bad.mkdir(mode=0o700)
        badfile = bad / "identity.seed"
        variants = [
            b"", saved[:-1], saved + b"\x00", b"X" + saved[1:],
            saved[:-64] + bytes([saved[-64] ^ 1]) + saved[-63:],
            saved[:-1] + bytes([saved[-1] ^ 1]),
            saved + b"\x00" * 100_000,
        ]
        for damaged in variants:
            badfile.write_bytes(damaged)
            run("resume", bad, success=False)
            assert badfile.read_bytes() == damaged

        # Do not follow a substituted final file or directory, or a hard link.
        linkdir = root / "linked-directory"
        linkdir.symlink_to(alice, target_is_directory=True)
        run("resume", linkdir, success=False)
        run("init", linkdir, success=False)
        linked = root / "linked-file"
        linked.mkdir()
        (linked / "identity.seed").symlink_to(seedfile)
        run("resume", linked, success=False)
        hardlinked = root / "hardlinked"
        hardlinked.mkdir()
        os.link(seedfile, hardlinked / "identity.seed")
        run("resume", hardlinked, success=False)
        wrongtype = root / "wrongtype"
        (wrongtype / "identity.seed").mkdir(parents=True)
        run("resume", wrongtype, success=False)

        # Competing initializations must not replace one another's identity.
        race = root / "race"
        def initialize():
            return subprocess.run(
                [str(EXECUTABLE), "init", str(race)], capture_output=True,
                text=True, timeout=20,
            )
        with ThreadPoolExecutor(max_workers=2) as pool:
            results = list(pool.map(lambda _: initialize(), range(2)))
        winners = [r for r in results if r.returncode == 0]
        assert len(winners) == 1
        assert identity(run("resume", race)) == identity(winners[0])

        run("init", root / "no-parent" / "identity", success=False)
        run("invalid-command", success=False)

    print("[PASS] Identity persistence: process restart, copied identity, exclusive creation, corruption, and file permissions")


if __name__ == "__main__":
    main()
