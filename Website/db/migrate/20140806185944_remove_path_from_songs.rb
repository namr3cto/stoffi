class RemovePathFromSongs < ActiveRecord::Migration
  def change
	Song.all.each do |s|
		begin
			next if s.path.to_s.empty?
			if s.path.start_with? 'stoffi:track:youtube:'
				id = s.path[21..-1]
				name = 'youtube'
				
			elsif s.path.start_with? 'stoffi:track:soundcloud:'
				id = s.path[24..-1]
				name = 'soundcloud'
				
			elsif s.path.start_with? 'stoffi:track:jamendo:'
				id = s.path[21..-1]
				name = 'jamendo'
				
			else
				id = s.path
				name = 'local'
			end
			
			src = Source.new
			src.resource = s
			src.name = name
			src.foreign_id = id
			src.foreign_url = s.foreign_url
			
		rescue
		end
			
	end
    remove_column :songs, :path, :string
    remove_column :songs, :path, :string
  end
end
