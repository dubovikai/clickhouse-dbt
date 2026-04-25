## 1. Start ClickHouse instance: 
```
cd clickhouse
docker compose up -d
```

- IMPORTANT For production environment:
1. Enable SSL protection for the native ClickHouse connection
- https://clickhouse.com/docs/knowledgebase/enabling-ssl-with-lets-encrypt
2. Use strong passwords (or an alternative auth way)
3. Or ask DevOps/SecOps to help if they are accessible :)

## 2. Init environment:
.env
```
CLICKHOUSE_USER=dev_user
CLICKHOUSE_PASSWORD=123
CLICKHOUSE_HOST=localhost
CLICKHOUSE_PORT=8123
```

Init Bash Script:
```
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cd dbt
```

## 3. Build dbt project:
```
dbt build
```


