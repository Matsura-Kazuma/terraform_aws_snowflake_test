package controls.evidence

# 日本語: EvidenceRecord の簡易検証（conftest 用）

deny[msg] {
  input.id == ""
  msg := "id が空です"
}

deny[msg] {
  not input.environment
  msg := "environment が未設定です（Dev/Stg/Prod/Preview）"
}

deny[msg] {
  some k
  input.hashes[k] == ""
  msg := sprintf("hashes['%s'] が空です", [k])
}
