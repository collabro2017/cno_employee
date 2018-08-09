class AlterCountSummaries < ActiveRecord::Migration
  def up
    drop_view :count_summaries
    create_view :count_summaries, load_sql(20150701182832, 'count_summaries')
  end

  def down
    drop_view :count_summaries
    create_view :count_summaries, load_sql(20140821153743, 'count_summaries')
  end
end

