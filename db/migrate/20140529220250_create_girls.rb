class CreateGirls < ActiveRecord::Migration
  def change
    create_table :girls do |t|
      t.string :name
      t.string :name_hira
      t.string :name_alpha
      t.datetime :birthday
      t.integer :tall
      t.integer :bust
      t.integer :west
      t.integer :hip
      t.string :hometown
      t.string :image_path

      t.timestamps
    end
  end
end
