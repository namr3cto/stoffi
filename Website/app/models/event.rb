class Event < ActiveRecord::Base
	has_and_belongs_to_many :artists, join_table: :performances
end
