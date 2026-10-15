"""Exchange public snapshots between two independent registries using Lean CLI."""
import copy
import json
from pathlib import Path
import tempfile

from identity_processes import run as create_identity, identity
from identity_registry_processes import run


def main():
    with tempfile.TemporaryDirectory(prefix="vdsi-identity-exchange-") as tmp:
        root = Path(tmp)
        alice, bob, a, b, export_a, export_b = [root / n for n in
            ("alice", "bob", "a", "b", "export-a", "export-b")]
        ka = identity(create_identity("init", alice))
        kb = identity(create_identity("init", bob))
        for keydir, registry in [(alice, a), (bob, b)]:
            run("registry-init", registry)
            run("registry-register", keydir, registry)
        # Exchange needs neither private seed, nor a currently running sender.
        alice.rename(root / "offline-alice")
        bob.rename(root / "offline-bob")
        run("registry-export", a, export_a)
        run("registry-export", b, export_b)
        for exported in (export_a, export_b):
            assert sorted(p.name for p in exported.iterdir()) == ["registry.json"]
        fa, fb = export_a / "registry.json", export_b / "registry.json"
        original_a = (a / "registry.json").read_bytes()
        original_b = (b / "registry.json").read_bytes()
        assert fa.read_bytes() == original_a and fb.read_bytes() == original_b
        run("registry-export", a, export_a, success=False)
        assert fa.read_bytes() == original_a

        # A valid new record followed by a forged known-key record rejects all.
        bad = root / "bad.json"
        document = json.loads(original_b)
        forged = copy.deepcopy(json.loads(original_a)["records"][0])
        forged["signature"][0] ^= 1
        document["records"].append(forged)
        bad.write_text(json.dumps(document))
        run("registry-import", a, bad, success=False)
        assert (a / "registry.json").read_bytes() == original_a
        document = json.loads(original_b)
        document["records"].append(copy.deepcopy(document["records"][0]))
        bad.write_text(json.dumps(document))
        run("registry-import", a, bad, success=False)
        document = json.loads(original_b)
        document["network"] = "network-B"
        bad.write_text(json.dumps(document))
        run("registry-import", a, bad, success=False)
        for payload in (b"{", b" " * 65537):
            bad.write_bytes(payload)
            run("registry-import", a, bad, success=False)
        run("registry-import", a, root / "missing.json", success=False)
        assert (a / "registry.json").read_bytes() == original_a

        pending = a / "registry.pending"
        pending.mkdir()
        run("registry-import", a, fb, success=False)
        assert (a / "registry.json").read_bytes() == original_a
        pending.rmdir()

        assert "2 identities" in run("registry-import", a, fb)
        assert "2 identities" in run("registry-import", b, fa)
        for registry, source, first_key in ((a, fb, ka), (b, fa, kb)):
            state = registry / "registry.json"
            before = state.read_bytes()
            before_stat = state.stat()
            assert "2 identities" in run("registry-import", registry, source)
            assert state.read_bytes() == before
            assert state.stat().st_mtime_ns == before_stat.st_mtime_ns
            assert state.stat().st_ino == before_stat.st_ino
            shown = run("registry-show", registry)
            assert ka in shown and kb in shown
            records = json.loads(before)["records"]
            assert bytes(records[0]["publicKey"]).hex() == first_key
            assert {bytes(r["publicKey"]).hex() for r in records} == {ka, kb}
        assert fa.read_bytes() == original_a and fb.read_bytes() == original_b
    print("[PASS] Identity exchange: public export, independent verification, atomic rejection, replay, key-set agreement, restart")


if __name__ == "__main__":
    main()
