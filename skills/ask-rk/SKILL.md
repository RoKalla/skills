---
name: ask-rk
description: "Which rk skill fits your situation? A router over the skills in this library. Usage: /ask-rk [your situation]"
disable-model-invocation: true
argument-hint: "[your situation]"
license: MIT
metadata:
  version: "1.1.1"
---

Recommend the rk skill, or sequence of skills, that fits the user's situation (`$ARGUMENTS`, or ask what they're trying to do). Name the command, say why it fits, and mention the alternative when two are close. If none fits, say so.

## Reviewing someone else's PR

* `/rk-review [target-branch]`: senior-engineer review of the current branch. Findings stay in the conversation, numbered `#1`, `#2`, …; nothing is posted. Pick this to read or adjust the findings before anyone sees them.
* `/rk-post-findings`: run after `/rk-review` in the same conversation. Posts the findings as one batch (GitHub: one review with a resolvable thread per finding; elsewhere: one comment), after the user approves a draft. Skips findings an earlier run already posted.
* `/rk-full-review [target-branch]`: both in one run, with the same instructions (it's generated from the two skills above). Pick this when you'll post anyway.

## Addressing feedback on your own PR

* `/rk-address-review [PR]`: triages every open review comment (from `rk-review`, people, or bots), applies the valid fixes as local commits after the user approves the plan, and drafts replies. It never posts or pushes.

## The loop

1. Reviewer: `/rk-review`, then `/rk-post-findings` (or `/rk-full-review`).
2. Author: `/rk-address-review`, then pushes and posts the drafted replies.
3. Reviewer: `/rk-full-review` again. Findings that are still open aren't posted twice; fixed ones are noted in the summary.

All rk skills find the PR's platform from the git remote and use its CLI (`gh`, `glab`, `az`), so no setup step is needed.
