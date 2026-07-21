#!/usr/bin/env python3
"""PreToolUse hook: scan staged changes for secrets before a commit.

Fires on Bash commands but only acts when the command is a ``git commit``. It runs
``git diff --cached`` and looks for common secret shapes; on a match it denies the
commit so the secret never lands in history.
"""

import json
import re
import subprocess
import sys

SECRET_PATTERNS = [
    (r"AKIA[0-9A-Z]{16}", "AWS access key id"),
    (r"-----BEGIN [A-Z ]*PRIVATE KEY-----", "private key"),
    (r"gh[pousr]_[A-Za-z0-9]{20,}", "GitHub token"),
    (
        r"(?i)(api[_-]?key|secret|token|password)\s*[:=]\s*['\"][^'\"]{12,}['\"]",
        "hardcoded credential",
    ),
]


def main() -> None:
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    command = payload.get("tool_input", {}).get("command", "")
    if "git commit" not in command:
        sys.exit(0)

    try:
        diff = subprocess.run(
            ["git", "diff", "--cached"], capture_output=True, text=True, timeout=10
        ).stdout
    except Exception:
        sys.exit(0)  # can't read the diff -> don't block, just bail

    findings = sorted({label for pattern, label in SECRET_PATTERNS if re.search(pattern, diff)})
    if findings:
        decision = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": (
                    "Commit bloqueado: se detectaron posibles secretos en los cambios "
                    f"en stage ({', '.join(findings)}). Quita el secreto o usa variables "
                    "de entorno antes de commitear."
                ),
            }
        }
        print(json.dumps(decision))
    sys.exit(0)


if __name__ == "__main__":
    main()
