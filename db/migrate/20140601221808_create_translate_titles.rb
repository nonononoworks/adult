class CreateTranslateTitles < ActiveRecord::Migration
  def change
    create_table :translate_titles do |t|
      t.string :english
      t.string :japanese

      t.timestamps
    end
  end
end
