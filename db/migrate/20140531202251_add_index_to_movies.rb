class AddIndexToMovies < ActiveRecord::Migration
  def change
	add_index :movies, :url, :unique => true
  end
end
