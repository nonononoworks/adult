class TagsController < ApplicationController
	def index
		@tags = Movie.tag_counts_on(:tags)
	end
end
