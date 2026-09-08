insert into org (id, name, slug) values
  ('ddcdad3f-62c0-44e4-8ba2-cc946e66be9e', 'Nordwind Logistik GmbH', 'nordwind'),
  ('2d236b56-2b32-4274-a9d1-2d29b5d818d7', 'Pixelhaus Studio', 'pixelhaus');

insert into app_user (id, org_id, email, role) values
  ('2c05aa76-81de-4579-8ef9-833f9acf347e', 'ddcdad3f-62c0-44e4-8ba2-cc946e66be9e', 'm.weber@nordwind-logistik.de', 'admin'),
  ('16e665ec-dd44-4324-bb82-766f7f7e5495', 'ddcdad3f-62c0-44e4-8ba2-cc946e66be9e', 'julia.brandt@nordwind-logistik.de', 'editor'),
  ('1d586abc-91cd-465b-bb75-ded12b56ecff', 'ddcdad3f-62c0-44e4-8ba2-cc946e66be9e', 't.keller@nordwind-logistik.de', 'editor'),
  ('0a41a11d-811c-4b60-90ba-99373f4648a0', '2d236b56-2b32-4274-a9d1-2d29b5d818d7', 'sarah@pixelhaus.io', 'admin'),
  ('06ae3afb-59e2-47db-91b1-789456543dae', '2d236b56-2b32-4274-a9d1-2d29b5d818d7', 'omar@pixelhaus.io', 'editor');

insert into note (org_id, author_id, title, body) values
  ('ddcdad3f-62c0-44e4-8ba2-cc946e66be9e', '2c05aa76-81de-4579-8ef9-833f9acf347e', 'Warehouse audit', 'Hamburg site audit moved to the 14th. Need the pallet counts from Julia before then.'),
  ('ddcdad3f-62c0-44e4-8ba2-cc946e66be9e', '16e665ec-dd44-4324-bb82-766f7f7e5495', 'Pallet counts', 'Hall A 412, Hall B 388, Hall C still being counted. Will update tomorrow.'),
  ('ddcdad3f-62c0-44e4-8ba2-cc946e66be9e', '16e665ec-dd44-4324-bb82-766f7f7e5495', 'Driver onboarding', 'New driver starts Monday. Tachograph card not arrived yet, chase DEKRA.'),
  ('ddcdad3f-62c0-44e4-8ba2-cc946e66be9e', '1d586abc-91cd-465b-bb75-ded12b56ecff', 'Fuel card invoices', 'August invoices dont match the statement, off by 218 EUR. Asked the supplier.'),
  ('2d236b56-2b32-4274-a9d1-2d29b5d818d7', '0a41a11d-811c-4b60-90ba-99373f4648a0', 'Client feedback round 2', 'They want the hero section darker and the font one size up. Deadline unchanged.'),
  ('2d236b56-2b32-4274-a9d1-2d29b5d818d7', '06ae3afb-59e2-47db-91b1-789456543dae', 'Font licence', 'Check if the Inter licence covers the client site or only internal use.');
