# Contributing

How this repo is laid out, which files are generated, and how to add a skill or cut a release.

## Layout

```
skills/<name>/SKILL.md        one folder per skill; each is self-contained
shared/platform.md            "Where the PR lives" section, copied into several skills
templates/rk-full-review.md   template for the generated rk-full-review skill
scripts/build.py              the generator
.claude-plugin/marketplace.json   Claude Code plugin manifest
.github/workflows/            CI: fails if generated files are out of date
```

Skill folders must stay self-contained: `npx skills add` and manual installs copy each folder on its own, so a skill can't reference files outside its folder. Shared text is copied into each skill by the generator instead.

## Generated files

| Generated | From |
| --- | --- |
| Text between `<!-- BEGIN SHARED: platform -->` and `<!-- END SHARED: platform -->` in any skill | `shared/platform.md` |
| `skills/rk-full-review/SKILL.md` (whole file) | `templates/rk-full-review.md` + the bodies of `rk-review` and `rk-post-findings` |

Edit the sources, never the generated text: the next build overwrites it.

Run `make build` after changing any of:

- `shared/platform.md`
- `skills/rk-review/SKILL.md`
- `skills/rk-post-findings/SKILL.md`
- `templates/rk-full-review.md`

Other edits (README, `ask-rk`, the non-generated parts of `rk-address-review`, …) need no build. Running it anyway is harmless.

| Command | What it does |
| --- | --- |
| `make build` | Regenerates the files above. |
| `make check` | Writes nothing; exits non-zero if a generated file is out of date. CI runs this on every push and PR. |
| `make help` | Lists the targets. |

### How the generator builds `rk-full-review`

For each included skill it drops the frontmatter and the shared blocks, then pushes every heading down one level so the skill nests under its `## Part N` heading. The shared platform section is included once, at the top. The frontmatter (name, description, version) comes from the template.

To use the shared section in another skill, add the empty markers where it should go and run `make build`:

```
<!-- BEGIN SHARED: platform -->
<!-- END SHARED: platform -->
```

A new shared section works the same way: create `shared/<name>.md` and use `<!-- BEGIN SHARED: <name> -->` markers.

## Adding a skill

1. Create `skills/<name>/SKILL.md` with frontmatter:

   ```yaml
   ---
   name: <name>
   description: "<one line>. Usage: /<name> [args]"
   disable-model-invocation: true
   argument-hint: "[args]"
   license: MIT
   metadata:
     version: "<current release>"
   ---
   ```

   All rk skills are user-invoked (`disable-model-invocation: true`), so a skill can't call another rk skill. Shared behaviour goes through the generator.
2. Add `./skills/<name>` to `skills` in `.claude-plugin/marketplace.json`.
3. Add a row to the Skills table and a Usage section in `README.md`.
4. Add the skill to `skills/ask-rk/SKILL.md` so the router knows about it.
5. Run `make build` if the skill uses shared sections, then `make check`.

Quote frontmatter strings that contain `:` or start with `[`; unquoted they break the YAML (the reason for v1.0.1).

## Versioning and releases

Versions follow [semver](https://semver.org) and apply to the whole repo: a release sets the same version everywhere.

- **Patch** (`1.1.1`): fixes and wording changes.
- **Minor** (`1.2.0`): new skills or new behaviour.
- **Major** (`2.0.0`): changes that break how existing skills are invoked.

To release:

1. Set the new version in every `skills/*/SKILL.md` (`metadata.version`), in `templates/rk-full-review.md`, and in `.claude-plugin/marketplace.json`.
2. Update the pin example in `README.md` (`git clone --branch vX.Y.Z …`).
3. Run `make build` and `make check`.
4. Commit, then create an annotated tag whose message is the release notes: `git tag -a vX.Y.Z -F notes.md`.
5. Push the commit and the tag: `git push origin main vX.Y.Z`.
6. Create the GitHub release from the same notes: `gh release create vX.Y.Z --title vX.Y.Z --notes-file notes.md --verify-tag`.
