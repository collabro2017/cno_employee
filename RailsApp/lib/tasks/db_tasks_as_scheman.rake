namespace :db do

  ['migrate', 'rollback', 'schema:load'].each do |task_name|
    desc "Run db:#{task_name} as 'scheman'"
    task "#{task_name}_as_scheman" do
      Rails.env = "scheman_#{Rails.env || 'development'}"
      Rake::Task["db:#{task_name}"].invoke
    end
  end

end

