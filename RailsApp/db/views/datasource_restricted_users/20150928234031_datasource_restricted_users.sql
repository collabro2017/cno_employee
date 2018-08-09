SELECT "datasources"."id" AS "datasource_id", "users"."id" AS "user_id"
  FROM "datasource_restricted_companies"
  INNER JOIN "datasources"
    ON "datasources"."id" = "datasource_restricted_companies"."datasource_id"
  INNER JOIN "users"  
    ON "users"."company_id" = "datasource_restricted_companies"."company_id"
  WHERE datasources.access_level = 'restricted'
UNION
SELECT "datasources"."id" AS "datasource_id", "users"."id" AS "user_id"
  FROM "datasources"
  CROSS JOIN "users"
  WHERE "datasources"."access_level" = 'open';