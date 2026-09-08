# design decisions

Short notes on the choices in this repo and why I made them.

## 1. shared tables with org_id, not a schema per org

Every table has an `org_id` and rls policies filter on it. The other option is
one schema per org. That gives stronger separation but migrations, connection
pooling and PostgREST config all get harder with every new org. For a notes app
with many small orgs, shared tables plus rls is the simpler thing to run, and
Postgres enforces the filter so app code cannot forget it.

## 2. postgres enforces isolation, the app does not

There is no `where org_id = ?` anywhere in application code. Policies add it.
This means a bug in auth-api or a hand written PostgREST query still cannot leak
rows from another org. The tests in `db/tests/rls.sql` check the policies
directly, without going through http.

## 3. jwt role claim maps to a real database role

PostgREST does `set role` to whatever the `role` claim says. So `admin` and
`editor` are actual postgres roles. Both inherit from `authenticated`, which
holds the shared grants. Only `admin` has the delete grant on `note`. This gives
two independent checks: grants say what a role may do at all, policies say which
rows. An editor cannot delete even if a policy were wrong.

## 4. org_id and author_id default from the jwt

Both columns on `note` default to values read from the token. A client only
sends title and body. If it does send an `org_id`, the insert policy still
compares it to the token, so lying does not help.

## 5. the login service gets its own low power db role

`auth_api` can select from `org` and `app_user` and nothing else. It has no
access to `note`. If the login service is compromised the attacker can list
users but cannot read or change notes.

## 6. login has no password

The task defines login as email plus org slug and says nothing about passwords,
so there are none. In a real system this endpoint would sit behind a password
check or an identity provider. Everything after the token is issued would stay
the same.

## 7. slug column on org

The task's table list does not have it, but login takes an `orgSlug`, so there
has to be something to look up by. A short unique text column is the obvious fit.

## 8. composite foreign key on note

`note(author_id, org_id)` references `app_user(id, org_id)`. A plain foreign key
on `author_id` would allow a note in org A written by a user from org B. The pair
makes that impossible at the constraint level, before rls is even involved.

## 9. hs256 with one shared secret

PostgREST and auth-api share `JWT_SECRET`. Simple and enough for two services in
one compose file. With more consumers I would switch to RS256 so only auth-api
holds the private key.

## 10. migrations through docker-entrypoint-initdb.d

Plain sql and sh files that postgres runs on first start, in name order. No
migration tool to install. The cost is that changing a migration means wiping the
volume. Fine for a demo, not what I would do for a long lived database.

## 11. zod for input, pgtyped for queries

Zod checks the login body before anything else runs. pgTyped reads the `.sql`
file, checks it against the real database and generates the parameter and result
types. Parameters are always bound, never concatenated.
