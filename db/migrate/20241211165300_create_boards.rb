class CreateBoards < ActiveRecord::Migration[8.0]
  def change
    create_table :boards do |t|
      t.integer :generation, null: false
      t.integer :rows, null: false
      t.integer :cols, null: false
      t.binary :data, null: false

      t.timestamps
    end
  end
end
