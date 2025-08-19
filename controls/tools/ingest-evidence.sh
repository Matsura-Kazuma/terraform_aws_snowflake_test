#!/usr/bin/env bash
# ingest-evidence.sh — CI/人手で生成した証跡を登録するユーティリティ
set -euo pipefail
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <artifact_path> <environment:Dev|Stg|Prod|Preview>"
  exit 1
fi
ART="$1"; ENV="$2"
DEST="controls/evidence/samples/$(date -u +%Y-%m-%d)_$(basename "$ART")"
mkdir -p "$(dirname "$DEST")"
cp "$ART" "$DEST"
HASH="sha256:$(sha256sum "$DEST" | awk '{print $1}')"

# 簡易メタ（ EvidenceRecord の最小版 ）
REC="controls/evidence/samples/$(date -u +%Y-%m-%d)_$(basename "$ART" .txt).json"
cat > "$REC" <<JSON
{ "id":"evi-$(date -u +%Y%m%d%H%M%S)",
  "title":"artifact: $(basename "$ART")",
  "controls":["CM-2"],
  "framework":"ORG_CUSTOM_V1",
  "produced_at":"$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "produced_by":{"actor":"$(whoami)","system":"manual/ingest","run_id":null,"commit_sha":null},
  "environment":"$ENV",
  "artifacts":["$(basename "$DEST")"],
  "hashes":{"$(basename "$DEST")":"$HASH"},
  "retention_until":null,
  "notes":"",
  "review":{"status":"needs-review","reviewer":null,"reviewed_at":null}
}
JSON
echo "Saved: $DEST"
echo "Record: $REC"
