class MoviesController < ApplicationController

	def index
		@movies = Movie.paginate(page: params[:page])
	end

	def show
	end
end
