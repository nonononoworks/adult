class CreateTranslateTags < ActiveRecord::Migration
  def change
    create_table :translate_tags do |t|
      t.string :english
      t.string :japanese

      t.timestamps
    end
  end
end
