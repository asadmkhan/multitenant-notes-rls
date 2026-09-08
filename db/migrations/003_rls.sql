create schema auth;
grant usage on schema auth to authenticated;

create function auth.org_id() returns uuid
language sql stable as $$
  select nullif(current_setting('request.jwt.claims', true)::json->>'org_id', '')::uuid
$$;

create function auth.user_id() returns uuid
language sql stable as $$
  select nullif(current_setting('request.jwt.claims', true)::json->>'sub', '')::uuid
$$;

alter table note alter column org_id set default auth.org_id();
alter table note alter column author_id set default auth.user_id();

grant usage on schema public to anon, authenticated;
grant select on org, app_user to authenticated;
grant select, insert, update on note to authenticated;
grant delete on note to admin;

alter table org enable row level security;
alter table app_user enable row level security;
alter table note enable row level security;

create policy org_select on org
  for select to authenticated
  using (id = auth.org_id());

create policy app_user_select on app_user
  for select to authenticated
  using (org_id = auth.org_id());

create policy note_select on note
  for select to authenticated
  using (org_id = auth.org_id());

create policy note_insert on note
  for insert to authenticated
  with check (org_id = auth.org_id() and author_id = auth.user_id());

create policy note_update on note
  for update to authenticated
  using (org_id = auth.org_id())
  with check (org_id = auth.org_id());

create policy note_delete on note
  for delete to admin
  using (org_id = auth.org_id());
