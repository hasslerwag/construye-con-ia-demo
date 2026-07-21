"""Domain models for the task tracker."""

from __future__ import annotations

from dataclasses import dataclass

# A task is either being worked on or finished. Kept as strings (not an enum) so the
# demo stays approachable for a mixed audience reading the diff live.
VALID_STATUSES = ("open", "done")


@dataclass
class Task:
    id: int
    title: str
    status: str  # one of VALID_STATUSES
