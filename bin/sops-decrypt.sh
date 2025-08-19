#!/usr/bin/env bash
set -euo pipefail
FILE="$1"
: "${SOPS_AGE_KEY_FILE:?SOPS_AGE_KEY_FILE を export してください}"
OUT="${FILE/.enc.tfvars/.dec.tfvars}"
sops -d "$FILE" > "$OUT"
echo "Decrypted: $OUT（削除を忘れずに）"
