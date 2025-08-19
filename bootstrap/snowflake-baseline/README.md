# snowflake-baseline（人手のみ）
順序通りに SQL を実行し、サービスユーザの**公開鍵**を設定します（秘密鍵は SOPS で暗号化保管）。

## 実行順
snowsql -f sql/01_roles.sql
snowsql -f sql/02_network_policy.sql
snowsql -f sql/03_resource_monitor.sql
# 公開鍵を貼ってから
snowsql -f sql/04_users_and_keys.sql
