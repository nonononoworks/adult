class MoviesController < ApplicationController

	def index
		@sort = sort_method(params[:sort])
		@movies = Movie.order(@sort).paginate(page: params[:page])
	    respond_to do |format|
	      format.html 
	      format.js { render 'sort.js.erb' }
	    end
	end

	def tag
		@sort = sort_method(params[:sort])
		@movies = Movie.tagged_with(params[:name]).order(@sort).paginate(page: params[:page])
	    respond_to do |format|
			format.html { render 'index' }
			format.js   { render 'sort.js.erb' }
	    end

	end

	def favourite
		@sort = sort_method(params[:sort])
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
		@sort = sort_method(params[:sort])
		@movies = Movie.search(title_cont: params[:search_string])
		@movies = @movies.result.order(@sort).paginate(page: params[:page])
	    respond_to do |format|
			format.html { render 'index' }
			format.js   { render 'sort.js.erb' }
	    end
	end

	private
		def sort_method(sort_id)
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
			return "#{sort} #{direction}"
		end
end
