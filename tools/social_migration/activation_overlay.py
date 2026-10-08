"""Deterministic opt-in G004 coverage overlay; immutable pins never change."""
import copy
import json
from pathlib import Path

from social_reference_checks import audit, expected_policy

POLICY_PATH = Path(__file__).resolve().parent / "reference/social_activation.json"


def apply(packages):
    # Full hash/semantic protection also validates every historical NPC input.
    audit()
    policy = json.loads(POLICY_PATH.read_text(encoding="utf-8"))
    assert policy == expected_policy(), "Unapproved social activation policy"
    result = copy.deepcopy(packages)
    by_id = {package["id"]: package for package in result}
    assert list(by_id) == policy["selected_ids"], "Social overlay roster mismatch"
    for kind, rows in policy["enable"].items():
        for row in rows:
            coverage = by_id[row["npc_id"]]["coverage"][kind]
            assert coverage[row["id"]]["status"] == "deferred", row
            coverage[row["id"]] = {
                "status": "enabled",
                "reason": "Approved social activation " + policy["policy_id"],
            }
    for row in policy["preserve_deferred"]:
        assert by_id[row["npc_id"]]["coverage"][row["kind"]][row["id"]]["status"] == "deferred", row
    return result
