import importlib.util
from pathlib import Path
import unittest


SCRIPT = Path(__file__).with_name("update-formula.py")
SPEC = importlib.util.spec_from_file_location("update_formula", SCRIPT)
UPDATE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(UPDATE)


class UpdateFormulaTest(unittest.TestCase):
    def test_parses_strict_checksums(self):
        digest = "a" * 64
        self.assertEqual(
            UPDATE.parse_checksums(f"{digest}  archive.tar.gz\n".encode()),
            {"archive.tar.gz": digest},
        )
        with self.assertRaisesRegex(ValueError, "invalid SHA256SUMS"):
            UPDATE.parse_checksums(f"{digest} archive.tar.gz\n".encode())

    def test_rejects_duplicate_checksums(self):
        line = f"{'a' * 64}  archive.tar.gz\n"
        with self.assertRaisesRegex(ValueError, "duplicate"):
            UPDATE.parse_checksums((line + line).encode())

    def test_renders_all_platforms(self):
        checksums = {
            f"zelport_1.2.3_{goos}_{goarch}.tar.gz": str(index) * 64
            for index, (goos, _, goarch, _) in enumerate(
                UPDATE.PLATFORMS, start=1
            )
        }
        formula = UPDATE.render_formula(
            'version "@VERSION@"\n@DOWNLOADS@\n', "1.2.3", checksums
        )
        self.assertIn('version "1.2.3"', formula)
        self.assertEqual(formula.count("https://github.com/"), 4)
        self.assertIn("on_macos do", formula)
        self.assertIn("on_linux do", formula)

    def test_rejects_non_stable_versions(self):
        for version in ("v1.2.3", "1.2", "1.2.3-rc.1", "01.2.3"):
            with self.subTest(version=version):
                with self.assertRaises(ValueError):
                    UPDATE.version_tuple(version)

    def test_normalizes_canonical_release_identifier(self):
        self.assertEqual(UPDATE.release_version("v1.2.3"), "1.2.3")
        for version in ("1.2.3", "v1.2", "v1.2.3-rc.1", "v01.2.3"):
            with self.subTest(version=version):
                with self.assertRaises(ValueError):
                    UPDATE.release_version(version)


if __name__ == "__main__":
    unittest.main()
