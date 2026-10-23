#!/usr/bin/env bash
# Bootstrap do FalaAí: repositórios GitHub, labels, rigs do Gas Town, beads da Fase 0
# espelhadas em GitHub Issues e convoy da Fase 0. Idempotente: pode rodar de novo.
#
# Uso:  ORG=falaai-br scripts/bootstrap/bootstrap.sh [etapa...]
# Etapas: repos labels rigs settings github seed sync convoy   (padrão: todas, nessa ordem)
set -euo pipefail

ORG="${ORG:-falaai-br}"
GT_HOME="${GT_HOME:-$HOME/gt}"
DOCS_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TPL="$DOCS_DIR/scripts/bootstrap/templates"
LIC="$DOCS_DIR/scripts/bootstrap/licenses"
WORK="${TMPDIR:-/tmp}/falaai-bootstrap"
PATH="$(go env GOPATH 2>/dev/null)/bin:$HOME/.cargo/bin:$(brew --prefix rustup 2>/dev/null)/bin:$PATH"
export PATH

# repo | rig | prefixo beads | visibilidade | licença | descrição
REPOS=(
  "falaai|falaai|flh|public|cc-by-sa-4.0|Blueprint, ADRs e documentação do FalaAí, mensageiro brasileiro com criptografia ponta a ponta"
  "falaai-core|falaai_core|flc|public|agpl-3.0|Núcleo criptográfico do FalaAí em Rust sobre a libsignal"
  "falaai-app|falaai_app|fla|public|agpl-3.0|App FalaAí para Android e iOS (Flutter)"
  "falaai-proto|falaai_proto|flp|public|apache-2.0|Contratos protobuf entre app e servidor do FalaAí"
  "falaai-server|falaai_server|fls|private|none|Servidor Go do FalaAí"
  "falaai-infra|falaai_infra|fli|private|none|Infraestrutura do FalaAí (Pulumi, AWS sa-east-1)"
)

log()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
die()  { printf '\033[1;31mERRO: %s\033[0m\n' "$*" >&2; exit 1; }
field() { echo "$1" | cut -d'|' -f"$2"; }
rig_dir() { echo "$GT_HOME/$1"; }
bdr() { local rig="$1"; shift; (cd "$(rig_dir "$rig")" && bd "$@"); }

preflight() {
  command -v gh >/dev/null || die "gh não encontrado"
  command -v gt >/dev/null || die "gt (Gas Town) não encontrado"
  command -v bd >/dev/null || die "bd (beads) não encontrado"
  local t; t="$(gh api "users/$ORG" --jq .type 2>/dev/null || true)"
  [[ "$t" == "Organization" ]] || die "A organização '$ORG' não existe no GitHub. Crie em https://github.com/organizations/plan (plano Free) e rode de novo."
  local dolt_status; dolt_status="$(cd "$GT_HOME" && gt dolt status 2>&1 || true)"
  if [[ "$dolt_status" == *"is not running"* ]]; then
    info "Dolt parado; iniciando com 'gt dolt start'"
    (cd "$GT_HOME" && gt dolt start) || die "não consegui iniciar o Dolt; veja 'gt dolt status'"
  fi
}

step_repos() {
  log "Repositórios em github.com/$ORG"
  mkdir -p "$WORK"
  for r in "${REPOS[@]}"; do
    local name vis lic desc; name=$(field "$r" 1); vis=$(field "$r" 4); lic=$(field "$r" 5); desc=$(field "$r" 6)
    if gh repo view "$ORG/$name" >/dev/null 2>&1; then
      info "$name: já existe"
    else
      gh repo create "$ORG/$name" "--$vis" --description "$desc" --disable-wiki >/dev/null
      info "$name: criado ($vis)"
    fi
    local src
    if [[ "$name" == "falaai" ]]; then
      src="$DOCS_DIR"
      [[ -d "$src/.git" ]] || die "$src não é repositório git"
    else
      src="$WORK/$name"
      if [[ ! -d "$src/.git" ]]; then
        rm -rf "$src"; mkdir -p "$src"
        cp -R "$TPL/$name/." "$src/"
        cp "$TPL/_common/SECURITY.md" "$src/SECURITY.md"
        cp -R "$TPL/_common/.githooks" "$TPL/_common/mk" "$src/"
        cp "$TPL/_common/.gitleaks.toml" "$TPL/_common/.editorconfig" "$src/"
        chmod +x "$src/.githooks/"*
        if [[ "$name" == "falaai-core" ]]; then (cd "$src" && cargo generate-lockfile -q); fi
        [[ "$lic" != "none" ]] && cp "$LIC/$lic.txt" "$src/LICENSE"
        grep -rl '__ORG__' "$src" | xargs -I{} sed -i '' "s/__ORG__/$ORG/g" {} 2>/dev/null || true
        git -C "$src" init -q -b main
        git -C "$src" add -A
        git -C "$src" commit -q -m "chore: estrutura inicial do repositório

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
        info "$name: rodando make check no esqueleto"
        (cd "$src" && make -s check >/dev/null) || die "$name: make check falhou no esqueleto; rode 'make check' em $src"
      fi
    fi
    git -C "$src" remote get-url origin >/dev/null 2>&1 || git -C "$src" remote add origin "git@github.com:$ORG/$name.git"
    if [[ -z "$(git ls-remote --heads "git@github.com:$ORG/$name.git" main 2>/dev/null)" ]]; then
      git -C "$src" push -q -u origin main && info "$name: push da main"
    else
      info "$name: main já publicada"
    fi
  done
}

