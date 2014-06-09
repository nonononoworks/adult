class GirlsController < ApplicationController
	def index
		@girls = Girl.paginate(page: params[:page], per_page: 40)
	end
end
