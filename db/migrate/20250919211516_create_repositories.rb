class CreateRepositories < ActiveRecord::Migration[7.0]
  def change
    create_table :repositories do |t|
      t.string :repository_id
      t.string :name
      t.datetime :last_updated_at
      t.timestamps
    end
  end
end
