class MoviesController < ApplicationController

	before_action :sort_method, :list_method, :current_url

	def index
		@movies = Movie.order(@sort).paginate(page: params[:page])
	    respond_to do |format|
	      format.html 
	      format.js { render 'sort.js.erb' }
	    end
	end

	def tag
		@name = params[:name]
		@movies = Movie.tagged_with(params[:name]).order(@sort).paginate(page: params[:page])
	    respond_to do |format|
			format.html { render 'index' }
			format.js   { render 'sort.js.erb' }
	    end

	end

	def favourite
		cookies[:user_name] = '4'
		content = cookies[:local_favourite]

		if content
			cookieArray = content.split('/')
		end

		@movies = Movie.where(id: cookieArray ).order(@sort).paginate(page: params[:page])

	    respond_to do |format|
			format.html { render 'index' }
			format.js   { render 'sort.js.erb' }
	    end
	end

	def find
		@movies = Movie.search(title_cont: params[:search_string])
		@movies = @movies.result.order(@sort).paginate(page: params[:page])
	    respond_to do |format|
			format.html { render 'index' }
			format.js   { render 'sort.js.erb' }
	    end
	end

	private
		def current_url
			@current = request.url
		end
		def list_method
			if params[:listtype].blank?
				if session[:listtype].blank?
					@listtype = 'og-grid'
				else
					@listtype = session[:listtype]
				end
			else
				session[:listtype] = params[:listtype]
				@listtype = params[:listtype]
			end
		end
		def sort_method

			if params[:sort].blank?
				sort_id = session[:sort]
			else
				session[:sort] = params[:sort]
				sort_id = params[:sort]
			end

			@selected = sort_id
			if sort_id.nil?
				sort = 'id'
				direction = 'asc'
				selected = 1
			else
				sort_num = sort_id.to_i
				if sort_num >= 10
					sort_num -= 10;
					direction = 'desc'
				else
					direction = 'asc'
				end
				case sort_num
					when 1 then
						sort = 'created_at'
					when 2 then
						sort = 'plays'
					when 3 then
						sort = 'title'
				end
			end
			@sort = "#{sort} #{direction}"
		end
end
