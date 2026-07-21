#!/usr/bin/env python3
"""PreToolUse hook: block any shell command that targets a production environment.

Reads the tool-call JSON from stdin. If the Bash command references a prod target, it
emits a ``deny`` permission decision so Claude never runs it. This is a guardrail demo:
in a real project it stops an agent from touching prod by accident.
"""

import json
import re
import sys

PROD_PATTERNS = [
    r"\bprod\b",
    r"\bproduction\b",
    r"--env[= ]+prod",
    r"deploy\b.*\bprod",
    r"kubectl\b.*\bprod",
]


def main() -> None:
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)  # nothing to inspect

    command = payload.get("tool_input", {}).get("command", "")
    for pattern in PROD_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            decision = {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": (
                        "Comando bloqueado: parece apuntar a producción "
                        f"(coincide con /{pattern}/). Este repo es una demo; "
                        "nunca ejecutamos contra prod."
                    ),
                }
            }
            print(json.dumps(decision))
            sys.exit(0)


if __name__ == "__main__":
    main()
