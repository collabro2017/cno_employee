json.array!(@jobs) do |job|
  json.extract! job, :type, :count_id, :count__result, :status, :sql
  json.url job_url(job, format: :json)
end