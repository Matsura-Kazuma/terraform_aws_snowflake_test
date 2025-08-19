#!/usr/bin/env bash
# 日本語コメント: 復号後は必ず削除すること
set -euo pipefail
if [[ $# -ne 1 ]]; then echo "Usage: $0 <path/to/secrets.enc.tfvars>"; exit 1; fi
: "${SOPS_AGE_KEY_FILE:?export SOPS_AGE_KEY_FILE を設定してください}"
IN="$1"; OUT="${IN/.enc.tfvars/.dec.tfvars}"
sops -d "$IN" > "$OUT"
echo "Decrypted: $OUT（作業後に削除してください）"
