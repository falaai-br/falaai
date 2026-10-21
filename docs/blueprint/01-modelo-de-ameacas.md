# 01 — Modelo de ameaças

Este documento é público. Ele diz com franqueza contra quem o FalaAí protege e contra quem não protege.

## Ativos

| Ativo | Onde vive | Sensibilidade |
|---|---|---|
| Conteúdo de mensagens, mídia e chamadas | Só nos aparelhos (cifrado em trânsito e no servidor) | Máxima |
| Chaves privadas de identidade e sessão | Só nos aparelhos (banco SQLCipher, chave no Keychain/Keystore) | Máxima |
| Grafo social (quem fala com quem) | Não deve existir em lugar nenhum | Alta |
| Número de telefone | Servidor, como HMAC + cifrado | Alta |
| Registros de acesso (IP + data/hora) | Servidor, 6 meses (obrigação legal) | Média |
| Lista de membros de grupos | Servidor (UUIDs opacos) no MVP | Média |

## Adversários

| Adversário | Protegemos | NÃO protegemos |
|---|---|---|
| **Rede, ISP ou Estado observando o tráfego** | Conteúdo (E2EE); remetente oculto do servidor (sealed sender); TLS 1.3 com certificate pinning | Padrões de tráfego, IP do usuário, horários, tamanho aproximado de pacotes em chamadas |
| **Servidor comprometido (invasão)** | Conteúdo, mídia e chaves privadas | Metadados operacionais existentes no momento (fila de entrega, membros de grupos, registros de acesso) |
| **Insider malicioso na empresa** | O mesmo que acima; acessos administrativos auditados e com break-glass | Um insider com acesso de deploy poderia publicar um app malicioso. Mitigação: cliente aberto, builds reproduzíveis e, na fase 2, key transparency |
| **Apreensão do aparelho bloqueado** | Banco local cifrado com chave em hardware (Secure Enclave/StrongBox) | Ataques forenses contra aparelhos sem atualização de segurança |
| **Apreensão do aparelho desbloqueado** | Bloqueio opcional do app por biometria/PIN; mensagens efêmeras | Tudo o que estiver visível ou acessível no aparelho |
| **SIM swap / sequestro do número** | PIN de registro impede registrar a conta em outro aparelho; contatos recebem alerta de mudança de safety number | Usuário sem PIN configurado pode ter a identidade personificada até que os contatos vejam o alerta. O histórico nunca vaza |
| **Coerção legal sobre a empresa** | Conteúdo: não temos as chaves. Metadados: guardamos o mínimo, por pouco tempo | O que a lei manda guardar (registros de acesso) será entregue mediante ordem judicial válida |
| **Spyware no aparelho (tipo Pegasus)** | Nada | Nada. Nenhum mensageiro protege um aparelho comprometido |
| **Spam e abuso** | Rate limiting, Play Integrity/App Attest, pedidos de mensagem de desconhecidos, denúncia pelo destinatário | Não lemos conteúdo para moderar. Denúncia depende do destinatário |

## Premissas

- O sistema operacional do aparelho e o hardware de chaves são confiáveis enquanto atualizados.
- A `libsignal` está correta. Nós a pinamos por commit e acompanhamos avisos de segurança.
- O usuário verifica safety numbers quando a conversa é sensível. O app incentiva, mas não obriga.

## Riscos residuais aceitos no MVP

1. **Membros de grupo visíveis ao servidor.** Resolvido com zkgroup em fase posterior.
2. **Sem key transparency.** Um servidor malicioso poderia tentar trocar chaves públicas; o alerta de mudança de safety number é a defesa no MVP.
3. **Chamadas em grupo expõem ao SFU quem está na chamada e quando.** O conteúdo de áudio e vídeo segue cifrado por frame.
4. **Hospedagem em provedor americano (AWS sa-east-1)** sujeito ao CLOUD Act. Só metadados estão em jogo; o conteúdo é ciphertext.
