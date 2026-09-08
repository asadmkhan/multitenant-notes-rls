#!/bin/sh
set -e

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<SQL
create role anon nologin;
create role authenticated nologin;
create role admin nologin in role authenticated;
create role editor nologin in role authenticated;

create role authenticator noinherit login password '$AUTHENTICATOR_PASSWORD';
grant anon, admin, editor to authenticator;
SQL
