class AddColumnsToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :embed, :string
  end
end
