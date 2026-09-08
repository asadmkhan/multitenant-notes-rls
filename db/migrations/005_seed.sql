insert into org (id, name, slug) values
  ('0c6b8a1e-3d1f-4b7a-9e2c-1a2b3c4d5e01', 'Acme Ltd', 'acme'),
  ('0c6b8a1e-3d1f-4b7a-9e2c-1a2b3c4d5e02', 'Globex Corp', 'globex');

insert into app_user (id, org_id, email, role) values
  ('7f1d2c3b-4a5e-4f60-8b7c-9d0e1f2a3b01', '0c6b8a1e-3d1f-4b7a-9e2c-1a2b3c4d5e01', 'alice@acme.test', 'admin'),
  ('7f1d2c3b-4a5e-4f60-8b7c-9d0e1f2a3b02', '0c6b8a1e-3d1f-4b7a-9e2c-1a2b3c4d5e01', 'bob@acme.test', 'editor'),
  ('7f1d2c3b-4a5e-4f60-8b7c-9d0e1f2a3b03', '0c6b8a1e-3d1f-4b7a-9e2c-1a2b3c4d5e01', 'carol@acme.test', 'editor'),
  ('7f1d2c3b-4a5e-4f60-8b7c-9d0e1f2a3b11', '0c6b8a1e-3d1f-4b7a-9e2c-1a2b3c4d5e02', 'dave@globex.test', 'admin'),
  ('7f1d2c3b-4a5e-4f60-8b7c-9d0e1f2a3b12', '0c6b8a1e-3d1f-4b7a-9e2c-1a2b3c4d5e02', 'erin@globex.test', 'editor');

insert into note (org_id, author_id, title, body) values
  ('0c6b8a1e-3d1f-4b7a-9e2c-1a2b3c4d5e01', '7f1d2c3b-4a5e-4f60-8b7c-9d0e1f2a3b01', 'Q3 planning', 'Draft the roadmap before the offsite.'),
  ('0c6b8a1e-3d1f-4b7a-9e2c-1a2b3c4d5e01', '7f1d2c3b-4a5e-4f60-8b7c-9d0e1f2a3b02', 'Onboarding checklist', 'Laptop, badge, repo access.'),
  ('0c6b8a1e-3d1f-4b7a-9e2c-1a2b3c4d5e01', '7f1d2c3b-4a5e-4f60-8b7c-9d0e1f2a3b02', 'Standup notes', 'Blocked on the API contract.'),
  ('0c6b8a1e-3d1f-4b7a-9e2c-1a2b3c4d5e01', '7f1d2c3b-4a5e-4f60-8b7c-9d0e1f2a3b03', 'Release checklist', 'Tag, changelog, announce.'),
  ('0c6b8a1e-3d1f-4b7a-9e2c-1a2b3c4d5e02', '7f1d2c3b-4a5e-4f60-8b7c-9d0e1f2a3b11', 'Vendor review', 'Compare the two quotes by Friday.'),
  ('0c6b8a1e-3d1f-4b7a-9e2c-1a2b3c4d5e02', '7f1d2c3b-4a5e-4f60-8b7c-9d0e1f2a3b12', 'Incident followup', 'Write the postmortem.');
