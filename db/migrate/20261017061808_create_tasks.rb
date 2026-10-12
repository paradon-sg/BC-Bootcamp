class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true

      t.string  :title,      null: false
      t.integer :status,     default: 0
      t.text    :description

      t.timestamps
    end
  end
end
