#!/usr/bin/env python3
"""Unit tests for Jira/Dynatrace key parsing. No live tokens."""
from __future__ import annotations

import base64
import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("wire_jira_dynatrace", ROOT / "wire-jira-dynatrace.py")
mod = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(mod)


class TestParseAndBasic(unittest.TestCase):
    def test_parse_key_file(self):
        jira, dt = mod.parse_key_file(
            "jira ATATT3xFfEXAMPLETOKENVALUEHERE0123456789==\n"
            "dynatrace dt0c01.ABCDEFGHIJKLMNOPQRSTUV.1234567890abcdef1234567890abcdef1234567890abcdef\n"
        )
        self.assertTrue(jira.startswith("ATATT"))
        self.assertTrue(dt.startswith("dt0c01."))

    def test_parse_missing_jira(self):
        with self.assertRaises(ValueError):
            mod.parse_key_file("dt0c01.ABCDEFGHIJKLMNOPQRSTUV.1234567890abcdef1234567890abcdef1234567890abcdef")

    def test_jira_basic_header(self):
        header = mod.jira_basic_header("user@example.com", "tok")
        self.assertTrue(header.startswith("Basic "))
        decoded = base64.b64decode(header.split(" ", 1)[1]).decode()
        self.assertEqual(decoded, "user@example.com:tok")


if __name__ == "__main__":
    unittest.main()
