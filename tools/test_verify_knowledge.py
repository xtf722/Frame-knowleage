"""Check explicit source-snapshot selection without using the real project."""
import contextlib
import hashlib
import io
import json
import tempfile
import unittest
from pathlib import Path

from verify_knowledge import check


class SnapshotSelectionTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        base = Path(self.temporary.name)
        self.root = base / "knowledge"
        self.source = base / "source"
        self.root.mkdir()
        self.source.mkdir()
        for folder in ("modules", "foundations", "evidence"):
            (self.root / folder).mkdir()
        for name in ("README.md", "AGENTS.md", "learning-map.md", "lifecycle-map.md"):
            (self.root / name).write_text("# Fixture\n", encoding="utf-8")
        (self.source / "example.dart").write_bytes(b"current source\n")
        self.old = self.manifest(b"historical source\n")
        self.new = self.manifest(b"current source\n")
        self.write_manifest("sources.json", self.old)
        self.write_manifest("blog-sources.json", self.new)

    def manifest(self, content):
        return {
            "schema_version": 1,
            "repositories": {
                name: {"head": "1" * 40, "working_tree_dirty": False}
                for name in ("frame_app", "workspace")
            },
            "sources": [{
                "id": "source-0123456789",
                "path": "example.dart",
                "sha256": hashlib.sha256(content).hexdigest(),
                "used_by": ["README.md"],
                "source_fragments": [],
            }],
        }

    def write_manifest(self, name, content):
        (self.root / "evidence" / name).write_text(json.dumps(content), encoding="utf-8")

    def run_check(self, **kwargs):
        with contextlib.redirect_stdout(io.StringIO()):
            return check(self.root, **kwargs)

    def test_default_retains_historical_drift(self):
        original = (self.root / "evidence/sources.json").read_bytes()
        self.assertEqual(self.run_check(source_root=self.source), 2)
        self.assertEqual((self.root / "evidence/sources.json").read_bytes(), original)

    def test_explicit_snapshot_checks_its_own_hashes(self):
        self.assertEqual(self.run_check(source_root=self.source, manifest="evidence/blog-sources.json"), 0)
        self.new["sources"][0]["sha256"] = "0" * 64
        self.write_manifest("blog-sources.json", self.new)
        self.assertEqual(self.run_check(source_root=self.source, manifest="evidence/blog-sources.json"), 2)

    def test_offline_structure_does_not_require_source_checkout(self):
        self.assertEqual(self.run_check(), 0)
        self.assertEqual(self.run_check(manifest="evidence/blog-sources.json"), 0)

    def test_outside_or_missing_manifest_is_not_a_pass(self):
        self.assertEqual(self.run_check(manifest="../outside.json"), 1)
        self.assertEqual(self.run_check(manifest="evidence/missing.json"), 1)


if __name__ == "__main__":
    unittest.main()
