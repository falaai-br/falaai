# falaai (docs) — pipeline de qualidade. Hooks chamam estes alvos.
include mk/hooks.mk

MARKDOWNLINT_VERSION ?= 0.24.0
GITLEAKS_VERSION     ?= v8.28.0
MDLINT := npx --yes markdownlint-cli2@$(MARKDOWNLINT_VERSION)
SH_FILES := $(filter-out %.md,$(shell git ls-files '*.sh' '.githooks/*' 2>/dev/null))

.PHONY: tools fmt lint test test-integration security build check check-fast
tools: hooks ## Instala ferramentas pinadas e ativa os hooks
	go install github.com/zricethezav/gitleaks/v8@$(GITLEAKS_VERSION)
	@command -v shellcheck >/dev/null || echo "instale shellcheck (brew install shellcheck)"
	@command -v npx >/dev/null || echo "instale Node.js (npx) para o markdownlint"

fmt: ## Corrige o que o markdownlint sabe corrigir
	$(MDLINT) --fix "**/*.md"

lint: ## markdownlint, shellcheck e sintaxe dos scripts
	$(MDLINT) "**/*.md"
	shellcheck -x $(SH_FILES)
	@for f in $(SH_FILES); do head -1 $$f | grep -q bash && bash -n $$f || sh -n $$f; done

test: ## Links internos
	python3 scripts/check-links.py

test-integration: ## Valida os templates: make -n check em cada um
	@for r in scripts/bootstrap/templates/falaai-*; do \
	  d=$$(mktemp -d); cp -R $$r/. $$d/; cp -R scripts/bootstrap/templates/_common/mk $$d/; \
	  (cd $$d && git init -q && $(MAKE) -s -n check >/dev/null) || { echo "template quebrado: $$r"; rm -rf $$d; exit 1; }; \
	  rm -rf $$d; done; echo "templates ok"

security: ## gitleaks
	gitleaks git --no-banner --redact .

build: ## Nada a compilar
	@true

check-fast: ## pre-commit
	$(MDLINT) "**/*.md"
	shellcheck -x $(SH_FILES)
	gitleaks git --no-banner --redact --staged .

check: lint test test-integration security build ## pre-push
