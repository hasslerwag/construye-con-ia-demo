#!/usr/bin/env python3
"""PostToolUse hook: run ``ruff format`` on a Python file right after Claude edits it.

Keeps the tree formatted without the agent having to remember to. Non-blocking: any
failure here is swallowed so it never interrupts the workflow. Tries a bare ``ruff``
first (fast, if it's on PATH) and falls back to ``poetry run ruff``.
"""

import json
import shutil
import subprocess
import sys


def _ruff_cmd() -> list[str]:
    if shutil.which("ruff"):
        return ["ruff"]
    return ["poetry", "run", "ruff"]


def main() -> None:
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    file_path = payload.get("tool_input", {}).get("file_path", "")
    if not file_path.endswith(".py"):
        sys.exit(0)

    ruff = _ruff_cmd()
    subprocess.run([*ruff, "format", file_path], capture_output=True, text=True)
    subprocess.run([*ruff, "check", "--fix", file_path], capture_output=True, text=True)


if __name__ == "__main__":
    main()
