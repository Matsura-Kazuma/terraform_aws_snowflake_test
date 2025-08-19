#!/usr/bin/env bash
set -euo pipefail
aws iam get-role --role-name gha-plan-Dev >/dev/null && echo ok
aws iam get-role --role-name gha-apply-Dev >/dev/null && echo ok
