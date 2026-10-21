#!/usr/bin/env python3
"""Falha se algum link relativo em arquivos Markdown apontar para arquivo inexistente."""
import glob
import os
import re
import sys

IGNORAR = ("graft/", "scripts/bootstrap/templates/", "node_modules/")
LINK = re.compile(r"\]\(([^)#\s]+)(#[^)]*)?\)")

quebrados = []
for arquivo in glob.glob("**/*.md", recursive=True):
    if arquivo.startswith(IGNORAR):
        continue
    with open(arquivo, encoding="utf-8") as f:
        texto = f.read()
    for m in LINK.finditer(texto):
        alvo = m.group(1)
        if alvo.startswith(("http://", "https://", "mailto:")):
            continue
        caminho = os.path.normpath(os.path.join(os.path.dirname(arquivo), alvo))
        if not os.path.exists(caminho):
            quebrados.append(f"{arquivo}: {alvo}")

for q in quebrados:
    print(f"link quebrado: {q}")
print(f"{len(quebrados)} link(s) quebrado(s)")
sys.exit(1 if quebrados else 0)