step_labels() {
  log "Labels"
  local labels=(
    "fase-0|0E8A16|Fase 0: spike do protocolo" "fase-1|1D76DB|Fase 1: texto 1:1" "fase-2|5319E7|Fase 2: grupos e mídia"
    "fase-3|B60205|Fase 3: chamadas" "fase-4|FBCA04|Fase 4: beta e lançamento" "seguranca|D93F0B|Segurança"
    "cripto|000000|Criptografia" "backend|0052CC|Servidor" "mobile|C2E0C6|App" "infra|BFD4F2|Infraestrutura"
    "juridico|F9D0C4|Jurídico" "docs|0075CA|Documentação" "epic|3E4B9E|Epic"
  )
  for r in "${REPOS[@]}"; do
    local name; name=$(field "$r" 1)
    for l in "${labels[@]}"; do
      gh label create "$(field "$l" 1)" -R "$ORG/$name" --color "$(field "$l" 2)" --description "$(field "$l" 3)" --force >/dev/null
    done
    info "$name: ${#labels[@]} labels"
  done
}

step_rigs() {
  log "Rigs no Gas Town ($GT_HOME)"
  for r in "${REPOS[@]}"; do
    local name rig prefix; name=$(field "$r" 1); rig=$(field "$r" 2); prefix=$(field "$r" 3)
    if [[ -d "$(rig_dir "$rig")" ]]; then
      info "$rig: já registrada"
    else
      local extra=()
      [[ "$name" == "falaai" ]] && extra=(--local-repo "$DOCS_DIR")
      (cd "$GT_HOME" && gt rig add "$rig" "git@github.com:$ORG/$name.git" --prefix "$prefix" "${extra[@]}") || true
      info "$rig: registrada (prefixo $prefix)"
    fi
    fix_rig_db "$rig" "$prefix"
  done
}

# Contorno de gastownhall/beads#4566 (modo servidor): o 'gt rig add' cria o banco da rig
# sem commitar o schema, a migração recusa tabelas sujas e o issue_prefix nunca é gravado.
fix_rig_db() {
  local rig="$1" prefix="$2" cur
  cur="$(bdr "$rig" config get issue_prefix 2>&1 | tail -1 || true)"
  [[ "$cur" == "$prefix" ]] && { info "$rig: banco de beads ok"; return; }
  info "$rig: aplicando contorno beads#4566 (commit do schema + reinit do prefixo)"
  dolt --host 127.0.0.1 --port 3307 --user root --password "" --no-tls --use-db "$rig" \
    sql -q "CALL DOLT_COMMIT('-Am', 'chore: commit do schema inicial da rig (beads#4566)')" >/dev/null 2>&1 || true
  bdr "$rig" config get issue_prefix >/dev/null 2>&1 || true   # dispara a migração
  bdr "$rig" init --reinit-local --prefix "$prefix" --database "$rig" --server --external \
    --skip-agents --skip-hooks --non-interactive -q >/dev/null
  cur="$(bdr "$rig" config get issue_prefix 2>&1 | tail -1 || true)"
  [[ "$cur" == "$prefix" ]] || die "$rig: issue_prefix continua '$cur'; veja gastownhall/beads#4566"
  # O reinit perde os tipos do Gas Town e a bead de identidade da rig.
  bdr "$rig" config set types.custom "agent,role,rig,convoy,slot,queue,event,message,molecule,gate,merge-request" >/dev/null
  local repo; repo="$(cd "$GT_HOME" && python3 -c "import json,sys;print(json.load(open(sys.argv[1]+'/config.json'))['git_url'])" "$rig")"
  bdr "$rig" show "$prefix-rig-$rig" >/dev/null 2>&1 || bdr "$rig" create --silent --id="$prefix-rig-$rig" \
    --title="$rig" --type=rig --labels=gt:rig --force \
    -d "Rig identity bead for $rig.
repo: $repo
prefix: $prefix
state: active" >/dev/null
  info "$rig: banco de beads ok"
}

