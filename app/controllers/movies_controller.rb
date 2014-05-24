class MoviesController < ApplicationController

	def index
		@movies = Movie.paginate(page: params[:page])
	end

	def tag
		@movies = Movie.tagged_with(params[:name]).paginate(page: params[:page])
		
		render 'index'
	end

	def show
	end
end
