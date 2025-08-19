#!/usr/bin/env bash
# 日本語コメント: CI と同等の安全オプションで Terraform を実行
set -euo pipefail
export TF_IN_AUTOMATION=1
export TF_CLI_ARGS="-input=false"
export TF_CLI_ARGS_plan="-lock=true -parallelism=4"
export TF_CLI_ARGS_apply="-lock=true"

ENV="${1:-dev}"; TARGET="${2:-foundation}"; REGION="${3:-ap-northeast-1}"
STACK="stacks/${ENV}/${REGION}/${TARGET}"

terraform -chdir="$STACK" init -backend-config="$STACK/backend.hcl"
terraform -chdir="$STACK" plan -out="$STACK/tfplan.bin"
terraform -chdir="$STACK" apply -auto-approve "$STACK/tfplan.bin"
