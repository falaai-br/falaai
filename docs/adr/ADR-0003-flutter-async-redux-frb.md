# ADR-0003 — Flutter com Async Redux e flutter_rust_bridge

- **Status:** aceita
- **Data:** 2026-10-21

## Contexto

Precisamos de iOS e Android com time pequeno. O time tem experiência em Flutter com Async Redux. O núcleo está em Rust.

## Decisão

App em Flutter, estado em **Async Redux**, navegação `go_router`, ponte **flutter_rust_bridge 2.x** com Native Assets (fallback xcframework estático para o NSE do iOS). Chamadas com `flutter_webrtc` e SDK LiveKit.

## Consequências

- Uma base de UI para as duas plataformas.
- Partes nativas inevitáveis: Notification Service Extension (Swift), CallKit/PushKit, ConnectionService.
- Riverpod/Bloc só com nova ADR.
