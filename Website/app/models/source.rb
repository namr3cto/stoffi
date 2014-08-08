class Source < ActiveRecord::Base
	belongs_to :resource, :polymorphic => true
	
	def self.parse_path(path)
		raise 'path cannot be nil' unless path
		begin
		if path.start_with? 'stoffi:'
			parts = path.split(':', 4)
			{
				resource: parts[1].to_sym,
				source: parts[2].to_sym,
				id: parts[3],
			}
		elsif path.start_with? 'http://' or path.start_with? 'https://'
			{ source: :url, id: path }
		else
			{ source: :local, id: path }
		end
		rescue
			raise path
		end
	end
	
	def self.get_by_path(path)
		begin
			path = parse_path(path) if path.is_a? String
			find_or_create_by(name: path[:source], foreign_id: path[:id])
			
		rescue StandardError => e
			raise e
			logger.error "could not get source from path: #{e.message}"
		end
	end
end
