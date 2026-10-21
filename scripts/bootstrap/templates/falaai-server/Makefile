# falaai-server — pipeline de qualidade. Hooks e Gas Town chamam estes alvos.
include mk/hooks.mk

GOLANGCI_VERSION    ?= v2.12.2
GOSEC_VERSION       ?= v2.28.0
GOVULNCHECK_VERSION ?= v1.3.0
COVERAGE_VERSION    ?= v2.19.0
SQLC_VERSION        ?= v1.30.0
GITLEAKS_VERSION    ?= v8.28.0
GOIMPORTS_VERSION   ?= v0.38.0
GOBIN := $(shell go env GOPATH)/bin

.PHONY: tools fmt lint test test-integration security build check check-fast cover
tools: hooks ## Instala ferramentas pinadas e ativa os hooks
	go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@$(GOLANGCI_VERSION)
	go install github.com/securego/gosec/v2/cmd/gosec@$(GOSEC_VERSION)
	go install golang.org/x/vuln/cmd/govulncheck@$(GOVULNCHECK_VERSION)
	go install github.com/vladopajic/go-test-coverage/v2@$(COVERAGE_VERSION)
	go install github.com/sqlc-dev/sqlc/cmd/sqlc@$(SQLC_VERSION)
	go install github.com/zricethezav/gitleaks/v8@$(GITLEAKS_VERSION)
	go install golang.org/x/tools/cmd/goimports@$(GOIMPORTS_VERSION)

fmt: ## Formata
	gofmt -s -w . && $(GOBIN)/goimports -w -local github.com/falaai-br .

lint: ## gofmt check, go vet, golangci-lint, sqlc vet
	@test -z "$$(gofmt -s -l . | grep -v '^gen/')" || { gofmt -s -l .; echo "rode 'make fmt'"; exit 1; }
	go vet ./...
	$(GOBIN)/golangci-lint run ./...
	@if [ -f sqlc.yaml ] && ls db/queries/*.sql >/dev/null 2>&1; then $(GOBIN)/sqlc vet; fi

test: ## Testes unitários com race e cobertura
	go test -race -count=1 -timeout 5m -coverprofile=coverage.out -covermode=atomic ./...
	$(GOBIN)/go-test-coverage --config=.testcoverage.yml

test-integration: ## Testes de integração (testcontainers: Postgres, Redis) e de contrato
	@docker info >/dev/null 2>&1 || { echo "Docker não está rodando: testes de integração precisam dele"; exit 1; }
	go test -race -count=1 -tags integration -timeout 15m ./...

security: ## gosec, govulncheck, gitleaks
	$(GOBIN)/gosec -quiet -exclude-generated ./...
	$(GOBIN)/govulncheck ./...
	$(GOBIN)/gitleaks git --no-banner --redact .

build: ## Build e verificação de código gerado
	go build ./...
	@if [ -f sqlc.yaml ] && ls db/queries/*.sql >/dev/null 2>&1; then $(GOBIN)/sqlc diff; fi

check-fast: ## pre-commit: rápido
	@test -z "$$(gofmt -s -l . | grep -v '^gen/')" || { gofmt -s -l .; echo "rode 'make fmt'"; exit 1; }
	go vet ./...
	$(GOBIN)/golangci-lint run --fast-only ./...
	$(GOBIN)/gitleaks git --no-banner --redact --staged .

check: lint test test-integration security build ## pre-push e gate do Refinery
