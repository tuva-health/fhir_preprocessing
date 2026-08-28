#!/usr/bin/env python3

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RELEASE_WORKFLOW = ROOT / ".github" / "workflows" / "create-release.yml"


class PackageContractTest(unittest.TestCase):
    def test_project_declares_one_semantic_version_and_the_supported_dbt_range(self):
        project_text = (ROOT / "dbt_project.yml").read_text()

        project_version = re.search(
            r"(?m)^version: '([1-9][0-9]*\.[0-9]+\.[0-9]+"
            r"(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?)'$",
            project_text,
        )

        self.assertIsNotNone(project_version)
        self.assertIn('require-dbt-version: ">=1.10.5,<3.0.0"', project_text)
        self.assertEqual(re.findall(r"(?m)^version:", project_text), ["version:"])

    def test_release_workflow_runs_package_contract(self):
        workflow_text = RELEASE_WORKFLOW.read_text()
        checkout_position = workflow_text.index("uses: actions/checkout@")
        contract_position = workflow_text.index(
            "run: python3 scripts/test_package_contract.py"
        )
        version_check_position = workflow_text.index("- name: Check version change")

        self.assertLess(checkout_position, contract_position)
        self.assertLess(contract_position, version_check_position)

    def test_release_workflow_finds_exactly_one_package_version(self):
        workflow_text = RELEASE_WORKFLOW.read_text()
        project_text = (ROOT / "dbt_project.yml").read_text()

        pattern_source = re.search(
            r'VERSION_LINE_PATTERN = re\.compile\(\s*'
            r'r"((?:[^"\\]|\\.)*)",\s*re\.MULTILINE,\s*\)',
            workflow_text,
        )
        self.assertIsNotNone(pattern_source)

        version_line_pattern = re.compile(pattern_source.group(1), re.MULTILINE)
        matches = version_line_pattern.findall(project_text)
        project_version = re.search(r"(?m)^version: '([^']+)'$", project_text)

        self.assertEqual(len(matches), 1)
        self.assertEqual(matches[0][1], project_version.group(1))

    def test_release_workflow_is_the_no_receipt_variant(self):
        workflow_text = RELEASE_WORKFLOW.read_text()

        # This package ships no data assets, so there is no release receipt to
        # verify. Keep the two facts locked together: a catalog appearing later
        # has to bring the receipt gate with it.
        self.assertFalse((ROOT / "data_assets.yml").exists())
        self.assertNotIn("data_assets.yml", workflow_text)
        self.assertNotIn("PACKAGE_SLUG", workflow_text)
        self.assertNotIn("receipt", workflow_text.lower())

    def test_release_workflow_tags_only_current_main_with_pinned_actions(self):
        workflow_text = RELEASE_WORKFLOW.read_text()

        self.assertIn('[[ "${GITHUB_REF}" != "refs/heads/main" ]]', workflow_text)
        self.assertIn('if [[ "${GITHUB_SHA}" != "${main_commit}" ]]', workflow_text)
        current_main_position = workflow_text.index(
            "- name: Require release commit to be current main"
        )
        tag_position = workflow_text.index("- name: Create tag")
        self.assertLess(current_main_position, tag_position)

        action_refs = re.findall(r"uses:\s+[^@\s]+@([^\s]+)", workflow_text)
        self.assertTrue(action_refs)
        for action_ref in action_refs:
            self.assertRegex(action_ref, r"^[0-9a-f]{40}$")


if __name__ == "__main__":
    unittest.main()
