# multitenant notes with postgres rls

Small demo of multi tenant data isolation. All orgs share the same tables.
Postgres row level security makes sure an org only ever sees its own rows.
PostgREST exposes the tables as a REST API. A small Node service does login
and hands out JWTs.

## what is in here

- `db/migrations` schema, roles, rls policies, notes_for_me function, seed data
- `db/tests/rls.sql` rls checks that run inside postgres
- `auth-api` node service, `POST /auth/login`
- `scripts/smoke.sh` curl checks against the running stack
- `docs` design notes, pg_stat_statements and explain output

## run

    cp .env.example .env
    docker compose up -d --build

Ports: postgres 5432, postgrest 3000, auth-api 4000, swagger 8080. Change them in `.env` if they clash.

Migrations run only the first time the database volume is created. If you change
a migration, wipe and start again:

    docker compose down -v
    docker compose up -d --build

## try it in the browser

Open http://localhost:8080. The dropdown at the top right has two specs.

1. Pick `auth-api`, open `POST /auth/login`, Try it out, pick one of the examples, Execute. Copy the `token` from the response.
2. Pick `postgrest`, click Authorize, paste `Bearer <token>`, close. The word `Bearer` and the space are needed, without them postgrest ignores the header and you get a 401.
3. Now try `GET /note`, `POST /note`, `POST /rpc/notes_for_me`, `DELETE /note`.

Log in again as someone from the other org and repeat step 2 to see the rows change.

## try it with curl

Seed users. There are no passwords, login is email plus org slug.

| org | slug | admin | editors |
|---|---|---|---|
| Nordwind Logistik GmbH | nordwind | m.weber@nordwind-logistik.de | julia.brandt@nordwind-logistik.de, t.keller@nordwind-logistik.de |
| Pixelhaus Studio | pixelhaus | sarah@pixelhaus.io | omar@pixelhaus.io |

Login:

    curl -X POST localhost:4000/auth/login \
      -H 'Content-Type: application/json' \
      -d '{"email":"julia.brandt@nordwind-logistik.de","orgSlug":"nordwind"}'

Copy the token from the answer, then:

    TOKEN=...

    curl localhost:3000/note -H "Authorization: Bearer $TOKEN"

    curl -X POST localhost:3000/note -H "Authorization: Bearer $TOKEN" \
      -H 'Content-Type: application/json' -d '{"title":"hello","body":"first note"}'

    curl -X POST localhost:3000/rpc/notes_for_me -H "Authorization: Bearer $TOKEN" \
      -H 'Content-Type: application/json' -d '{}'

    curl -X DELETE "localhost:3000/note?title=eq.hello" -H "Authorization: Bearer $TOKEN"

`org_id` and `author_id` are filled in from the token, you do not need to send them.
Delete only works with an admin token, editors get a 403. Log in as
m.weber@nordwind-logistik.de to try it. Tokens last 15 minutes.

## tests

    docker compose exec -T postgres psql -U postgres -d notes -v ON_ERROR_STOP=1 < db/tests/rls.sql
    sh scripts/smoke.sh

Both print one `ok` line per check. The sql test rolls itself back and does not
touch the seed data. On Windows use Git Bash, PowerShell does not do `<`.

## debug

Logs:

    docker compose logs -f auth-api
    docker compose logs -f postgrest

Open the database:

    docker compose exec postgres psql -U postgres -d notes

To see exactly what a user sees, pretend to be them in psql:

    set role editor;
    select set_config('request.jwt.claims', '{"sub":"<user id>","org_id":"<org id>","role":"editor"}', true);
    select * from note;

Query stats:

    select calls, round(mean_exec_time::numeric, 2) ms, left(query, 80)
    from extensions.pg_stat_statements order by total_exec_time desc limit 10;

## common problems

401 "No suitable key or wrong key type". PostgREST and auth-api have a different
`JWT_SECRET`, or it is shorter than 32 chars. Both read the same `.env`, so this
usually means one container is stale. `docker compose up -d --build`.

401 "permission denied for table note". No token, or an expired one.

403 "new row violates row-level security policy". You sent an `org_id` that is not
yours. Leave it out.

postgrest restarts in a loop. The `authenticator` role is missing, which means the
migrations did not run. `docker compose down -v` and start again.

Port already in use. Change `POSTGRES_PORT`, `PGRST_PORT` or `AUTH_API_PORT` in `.env`.

Changed a migration but nothing happened. Migrations only run on a fresh volume.

## working on auth-api

    cd auth-api
    npm install
    export DATABASE_URL=postgres://auth_api:auth_api@localhost:5432/notes
    export JWT_SECRET=<same value as in .env>
    npm run dev

`npm run typecheck`, `npm run lint` and `npm run format` do what they say.

Queries live in `src/queries/*.sql`. After changing one, run `npm run pgtyped`
against a running database to regenerate the `.queries.ts` file next to it.
