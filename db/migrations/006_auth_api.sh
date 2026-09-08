#!/bin/sh
set -e

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<SQL
create role auth_api login password '$AUTH_API_DB_PASSWORD';
grant usage on schema public to auth_api;
grant select on org, app_user to auth_api;

create policy org_auth_api on org for select to auth_api using (true);
create policy app_user_auth_api on app_user for select to auth_api using (true);
SQL
