+-------------------------+
| Tested on:              |
| CentOS 7.3 / RedHat 7.3 |
| Zabbix 2.4.8 / 3.0 LTS  |
| PostgreSQL 9.6          |
+-------------------------+

Olá. Andre aqui. Eu não sou muito bom no PostgreSQL. Se fiz algo errado, por favor me ajude a consertar.

Este template é baseado no pgCayenne by Lesovsky Alexey, mas eu o atualizei para trabalhar no PostgreSQL 9.6 e adicionei alguns novos itens.

Você pode encontrar pgCayenne original aqui:
https://github.com/lesovsky/zabbix-extensions/tree/master/files/postgresql


+------------+
| HOW TO USE |
+------------+
1) Instale os requisitos:
Você precisará do pacote "contrib".
  # yum install postgresql96-contrib.x86_64

Os seguintes módulos serão instalados pelo pacote contrib:
- pg_buffercache
- pg_stat_statements

2) Crie as extensões:
Buffers:
  No terminal Postgres, crie a extensão "pg_buffercache":
  postgres=# CREATE EXTENSION pg_buffercache;
  CREATE EXTENSION
  Nota: Você deve criar a extensão para seu próprio banco de dados. Exemplo:
  postgres=# \c zabbix
  Agora você está conectado ao banco de dados "zabbix" como usuário "postgres".
  zabbix=# create extension pg_buffercache;
  CREATE EXTENSION
  zabbix=# 

Afirmações:
  No terminal Postgres, crie a extensão "pg_stat_statements":
  postgres=# create extension pg_stat_statements;
  CREATE EXTENSION
  postgres=# \c zabbix
  You are now connected to database "zabbix" as user "postgres".
  zabbix=# create extension pg_stat_statements;
  CREATE EXTENSION

3) Ativar biblioteca pg_stat_statements:
# vi  postgresql.conf
  shared_preload_libraries = 'pg_stat_statements'
  pg_stat_statements.max = 10000
  pg_stat_statements.track = all

4) Permitir acesso de confiança local ao PostgreSQL:
  # vi /data/postgresql/data/pg_hba.conf
  host    all             postgres        127.0.0.1/32            trust

5) Reinicie os serviços para que as alterações entrem em vigor:
  # systemctl restart postgresql-9.6.service

6) Verifique se você pode obter alguns dados:
  # zabbix_get -s 172.16.240.9 -k pgsql.ping['-h 127.0.0.1 -p 5432 -U postgres -d postgres']
    Note: Change the IP "172.16.240.9" for the Zabbix Proxy that will query.
    Or
  # zabbix_get -s 127.0.0.1 -k pgsql.ping['-h 127.0.0.1 -p 5432 -U postgres -d zabbix']

Nota: O IP do host local deve ser permitido no Agente Zabbix. Exemplo:
  Server=myzabbixserver.mydomain.com,127.0.0.1
  ServerActive=myzabbixserver.mydomain.com,127.0.0.1

7) Coloque o arquivo "userparameter_postgres.conf" no seu diretório "/etc/zabbix/zabbix.d" e reinicie o agente.
  # cp userparameter_postgres.conf /etc/zabbix/zabbix.d/
  # systemctl restart zabbix-agent

8) Importe o modelo no seu servidor Zabbix

9) Associate the template "Postgres Simple Monitor" to the monitored host.

10) Define the Host Macros:
{$PG_CACHE_HIT_RATIO} = 90
{$PG_CHECKPOINTS_REQ_THRESHOLD} = 5
{$PG_CONFLICTS_THRESHOLD} = 0
{$PG_CONNINFO} = -h 127.0.0.1 -p 5432 -U postgres -d zabbix
{$PG_CONNINFO_STANDBY} = -p 5432 -U postgres -d zabbix
{$PG_CONN_IDLE_IN_TRANSACTION} = 3
{$PG_CONN_TOTAL_PCT} = 90
{$PG_CONN_WAITING} = 0
{$PG_DATABASE_SIZE_THRESHOLD} = 100000000000
{$PG_DEADLOCKS_THRESHOLD} = 0
{$PG_LONG_QUERY_THRESHOLD} = 30
{$PG_PING_THRESHOLD_MS} = 1000
{$PG_PROCESS_NAME} = postgres
{$PG_SR_LAG_BYTE} = 50000000
{$PG_SR_LAG_SEC} = 600
{$PG_SR_PACKET_LOSS} = 10
{$PG_UPTIME_THRESHOLD} = 600

Descrição dos itens:
PG_CONNINFO_STANDBY: Configurações de conexão para as conexões do agente zabbix com o serviço postgres em servidores em espera, necessárias para o monitoramento de latência de replicação de fluxo contínuo;
PG_CACHE_HIT_RATIO: taxa de cache de buffers compartilhados;
PG_CONN_TOTAL_PCT: A porcentagem do número total de conexões para o máximo permitido (max_connections);

