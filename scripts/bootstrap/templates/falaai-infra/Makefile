# falaai-infra — pipeline de qualidade.
include mk/hooks.mk

GOLANGCI_VERSION    ?= v2.12.2
GOSEC_VERSION       ?= v2.28.0
GOVULNCHECK_VERSION ?= v1.3.0
GITLEAKS_VERSION    ?= v8.28.0
GOBIN := $(shell go env GOPATH)/bin
SH_FILES := $(shell git ls-files '*.sh' 2>/dev/null)

.PHONY: tools fmt lint test test-integration security build check check-fast
tools: hooks ## Instala ferramentas pinadas e ativa os hooks
	go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@$(GOLANGCI_VERSION)
	go install github.com/securego/gosec/v2/cmd/gosec@$(GOSEC_VERSION)
	go install golang.org/x/vuln/cmd/govulncheck@$(GOVULNCHECK_VERSION)
	go install github.com/zricethezav/gitleaks/v8@$(GITLEAKS_VERSION)
	@command -v shellcheck >/dev/null || echo "instale shellcheck (brew install shellcheck)"

fmt: ## Formata
	gofmt -s -w .

lint: ## gofmt, go vet, golangci-lint, shellcheck
	@test -z "$$(gofmt -s -l .)" || { gofmt -s -l .; echo "rode 'make fmt'"; exit 1; }
	go vet ./...
	$(GOBIN)/golangci-lint run ./...
	@if [ -n "$(SH_FILES)" ]; then shellcheck $(SH_FILES); fi

test: ## Testes unitários das stacks Pulumi (mocks)
	go test -race -count=1 ./...

test-integration: ## Valida o docker-compose de desenvolvimento
	@if [ -f docker-compose.yml ]; then docker compose -f docker-compose.yml config -q; fi

security: ## gosec, govulncheck, gitleaks
	$(GOBIN)/gosec -quiet ./...
	$(GOBIN)/govulncheck ./...
	$(GOBIN)/gitleaks git --no-banner --redact .

build: ## Build
	go build ./...

check-fast: ## pre-commit
	@test -z "$$(gofmt -s -l .)" || { gofmt -s -l .; echo "rode 'make fmt'"; exit 1; }
	go vet ./...
	$(GOBIN)/gitleaks git --no-banner --redact --staged .

check: lint test test-integration security build ## pre-push e gate do Refinery
