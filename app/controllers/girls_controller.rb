class GirlsController < ApplicationController
	def index
		@girls = Girl.paginate(page: params[:page])
	end
end
