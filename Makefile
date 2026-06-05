.PHONY: mac-setup brew-folder podman-setup lint fmt update whats-new doctor precommit help

# Discovers all shell scripts under src/scripts/ automatically —
# adding a new script requires no Makefile changes.
SHELL_SCRIPTS := $(shell find src/scripts -name '*.sh' | sort) src/dotfiles/claude/statusline-command.sh

##  mac-setup: install packages, .zshrc, .databrickscfg
mac-setup:
	@bash src/scripts/setup.sh

## podman-setup: setup podman machine and registry mirror
podman-setup:
	@bash src/scripts/setup_podman.sh

## lint: run shellcheck on all shell scripts (same check CI runs)
lint:
	@shellcheck -x --severity=warning $(SHELL_SCRIPTS) && echo "✅ shellcheck clean"

## fmt: auto-format all shell scripts with shfmt (2-space indent, matches pre-commit)
fmt:
	@shfmt -w -i 2 -ci -sr $(SHELL_SCRIPTS) && echo "✅ formatted"

## update: brew update + upgrade + bundle + cleanup (one command, no thinking)
update:
	brew update && brew upgrade && brew bundle --file=src/dotfiles/homebrew/Brewfile && brew cleanup

## whats-new: list outdated brew packages and their GitHub release notes (no install)
whats-new:
	@bash src/scripts/whats_new.sh

## doctor: sanity check — brew doctor + podman info
doctor:
	@brew doctor && podman info > /dev/null && echo "✅ all systems green"

## precommit: install + run pre-commit on the whole repo
precommit:
	@pre-commit install && pre-commit run --all-files

## brew-folder: print Homebrew installation prefix
brew-folder:
	brew --prefix

#################################################################################
# Self Documenting Commands                                                     #
#################################################################################
.DEFAULT_GOAL := help
# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
#   * save line in hold space
#   * purge line
#   * Loop:
#       * append newline + line to hold spaceg
#       * go to next line
#       * if line starts with doc comment, strip comment character off and loop
#   * remove target prerequisites
#   * append hold space (+ newline) to line
#   * replace newline plus comments by `---`
#   * print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
