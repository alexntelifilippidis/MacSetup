# Global Git Commit Message Instructions

## Format

Always use **Conventional Commits** format:

```
<type>(<optional scope>): <short summary>
```

## Allowed Commit Types

- `feat` — ✨ a new feature
- `fix` — 🐛 a bug fix
- `chore` — 🔧 routine task (build config, dependencies, maintenance)
- `ci` — 🤖 changes to CI/CD configuration
- `docs` — 📚 documentation only changes
- `perf` — 🚀 performance improvement
- `refactor` — 🛠️ code change that neither fixes a bug nor adds a feature
- `revert` — ⏪ revert a previous commit
- `style` — 💅 formatting, missing semi-colons, etc. (no logic changes)
- `test` — 🧪 adding or updating tests

## MR Title Regex (enforced by GitLab CI)

```
^((feat|fix|chore|ci|docs|perf|refactor|revert|style|test)(\([[:alnum:][:space:]\/:,-]+\))?(!)?: .+|Merge branch .+|[iI]nitial commit)$
```

## Rules

- **Summary line:** imperative mood, lowercase, no period at the end, max 72 chars
  - ✅ `feat: add podman registry mirror setup`
  - ❌ `Added podman registry mirror setup.`
- **Scope (optional):** use the module/area affected, e.g. `feat(bronze): ...`, `fix(zsh): ...`
  - Scope may contain alphanumeric characters, spaces, `/`, `:`, `,`, `-`
- **Breaking changes:** add `BREAKING CHANGE:` footer or `!` after type, e.g. `feat!: ...`
- **Body (optional):** wrap at 72 chars, explain *what* and *why* (not *how*)
- Never commit directly to `main` or `master`

## Branch Naming Convention (enforced by GitLab CI)

```
^((feature|bugfix|hotfix|release|chore|config)/([A-Z]+-\d+|NOJIRA)-.*|main|master)$
```

| Prefix | When to use |
|---|---|
| `feature/` | New functionality |
| `bugfix/` | Bug fixes |
| `hotfix/` | Urgent production fixes |
| `release/` | Release preparation |
| `chore/` | Maintenance, dependency updates |
| `config/` | Configuration changes |

- Ticket: `[A-Z]+-\d+` (e.g. `PROJ-123`, `BST-456`) or `NOJIRA` if no ticket
- Use `NOJIRA` only for trivial changes with no associated ticket

**Examples:**

```
feature/PROJ-123-add_login
bugfix/PROJ-456-fix_header_overlap
hotfix/BST-789-patch_null_pointer
chore/NOJIRA-cleanup_deps
config/DATA-321-update_databricks_target
```

## Commit/MR Examples

```
feat(auth): add OAuth2 support
feat(podman): add docker hub registry mirror configuration
fix(setup): ensure .databrickscfg permissions are set to 600
fix(ui): resolve button alignment issue
chore: update Brewfile with python 3.13
refactor(zsh): simplify PATH exports in .zshrc
docs: update README with podman troubleshooting steps
ci: add pre-commit hook for shellcheck validation
revert: revert feat(podman) registry mirror change
style: fix trailing whitespace in setup.sh
test: add unit tests for record validation
```
