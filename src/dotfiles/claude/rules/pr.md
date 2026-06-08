# PR Conventions

## Branch Naming

Must match CI pattern:

```
(feature|bugfix|hotfix|release|chore|config)/<short-description>
```

Examples:

- `feature/add-zsh-aliases`
- `chore/update-brewfile`
- `bugfix/fix-podman-registry`

## Commit Format

Conventional commits, imperative mood:

```
type(scope): what it does
```

Types: `feat` | `fix` | `chore` | `ci` | `docs` | `perf` | `refactor` | `revert` | `style` | `test`

Scopes: `homebrew` | `zsh` | `podman` | `git` | `claude` | `scripts`

## Pre-PR Checklist

```bash
pre-commit run --all-files   # must pass
make lint                    # shellcheck clean
make fmt                     # shfmt clean
make doctor                  # environment healthy
```

## PR Creation

```bash
gh pr create
```

- Read `.github/pull_request_template.md`
- Fill every section from the diff
- No placeholder text, no empty headings, no skipped checklist items
- Never commit or push directly to `main`/`master`
