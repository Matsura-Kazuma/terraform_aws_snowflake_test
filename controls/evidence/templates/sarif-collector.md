# SARIF 収集手順
- Trivy/Checkov/gitleaks 等の SARIF を `controls/evidence/samples/` に保存
- 大容量は artifact とし、ここには **メタデータ（ハッシュ/場所）** のみ残す
