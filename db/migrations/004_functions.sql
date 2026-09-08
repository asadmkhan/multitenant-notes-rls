create function notes_for_me() returns setof note
language sql stable as $$
  select * from note
  where author_id = auth.user_id()
  order by created_at desc
$$;
