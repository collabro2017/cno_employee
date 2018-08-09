SELECT
  "email",
	'94238c31430b34a2ac79f039b70794015ec9ed8763144f4a76cb0ddca2b324717ea2acc464c865bd70122dea228c3654b3c7ca98d67f29fea67129bc59e67a10'::varchar AS "ftp_hash",
	'41037db285d5b18fa965feee912628c8'::varchar AS "ftp_salt",
	'/var/ftp/'::char(10) || "email"::varchar(255) AS "homedir",
	'/usr/sbin/nologin'::char(17) AS "shell"
FROM "model"."users"

