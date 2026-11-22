# skills

Reusable [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) for Claude Code and other agents that support the `SKILL.md` format.

## Skills

| Skill | Description |
| --- | --- |
| [`rk-review`](skills/rk-review/SKILL.md) | Senior-engineer review of the current branch against its target branch. It auto-detects the target from the PR or branch history and reads the PR discussion so it doesn't repeat settled points. |

## Install

### Option 1: `skills` CLI

```bash
npx skills add RoKalla/skills
```

### Option 2: Claude Code plugin marketplace

```
/plugin marketplace add RoKalla/skills
/plugin install rk-skills@rk-skills
```

### Option 3: Manual

Copy a skill folder into your skills directory:

```bash
git clone https://github.com/RoKalla/skills.git
cp -r skills/skills/rk-review ~/.claude/skills/        # all projects
# or
cp -r skills/skills/rk-review <your-repo>/.claude/skills/   # one project
```

## Usage

### `rk-review`

Run inside a git repo on the branch you want reviewed:

```
/rk-review              # auto-detect the target branch
/rk-review main         # review against a specific branch
```

The review:

- learns the surrounding codebase and its conventions first
- reads the PR description, commits, linked issues and the PR's review discussion, on any hosting platform
- diffs against the merge-base with the target branch
- reports findings with severity and confidence

The skill sets `disable-model-invocation: true`, so it only runs when you call it explicitly.

## Versioning

Releases use [semantic versioning](https://semver.org) and are tagged in git (`v1.0.0`, ...). The version is recorded in each skill's `SKILL.md` frontmatter (`metadata.version`), so it travels with the skill to any agent.

Installs track the latest commit on `main` by default. To pin a release, check out a tag:

```bash
git clone --branch v1.0.2 https://github.com/RoKalla/skills.git
```

## License

[MIT](LICENSE)