Definições de limite:
PG_CHECKPOINTS_REQ_THRESHOLD: limite para pontos de verificação que ocorreram por demanda;
PG_CONFLICTS_THRESHOLD: o limite para conflitos de recuperação é acionado;
PG_CONN_IDLE_IN_TRANSACTION: Limite para conexões que estão inativas no estado da transação;
PG_CONN_WAITING: Limite para conexões que estão no estado de espera;
PG_DATABASE_SIZE_THRESHOLD: limite para o tamanho do banco de dados;
PG_DEADLOCKS_THRESHOLD: o limite para o acionamento de conflitos de deadlock;
PG_LONG_QUERY_THRESHOLD: limite para o acionamento de transações longas;
PG_PING_THRESHOLD_MS: limite para resposta do serviço postgres;
PG_SR_LAG_BYTE: limite em bytes para o atraso de replicação de fluxo entre o servidor e os servidores em espera detectados;
PG_SR_LAG_SEC: Limite em segundos para o atraso de replicação de fluxo entre o servidor e os servidores em espera descobertos;
PG_UPTIME_THRESHOLD: limite para o tempo de atividade do serviço.

11) Aguarde alguns minutos e os dados aparecerão. Alguns itens requerem uma hora extra.


+-----------------+
| MONITORED ITENS |
+-----------------+

Background Writer (10 Items)
•	buffers allocated
•	buffers written by the bgwriter
•	buffers written directly by a backend
•	buffers written during checkpoints
•	checkpoints by timeout
•	max written
•	required checkpoints
•	sync time
•	times a backend had to execute its own fsync
•	write time

Buffers & Caches (5 Items)
•	cache hit ratio
•	clear buffers
•	dirty buffers
•	total buffers
•	used buffers

Configuration (3 Items)
•	fsync
•	full_page_writes
•	synchronous_commit

Connections (8 Items)
•	number of active connections
•	number of idle connections
•	number of idle in transaction connections
•	number of prepared connections
•	number of waiting connections
•	ping
•	total connections
•	total connections (%)

Databases (1 Item)
•	database zabbix size

Database Status (13 Items)
•	blocks hit per second
•	blocks read per second
•	commits per second
•	registered conflicts
•	registered deadlocks
•	rollbacks per second
•	temp_bytes written
•	temp_files created
•	tuples deleted per second
•	tuples fetched per second
•	tuples inserted per second
•	tuples returned per second
•	tuples updated per second

General Information (3 Items)
•	number of running processes postmaster
•	postgresql version
•	service uptime

Operations (1 Item)
•	pg_stat_statements: average query time

Streaming Replication (2 Items)
•	recovery state
•	stand-by count

Table Info (25 Items)
•	table public.sessions indexes size
•	table public.sessions rows count
•	table public.sessions size
•	table public.sessions stat: analyzes
•	table public.sessions stat: autoanalyzes
•	table public.sessions stat: autovacuums
•	table public.sessions stat: cache blocks hits per second
•	table public.sessions stat: cache blocks read per second
•	table public.sessions stat: dead rows
•	table public.sessions stat: disk blocks hits per second from TOAST
•	table public.sessions stat: disk blocks hits per second from TOAST indexes
•	table public.sessions stat: disk blocks read per second from TOAST
•	table public.sessions stat: disk blocks read per second from TOAST indexes
•	table public.sessions stat: index blocks hit per second
•	table public.sessions stat: index blocks read per second
•	table public.sessions stat: index scans
•	table public.sessions stat: live rows
•	table public.sessions stat: rows deleted per second
•	table public.sessions stat: rows HOT updated per second
•	table public.sessions stat: rows inserted per second
•	table public.sessions stat: rows updated per second
•	table public.sessions stat: sequential scans
•	table public.sessions stat: tuples read per second by index scans
•	table public.sessions stat: tuples read per second by sequential scans
•	table public.sessions stat: vacuums

Transactions (4 Items)
•	current max active transaction time
•	current max idle transaction time
•	current max prepared transaction time
•	current max waiting transaction time

Write-Ahead Logging (2 Items)
•	WAL segments count
•	WAL write



Bonus:

+--------------------------+
| Useful commands/packages |
+--------------------------+

CPU and Disk Access:
pg_stat_kcache96.x86_64

Performance:
pg_activity.noarch
pgcenter.x86_64
pgcluu.noarch
pg_top.x86_64
pg_top96.x86_64

Statistics:
pg_qualstats96.x86_64

Backup:
pgbackman.noarch
pgbackrest.noarch

Tunning:
pgtune.noarch

Info:
pg_view.noarch