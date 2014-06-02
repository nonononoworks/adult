class AddColumns2ToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :title, :string
    add_column :movies, :image_path, :string
    add_column :movies, :plays, :integer
  end
end
