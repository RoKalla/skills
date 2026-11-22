---
name: rk-full-review
description: "Review the current branch and post the findings to its PR, in one run: /rk-review followed by /rk-post-findings. Shows a draft before posting. Usage: /rk-full-review [target-branch]"
disable-model-invocation: true
argument-hint: "[target-branch]"
license: MIT
metadata:
  version: "1.1.0"
---

Run two parts in order: a code review of this branch, then posting its findings to the PR. Finish part 1, including its final assessment, before starting part 2.

{{shared:platform}}

## Part 1: Review

{{body:skills/rk-review/SKILL.md}}

## Part 2: Post the findings

{{body:skills/rk-post-findings/SKILL.md}}
