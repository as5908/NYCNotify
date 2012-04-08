class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :Status_id
      t.string :Text
      t.string :Accounts_Used
      t.string :Followers_Count
      t.string :Time
      t.integer :Failures

      t.timestamps
    end
  end
end
