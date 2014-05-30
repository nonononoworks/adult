class Movie < ActiveRecord::Base
  acts_as_taggable_on :tags, :girls
end
