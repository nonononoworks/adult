class MoviesController < ApplicationController

	def index
		@movies = Movie.paginate(page: params[:page])
	end

	def tag
		@movies = Movie.tagged_with(params[:name]).paginate(page: params[:page])
		
		render 'index'
	end

	def favourite
		cookies[:user_name] = '4'
		content = cookies[:local_favourite]

		if content
			cookieArray = content.split('/')
		end

		@movies = Movie.where(id: cookieArray ).paginate(page: params[:page])

		render 'index'
	end

	def find
		@movies = Movie.search(title_cont: params[:search_string])
		@movies = @movies.result.paginate(page: params[:page])
		render 'index'
	end
end
