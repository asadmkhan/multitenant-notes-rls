/** Types generated for queries found in "src/queries/users.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'FindUserByEmailAndOrg' parameters type */
export interface IFindUserByEmailAndOrgParams {
  email: string;
  orgSlug: string;
}

/** 'FindUserByEmailAndOrg' return type */
export interface IFindUserByEmailAndOrgResult {
  id: string;
  org_id: string;
  role: string;
}

/** 'FindUserByEmailAndOrg' query type */
export interface IFindUserByEmailAndOrgQuery {
  params: IFindUserByEmailAndOrgParams;
  result: IFindUserByEmailAndOrgResult;
}

const findUserByEmailAndOrgIR: any = {
  usedParamSet: { email: true, orgSlug: true },
  params: [
    { name: 'email', required: true, transform: { type: 'scalar' }, locs: [{ a: 92, b: 98 }] },
    { name: 'orgSlug', required: true, transform: { type: 'scalar' }, locs: [{ a: 113, b: 121 }] },
  ],
  statement:
    'select u.id, u.org_id, u.role\nfrom app_user u\njoin org o on o.id = u.org_id\nwhere u.email = :email! and o.slug = :orgSlug!',
};

/**
 * Query generated from SQL:
 * ```
 * select u.id, u.org_id, u.role
 * from app_user u
 * join org o on o.id = u.org_id
 * where u.email = :email! and o.slug = :orgSlug!
 * ```
 */
export const findUserByEmailAndOrg = new PreparedQuery<
  IFindUserByEmailAndOrgParams,
  IFindUserByEmailAndOrgResult
>(findUserByEmailAndOrgIR);
