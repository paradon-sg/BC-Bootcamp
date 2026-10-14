class DropUsersAndUserProjects < ActiveRecord::Migration[8.1]
  def change
    drop_table :user_projects do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.timestamps
      t.index [ :user_id, :project_id ], unique: true
    end

    drop_table :users do |t|
      t.string :email
      t.timestamps
      t.index :email, unique: true
    end
  end
end
