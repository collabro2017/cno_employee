class CreateCountSummaries < ActiveRecord::Migration
  def up
    create_view :count_summaries, load_sql(20140821153743, 'count_summaries')
  end

  def down
    drop_view :count_summaries
  end
end

