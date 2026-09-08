create table org (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  created_at timestamptz not null default now()
);

create table app_user (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references org(id) on delete cascade,
  email text not null,
  role text not null check (role in ('admin', 'editor')),
  created_at timestamptz not null default now(),
  unique (org_id, email),
  unique (id, org_id)
);

create table note (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references org(id) on delete cascade,
  author_id uuid not null,
  title text not null,
  body text not null default '',
  created_at timestamptz not null default now(),
  foreign key (author_id, org_id) references app_user(id, org_id)
);

create index note_org_id_idx on note (org_id);
create index note_author_id_idx on note (author_id);
