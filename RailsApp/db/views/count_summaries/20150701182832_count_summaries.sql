SELECT
  "id",
  "count_id",
  "user_name",
  "datasource_name",
  "most_recent_job_id",
  "most_recent_job_status",
  "most_recent_job_updated_at"
FROM (
  SELECT
    "counts"."id" AS "id",
    "counts"."id" AS "count_id",
    "users"."first_name" || ' ' || "users"."last_name" AS "user_name",
    "datasources"."name" AS "datasource_name",
    "jobs"."id" AS "most_recent_job_id",
    "jobs"."status" AS "most_recent_job_status",
    "jobs"."updated_at" AS "most_recent_job_updated_at",
    rank() OVER (
      PARTITION BY "jobs"."count_id" ORDER BY "jobs"."updated_at" DESC
      )
  FROM "counts"
  INNER JOIN "users" ON "counts"."user_id" = "users"."id"
  INNER JOIN "datasources" ON "counts"."datasource_id" = "datasources"."id"
  LEFT JOIN "jobs" ON "counts"."id" = "jobs"."count_id"
  ) AS tmp
WHERE tmp.rank = 1
