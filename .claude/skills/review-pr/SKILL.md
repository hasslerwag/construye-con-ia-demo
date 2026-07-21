---
name: review-pr
description: Use when reviewing a pull request or a diff in this repo. A fixed recipe — identify intent, count added tests, check coverage, match intent to code, run the suite, and give a PASS/CONCERNS verdict.
---

# review-pr (recipe)

This is a RECIPE skill: follow the steps IN ORDER, do not skip any, and report each
step's result before moving on.

## 1. Identify the PR's intent
- If given a PR number, read it with `gh pr view <n>`. Otherwise read the diff
  (`git diff <base>...HEAD`).
- State in **one sentence** what this change is supposed to do.

## 2. Count the added tests
- `git diff <base>...HEAD -- tests/` and count new test functions:
  `git diff <base>...HEAD -- tests/ | grep -c '^+def test_'`
- New behavior with **zero** new tests is a CONCERN.

## 3. Check coverage
- Run `poetry run pytest --cov=app --cov-report=term-missing`.
- Note the coverage % and any uncovered lines in files the PR touched.

## 4. Match intent to code
- For each changed file in `app/`, confirm it actually serves the intent from step 1.
- Flag anything unrelated, risky, or missing — e.g. an endpoint added with no template
  when it needs UI, or a model field added but `storage.py` never updated.

## 5. Run the suite
- Run `poetry run pytest`. Every test must pass.

## 6. Verdict
Emit exactly one:
- **PASS** — intent clear, tests added and passing, coverage not reduced, code matches intent.
- **CONCERNS** — a bullet per concern with the file/line and why it matters.

No praise padding. Be specific and short.
