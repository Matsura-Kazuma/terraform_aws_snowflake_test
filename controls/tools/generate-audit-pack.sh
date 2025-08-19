#!/usr/bin/env bash
# generate-audit-pack.sh — 監査用パックを生成
set -euo pipefail
OUT="audit-pack_$(date -u +%Y%m%d).tar.gz"
tar -czf "$OUT" controls/mappings controls/procedures controls/tests controls/evidence/samples
echo "Generated $OUT"
