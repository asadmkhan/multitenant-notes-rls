-- run with:
--   docker compose exec -T postgres psql -U postgres -d notes -v ON_ERROR_STOP=1 < db/tests/rls.sql
-- everything is rolled back at the end, the seed data is not touched

begin;

insert into org (id, name, slug) values
  ('a0000000-0000-4000-8000-000000000001', 'rls test a', 'rls-test-a'),
  ('b0000000-0000-4000-8000-000000000001', 'rls test b', 'rls-test-b');

insert into app_user (id, org_id, email, role) values
  ('a0000000-0000-4000-8000-0000000000a1', 'a0000000-0000-4000-8000-000000000001', 'admin@a.test', 'admin'),
  ('a0000000-0000-4000-8000-0000000000a2', 'a0000000-0000-4000-8000-000000000001', 'editor@a.test', 'editor'),
  ('b0000000-0000-4000-8000-0000000000b1', 'b0000000-0000-4000-8000-000000000001', 'admin@b.test', 'admin');

insert into note (org_id, author_id, title) values
  ('a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-0000000000a1', 'rls a1'),
  ('a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-0000000000a2', 'rls a2'),
  ('b0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-0000000000b1', 'rls b1');

-- editor in org a
set local role editor;
select set_config('request.jwt.claims',
  '{"sub":"a0000000-0000-4000-8000-0000000000a2","org_id":"a0000000-0000-4000-8000-000000000001","role":"editor"}', true);

do $$
begin
  assert (select count(*) from note where title like 'rls %') = 2, 'editor should see 2 notes';
  assert (select count(*) from note where org_id = 'b0000000-0000-4000-8000-000000000001') = 0, 'editor must not see org b';
  assert (select count(*) from app_user where email like '%.test') = 2, 'editor should see 2 users';
  assert (select count(*) from org where slug like 'rls-test-%') = 1, 'editor should see 1 org';
  raise notice 'ok  editor sees only own org';

  assert (select count(*) from notes_for_me()) = 1, 'notes_for_me should return 1';
  raise notice 'ok  notes_for_me returns own notes only';
end $$;

do $$
declare n note;
begin
  insert into note (title) values ('rls a3') returning * into n;
  assert n.org_id = 'a0000000-0000-4000-8000-000000000001', 'org_id should default from jwt';
  assert n.author_id = 'a0000000-0000-4000-8000-0000000000a2', 'author_id should default from jwt';
  raise notice 'ok  insert fills org_id and author_id from jwt';
end $$;

do $$
begin
  insert into note (org_id, author_id, title)
  values ('b0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-0000000000b1', 'sneaky');
  raise exception 'editor inserted into another org';
exception when insufficient_privilege then
  raise notice 'ok  insert into another org is rejected';
end $$;

do $$
begin
  delete from note where title = 'rls a1';
  raise exception 'editor was able to delete';
exception when insufficient_privilege then
  raise notice 'ok  editor cannot delete';
end $$;

-- admin in org a
reset role;
set local role admin;
select set_config('request.jwt.claims',
  '{"sub":"a0000000-0000-4000-8000-0000000000a1","org_id":"a0000000-0000-4000-8000-000000000001","role":"admin"}', true);

do $$
declare deleted int;
begin
  delete from note where title = 'rls a1';
  get diagnostics deleted = row_count;
  assert deleted = 1, 'admin should delete own org note';

  delete from note where title = 'rls b1';
  get diagnostics deleted = row_count;
  assert deleted = 0, 'admin must not delete other org note';
  raise notice 'ok  admin deletes only inside own org';
end $$;

-- no token
reset role;
set local role anon;

do $$
begin
  perform count(*) from note;
  raise exception 'anon could read notes';
exception when insufficient_privilege then
  raise notice 'ok  anon has no access';
end $$;

-- the login service role
reset role;
set local role auth_api;

do $$
begin
  assert (select count(*) from app_user where email like '%.test') = 3, 'auth_api should see all users';
  raise notice 'ok  auth_api reads users across orgs';
end $$;

do $$
begin
  perform count(*) from note;
  raise exception 'auth_api could read notes';
exception when insufficient_privilege then
  raise notice 'ok  auth_api cannot read notes';
end $$;

rollback;
