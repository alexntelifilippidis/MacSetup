# Claude Code Configuration

Files in this directory are symlinked into `$HOME/.claude/` by `make mac-setup`.
`CLAUDE.md` is the exception — it lands at `$HOME/CLAUDE.md` (Claude Code's global instructions root).

## Structure

```
.claude/
├── CLAUDE.md                        → ~/CLAUDE.md
├── settings.json                    → ~/.claude/settings.json
├── settings.local.json              → ~/.claude/settings.local.json  (gitignored values)
├── statusline-command.sh            → ~/.claude/statusline-command.sh
├── rules/
│   ├── code-style.md                shell + Python formatting rules
│   ├── api-conventions.md           Databricks, Terraform, secrets
│   ├── pr.md                        branch naming, commit format, pre-PR checklist
│   ├── git/
│   │   ├── github.md                personal GitHub identity + gh CLI workflow
│   │   └── gitlab.md                work GitLab (KaizenGaming) identity + glab CLI workflow
│   └── repos/
│       ├── terraform.md             Azure provider, state, plan/apply conventions
│       ├── python.md                uv, ruff, pytest, src/ layout
│       ├── scala.md                 Scala 2.12+, SBT, Spark, Delta Lake
│       └── sql.md                   Spark SQL / dbt: formatting, naming, Delta patterns
├── commands/
│   ├── review.md                    /review — severity-ordered code review
│   └── deploy.md                    /deploy — dotfile + setup deployment
├── skills/
│   └── testing-patterns/
│       └── SKILL.md                 test pyramid, bats, golden-file, pytest patterns
├── agents/
│   ├── code-reviewer.md             5-axis review agent (correctness/security/perf/…)
│   └── security-auditor.md          secrets, injection, PII, IAM audit agent
└── hooks/
    └── validate-code.sh             pre-edit shellcheck + shfmt validation
```

## How it works

`setup_claude` in `src/scripts/lib/tools.sh` uses a `find` loop — every file under this
directory is automatically symlinked to the equivalent path under `~/.claude/` on the
next `make mac-setup`. Adding a new rule file requires no changes to the setup script.

`CLAUDE.md` imports the rule, agent, and skill files via `@.claude/<path>` so their
content is loaded into every Claude Code session automatically.

## Documentation

- [Claude Code overview](https://docs.anthropic.com/en/docs/claude-code)
- [Settings reference](https://docs.anthropic.com/en/docs/claude-code/settings)
- [Hooks reference](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [Status line](https://docs.anthropic.com/en/docs/claude-code/status-line)
- [Custom commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)
- [Custom agents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)