step_settings() {
  log "Gates de qualidade das rigs (merge_queue)"
  # gt v1.1.0 não aceita 'merge_queue.gates' em 'gt rig settings'; o Refinery usa test_command.
  # Quando o gt suportar gates nomeados, acrescentar: check (pre-merge) e build-merged (post-squash).
  local kv
  for r in "${REPOS[@]}"; do
    local rig; rig=$(field "$r" 2)
    for kv in "enabled=true" "run_tests=true" "setup_command=make tools" "lint_command=make lint" \
              "test_command=make check" "build_command=make build" \
              "judgment_enabled=true" "merge_strategy=pr" "require_review=false" \
              "on_conflict=assign_back" "retry_flaky_tests=1" "poll_interval=30s" "max_concurrent=1"; do
      (cd "$GT_HOME" && gt rig settings set "$rig" "merge_queue.${kv%%=*}" "${kv#*=}") >/dev/null
    done
    info "$rig: make check antes do merge, revisão por agente, PR no GitHub"
  done
}

step_github() {
  log "Espelho beads -> GitHub Issues"
  for r in "${REPOS[@]}"; do
    local name rig; name=$(field "$r" 1); rig=$(field "$r" 2)
    bdr "$rig" config set github.owner "$ORG" >/dev/null
    bdr "$rig" config set github.repo "$name" >/dev/null
    info "$rig -> $ORG/$name"
  done
}

# cria bead se não existir uma com o mesmo título; imprime o ID
mk() { # rig type labels priority title description
  local rig="$1" type="$2" lbls="$3" prio="$4" title="$5" desc="$6" id
  id="$(bdr "$rig" list --all -n 0 --json 2>/dev/null | python3 -c "import json,sys
t=sys.argv[1]
try: d=json.load(sys.stdin)
except Exception: d=[]
if isinstance(d,dict): d=d.get('issues') or d.get('items') or []
print(next((i.get('id','') for i in d if isinstance(i,dict) and i.get('title')==t),''))" "$title")"
  if [[ -z "$id" ]]; then
    id="$(bdr "$rig" create --silent -t "$type" -l "$lbls" -p "$prio" --title "$title" -d "$desc")"
  fi
  echo "$id"
}
dep() { bdr "$1" dep add "$2" "$3" >/dev/null 2>&1 || true; }

