/* @name findUserByEmailAndOrg */
select u.id, u.org_id, u.role
from app_user u
join org o on o.id = u.org_id
where u.email = :email! and o.slug = :orgSlug!;