step_seed() {
  log "Beads: epics das fases e tarefas da Fase 0"
  local BP="https://github.com/$ORG/falaai/blob/main/docs"
  local E0 E1 E2 E3 E4
  E0=$(mk falaai epic "epic,fase-0" 1 "Fase 0 — Spike do protocolo" "libsignal via flutter_rust_bridge em iOS e Android; sessão 1:1 entre dois aparelhos físicos; NSE do iOS decifrando com app fechado; servidor mínimo.
Critério de saída: mensagem cifrada entre iPhone e Android, decifrada pelo NSE com app fechado. Esforço: 4-6 semanas.
Roadmap: $BP/blueprint/05-roadmap.md")
  E1=$(mk falaai epic "epic,fase-1" 2 "Fase 1 — Texto 1:1" "Registro com SMS e PIN, username, Triple Ratchet, sealed sender, outbox, recibos, push, safety numbers, efêmeras.
Critério de saída: 1.000 mensagens em 3 perfis de rede ruim sem perda nem duplicação. Detalhar ao fim da Fase 0.")
  E2=$(mk falaai epic "epic,fase-2" 2 "Fase 2 — Grupos e mídia" "Sender Keys, estado de grupo cifrado, convites por link, anexos com upload resumível, backup cifrado. Contratar auditoria externa.
Critério de saída: grupo de 50 com rotação de chave correta; fotos em 3G. Detalhar ao fim da Fase 1.")
  E3=$(mk falaai epic "epic,fase-3" 2 "Fase 3 — Chamadas de voz e vídeo" "1:1 com WebRTC + CallKit/ConnectionService + coturn; grupo via LiveKit com frame encryption.
Critério de saída: conexão > 95% em teste nacional; chamada recebida com tela bloqueada. Detalhar ao fim da Fase 2.")
  E4=$(mk falaai epic "epic,fase-4" 2 "Fase 4 — Beta, auditoria e lançamento" "Beta fechado (500 pessoas), auditoria externa publicada, bug bounty, lojas, relatório de transparência.
Critério de saída: zero achados críticos abertos; crash-free > 99,5%.")
  dep falaai "$E1" "$E0"; dep falaai "$E2" "$E1"; dep falaai "$E3" "$E2"; dep falaai "$E4" "$E3"

  local J1
  J1=$(mk falaai task "juridico,fase-0" 1 "Parecer jurídico: AGPL da libsignal × App Store" "Não há exceção §7 na libsignal Rust (issue signalapp/libsignal#684). Pedir confirmação formal à Signal e parecer de advogado de licenças. Bloqueia publicação na App Store (Fase 4). Ver $BP/legal/licenciamento-agpl.md")
  mk falaai task "juridico" 2 "Constituir entidade jurídica e nomear encarregado LGPD" "Empresa brasileira com representante legal; encarregado (LGPD art. 41) com contato público. Ver $BP/legal/lgpd-e-marco-civil.md" >/dev/null
  mk falaai task "juridico,docs" 2 "Publicar 'O que o FalaAí pode e não pode entregar'" "Documento público com fundamento técnico, antes do beta. Base: $BP/legal/retencao-e-resposta-a-ordens.md" >/dev/null
  dep falaai "$E4" "$J1"

  # ---- pipeline de qualidade: raiz de cada rig de código
  local QP QC QS QA QI
  local QD="make tools ativa os hooks; make check verde (lint, testes unitários, integração, segurança, build) sem pular nada. Garantir que um commit com mensagem fora do padrão é recusado e que o pre-push bloqueia falha. Ver $BP/blueprint/07-qualidade-e-pipeline.md"
  QP=$(mk falaai_proto task "fase-0,infra" 0 "Pipeline de qualidade verde: make tools, make check e hooks" "$QD
Específico: buf lint/breaking/generate com código Go versionado em gen/go.")
  QC=$(mk falaai_core task "fase-0,infra,cripto" 0 "Pipeline de qualidade verde: make tools, make check e hooks" "$QD
Específico: cargo deny aceitando AGPL-3.0 e só as fontes git da Signal; clippy -D warnings; teste de integração real em tests/.")
  QS=$(mk falaai_server task "fase-0,infra,backend" 0 "Pipeline de qualidade verde: make tools, make check e hooks" "$QD
Específico: testcontainers-go (Postgres, Redis) com build tag integration; go-test-coverage com 85% nos pacotes domain.")
  QA=$(mk falaai_app task "fase-0,infra,mobile" 0 "Pipeline de qualidade verde: make tools, make check e hooks" "$QD
Específico: analysis_options.yaml estrito; test_integration/ sem aparelho; make test-device documentado.")
  QI=$(mk falaai_infra task "fase-0,infra" 0 "Pipeline de qualidade verde: make tools, make check e hooks" "$QD
Específico: testes de stack Pulumi com mocks; docker compose config validado.")

  # ---- falaai-proto
  local P1
  P1=$(mk falaai_proto task "fase-0,backend,cripto" 1 "Definir Envelope, frames do WebSocket, ACK e PreKeyBundle em protobuf" "proto3 em proto/falaai/v1 com buf (lint + breaking). Gerar Go e Rust (prost).
- Envelope sem remetente em claro (sealed sender), com campo de tipo (mensagem, recibo, call_signal).
- Frames: Send, Deliver, Ack(seq), Ping.
- PreKeyBundle: identity, signed prekey, Kyber prekey, one-time prekey, registration id, device id.
Ver $BP/blueprint/03-backend-e-infra.md")

  # ---- falaai-core
  local C1 C2 C3 C4 C5
  C1=$(mk falaai_core task "fase-0,cripto" 0 "Esqueleto do crate com libsignal pinada por commit" "rust-toolchain.toml igual ao da libsignal; dependência git pinada (ADR-0001). Isolar a libsignal atrás de traits internas.")
  C2=$(mk falaai_core task "fase-0,cripto,mobile" 0 "Compilar o core para Android (3 ABIs) e iOS (xcframework)" "make build-mobile: cargo-ndk para arm64-v8a, armeabi-v7a, x86_64; xcframework com aarch64-apple-ios e aarch64-apple-ios-sim. Artefatos em dist/ (não versionados). Medir tamanho por ABI (meta: core < 10 MB).")
  C3=$(mk falaai_core task "fase-0,cripto" 0 "Stores da libsignal sobre SQLCipher" "Implementar IdentityKeyStore, SessionStore, PreKeyStore, SignedPreKeyStore, KyberPreKeyStore, SenderKeyStore sobre rusqlite com bundled-sqlcipher. Chave do banco recebida da plataforma (Keychain/Keystore). WAL + busy timeout, pensando no NSE do iOS.")
  C4=$(mk falaai_core task "fase-0,cripto,mobile" 0 "API flutter_rust_bridge: chaves, sessão, cifrar, decifrar e stream de eventos" "Funções async: generate_account_keys, process_prekey_bundle, encrypt, decrypt; Stream<ChatEvent> via StreamSink. Nenhum material de chave cruza o FFI. Erros tipados.")
  C5=$(mk falaai_core task "fase-0,cripto,backend" 1 "Teste PQXDH entre dois cores e vetores de envelope para o servidor" "Teste de integração: dois cores em processo trocam mensagens (PQXDH + Triple Ratchet), incluindo fora de ordem e duplicadas. Exportar vetores de envelope (protobuf) para testes de contrato no falaai-server. Depende de falaai-proto ($P1).")
  dep falaai_proto "$P1" "$QP"
  dep falaai_core "$C1" "$QC"; dep falaai_core "$C2" "$C1"; dep falaai_core "$C3" "$C1"; dep falaai_core "$C4" "$C3"; dep falaai_core "$C5" "$C3"

  # ---- falaai-server
  local S1 S2 S3 S4 S5
  S1=$(mk falaai_server task "fase-0,backend" 0 "Esqueleto Go modular com Postgres e migrations" "Um binário com módulos (accounts, keys, gateway, delivery); gin; sqlc + pgx/v5; goose; Dockerfile distroless; docker-compose local. Logger com redação de campos sensíveis desde o início.")
  S2=$(mk falaai_server task "fase-0,backend,seguranca" 1 "accounts mínimo: registro com OTP de desenvolvimento e token de dispositivo" "POST de registro com OTP fixo em dev (SMS real na Fase 1); ACI aleatório; phone_hmac + phone_enc; token de dispositivo (hash no banco). Sem log de telefone.")
  S3=$(mk falaai_server task "fase-0,backend,cripto" 1 "keys: upload e fetch de bundle com consumo de one-time prekey" "PUT do bundle por dispositivo; GET entrega um bundle e apaga a one-time prekey; aviso quando o pool < 20; rate limit por par (solicitante, alvo). O servidor guarda o bundle como opaco e valida só estrutura; a assinatura é verificada pela libsignal no cliente. Sem cripto escrita à mão e sem libsignal no servidor (AGPL). Rate limit com contadores separados por solicitante e por alvo, nunca do par (ADR-0008).")
  S4=$(mk falaai_server task "fase-0,backend" 1 "gateway + delivery mínimo: WebSocket, fila e DELETE no ACK" "WebSocket autenticado por token; message_queue particionada por hash; envelope sem remetente; entrega online via Redis pub/sub por pod; pendentes ao conectar; DELETE no ACK; TTL 30 dias (ADR-0008).")
  S5=$(mk falaai_server task "fase-0,backend,cripto" 2 "Testes de contrato com vetores do falaai-core" "Consumir vetores de envelope exportados pelo falaai-core e garantir que o servidor roteia sem alterar bytes.")
  dep falaai_server "$S1" "$QS"; dep falaai_server "$S2" "$S1"; dep falaai_server "$S3" "$S1"; dep falaai_server "$S4" "$S2"; dep falaai_server "$S5" "$S4"

  # ---- falaai-app
  local A1 A2 A3 A4
  A1=$(mk falaai_app task "fase-0,mobile" 0 "Esqueleto Flutter com Async Redux, go_router, pt-BR e falaai-core integrado" "Projeto Flutter; Async Redux; go_router; ARB pt-BR; integração do falaai-core via flutter_rust_bridge (Native Assets). Chave do SQLCipher gerada e guardada no Keychain/Keystore. Rodar em aparelho físico iOS e Android.")
  A2=$(mk falaai_app task "fase-0,mobile" 1 "Demo: registrar e trocar mensagem 1:1 entre iPhone e Android" "Telas mínimas: registro (OTP de dev), adicionar contato por ACI/QR, conversa. Mensagem cifrada ponta a ponta via servidor de desenvolvimento.")
  A3=$(mk falaai_app task "fase-0,mobile,cripto" 0 "iOS: Notification Service Extension decifrando via App Group" "NSE linka o falaai-core (xcframework estático), abre o SQLCipher via App Group, busca o envelope e decifra dentro de ~24 MB/30s. Lock para nunca avançar o ratchet em dois processos. Fallback 'Nova mensagem'.")
  A4=$(mk falaai_app task "fase-0,mobile" 1 "Android: FCM data message decifrando no serviço" "FirebaseMessagingService chama o core, busca e decifra, mostra notificação local. Medir comportamento em Doze.")
  dep falaai_app "$A1" "$QA"; dep falaai_app "$A2" "$A1"; dep falaai_app "$A3" "$A1"; dep falaai_app "$A4" "$A1"

  # ---- falaai-infra
  local I1 I2
  I1=$(mk falaai_infra task "fase-0,infra" 1 "Ambiente de desenvolvimento: docker-compose e AWS local (LocalStack) com Pulumi" "docker-compose com Postgres, Redis, RedPanda e LocalStack (S3, SQS, KMS, Secrets Manager) para dev local.
Stack Pulumi (Go) 'local' apontando para o LocalStack (endpoints customizados, credenciais fake), aplicada com 'pulumi up' contra o LocalStack. Nenhuma conta AWS real nesta fase.
Mesma stack deve servir de base para sa-east-1 depois, trocando só configuração. Logs com 7 dias de retenção.")
  I2=$(mk falaai_infra task "fase-0,infra,mobile" 1 "Contas Apple Developer e Firebase; credenciais APNs e FCM" "Tarefa humana: contas de desenvolvedor, App Group, push certificates/keys, projeto Firebase. Segredos só no gerenciador de segredos.")

  dep falaai_infra "$I1" "$QI"
  echo "$E0 $J1 $QP $QC $QS $QA $QI $P1 $C1 $C2 $C3 $C4 $C5 $S1 $S2 $S3 $S4 $S5 $A1 $A2 $A3 $A4 $I1 $I2" > "$WORK/fase0-ids.txt"
  info "Fase 0: $(wc -w < "$WORK/fase0-ids.txt" | tr -d ' ') beads (IDs em $WORK/fase0-ids.txt)"
}

step_sync() {
  log "Sincronizando beads -> GitHub Issues"
  for r in "${REPOS[@]}"; do
    local rig; rig=$(field "$r" 2)
    # Só beads de trabalho viram issues; tipos internos do Gas Town (rig, agent, convoy...) ficam fora.
    local ids
    ids="$(bdr "$rig" list --all -n 0 --json 2>/dev/null | python3 -c "import json,sys
d=json.load(sys.stdin)
if isinstance(d,dict): d=d.get('issues') or []
print(','.join(i['id'] for i in d if i.get('issue_type') in ('task','epic','bug','feature','chore','decision')))")"
    if [[ -z "$ids" ]]; then info "$rig: nada para sincronizar"; continue; fi
    bdr "$rig" github sync --push-only --issues "$ids" >/dev/null && info "$rig: $(echo "$ids" | tr ',' '\n' | wc -l | tr -d ' ') beads espelhadas"
  done
}

step_convoy() {
  log "Convoy da Fase 0"
  if (cd "$GT_HOME" && gt convoy list 2>/dev/null | grep -q "FalaAí Fase 0"); then
    info "já existe"; return
  fi
  [[ -s "$WORK/fase0-ids.txt" ]] || die "rode a etapa 'seed' antes"
  # shellcheck disable=SC2046
  (cd "$GT_HOME" && gt convoy create "FalaAí Fase 0" $(cat "$WORK/fase0-ids.txt") --owned)
}

main() {
  local steps=("$@"); [[ ${#steps[@]} -eq 0 ]] && steps=(repos labels rigs settings github seed sync convoy)
  preflight
  for s in "${steps[@]}"; do "step_$s"; done
  log "Pronto. Próximo passo (manual): gt rig start <rig> e gt sling <bead> <rig>"
}
main "$@"
