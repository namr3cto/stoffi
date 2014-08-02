# -*- encoding : utf-8 -*-
# The model of a Wikipedia link to a resource.
#
# The model contains methods for fetching links and
# extracting information from pages.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2014 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

require 'wikipedia'

# Describes a link to wikipedia for a resource
class WikipediaLink < ActiveRecord::Base
	belongs_to :resource, polymorphic: true
	
	# A brief summary of the page followed by some highlighted data
	def self.summary(page)
		return {} unless page and page.content
		
		retval = { intro: nil, info: nil }
		
		begin
			retval[:intro] = get_first_sentence(page)
		rescue Exception => e
			logger.error "error extracting first sentence from wikipedia content: #{e.message}"
		end
		
		# parse infobox
		begin
			box = extract_infobox(page.content)
			fields = box.split("\n|")
			return {} unless fields.length > 2
			retval[:info] = {}
			fields[1..-1].each do |field|
			
				begin
					# split into key and value pair
					pair = field.split(' = ')
					next if pair.length < 2
					key = pair[0].strip
					next if key == 'module'
					value = pair[1].strip
			
					# check for some special template formats
					try_date = parse_date(value)
					try_list = parse_list(value)
					try_marriage = parse_marriage(value)
			
					# date templates
					if try_date
						value = try_date.to_s
			
					# list templates
					elsif try_list
						value = try_list.join('<br/>')
				
					# marriage templates
					elsif try_marriage
						value = "#{try_marriage[:name]}"
						if try_marriage[:start_date]
							range = try_marriage[:start_date].to_s
							if try_marriage[:end_date]
								range += "-#{try_marriage[:end_date]}"
							else
								range += '-present'
							end
							value += ' ('+range+')'
						end
				
					# normal (string) value
					else
						value = Wikipedia::Page.sanitize(value)
						value.gsub!('}}','')
					end
			
					retval[:info][key] = value
				rescue Exception => e
					logger.error "error parsing infobox field #{field}: #{e.message}"
				end
			end
		rescue Exception => e
			logger.error "error parsing infobox: #{e.message}"
		end
		
		return retval
	end
	
	# The full URL of the wikipedia page
	def url
		"#{base}/wiki/#{page}"
	end
	
	# Find the Wikipedia page given the query, the type of page, and the
	# locale.
	#
	# If no page is found, a search for an english page will be done.
	def self.find_page(query, locale, type)
		query = query.titleize
		logger.info "finding page on wikipedia"
		logger.info " query : #{query}"
		logger.info " locale: #{locale}"
		logger.info " type  : #{type}"
		page = find_localized_page(query, locale, type)
		
		unless page or lang(locale) == :en
			logger.debug 'reverting to english page'
			page = find_english_page(query, type)
		end
		
		page
	end
	
	private
	
	# The maximum number of links to crawl when doing a breadth-first search
	# Set to -1 for infinite
	MAX_LINKS_TO_CRAWL = 10
	
	# The base URL of the wikipedia pages given a locale
	def self.base(locale = :us)
		"https://#{lang(locale)}.wikipedia.org"
	end
	
	# The language subdomain for a given locale
	def self.lang(locale)
		case locale.to_s
		when 'us' then 'en'
		when 'uk' then 'en'
		when 'cn' then 'zh'
		when 'se' then 'sv'
		else locale.to_s
		end
	end
	
	def self.get_first_sentence(page)
		begin
			content = page.sanitized_content
			cut_pos = 100
			max_cut = content.index('==')
			cut_pos = [cut_pos,max_cut].min
			intro = ""
			loop do
				cut = content.index('.',cut_pos)
				if cut > max_cut
					if cut_pos <= 0
						return nil
					end
					cut_pos = content.rindex('.',cut-1)
					next
				end
				intro = content[0..cut]
				cut_pos += 5
				if intro.scan(/<b>/).count <= intro.scan(/<\/b>/).count or
				   cut_pos > 200 or max_cut <= cut_pos
					break
				end
			end
			intro.gsub!('<p>', '')
			intro.gsub!('</p>', '')
		
			unclosed_b = intro.scan(/<b>/).count - intro.scan(/<\/b>/).count
			intro += "</b>"*unclosed_b
		
			unclosed_i = intro.scan(/<i>/).count - intro.scan(/<\/i>/).count
			intro += "</i>"*unclosed_i
		rescue
			return nil
		end
	end
	
	# Find a page on the English version of wikipedia that is categorized
	# as the specified type, matching the given query.
	def self.find_english_page(query, type)
		find_localized_page(query, :us, type)
	end
	
	# Find a page on wikipedia that is categorized as the specified type,
	# matching the given query.
	def self.find_localized_page(query, locale, type)
		l = lang(locale)
		Wikipedia.Configure do
			protocol 'https'
			domain    "#{l}.wikipedia.org"
			path      'w/api.php'
		end
		
		logger.debug "url: https://#{l}.wikipedia.org/w/api.php"
		logger.debug "looking up page #{query}"
		page = Wikipedia.find(query)
		return page if is_correct_type?(page, type, l.to_sym)
		
		logger.debug "page did not match, looking through possible suffixes"
		get_suffixes(query, type, l.to_sym).each do |suffixed_page|
			logger.debug "checking suffixed page #{suffixed_page}"
			page = Wikipedia.find(suffixed_page)
			# for these pages we don't require correct category, the suffix is sufficient
			return page if page and page.content
		end
		
		logger.debug "last resort: starting to crawl links"
		return follow_links(page, l.to_sym, type)
	end
	
	# Does a breadth-first scan of links on a page and returns the first
	# page that matches the correct type
	#
	# If a link to a disambiguation page is found, it is searched by depth first
	def self.follow_links(page, language, type)
		return nil unless page and page.title and page.content
		logger.debug "following links on #{page.title}"
		
		# check for disambiguation page and crawl it if it exists
		logger.debug "disambiguatized title: #{disambiguatize(page.title, language)}"
		dis_page = Wikipedia.find(disambiguatize(page.title, language))
		if dis_page and is_disambiguation_page?(dis_page, language) and page.title != dis_page.title
			logger.debug "found disambiguation page: #{dis_page.title}"
			p = follow_links(dis_page, language, type)
			return p if p
		end
		
		# breadth-first crawl of link graph
		logger.debug 'starting breadth-first crawl'
		queue = links_in_content(page)
		i = 0
		queue.each do |link|
			logger.debug "following link: #{link}"
			p = Wikipedia.find(link)
			return p if is_correct_type?(p, type, language)
			
			i += 1
			return nil if MAX_LINKS_TO_CRAWL > 0 and i > MAX_LINKS_TO_CRAWL
			logger.debug "no match, extracing #{links_in_content(p).length} links"
			queue << links_in_content(p)
		end
		
		# sorry, nothing found :(
		return nil
	end
	
	# Extract all links in content of page
	#
	# Remark: The page.links list does not always return
	# every link in the page content. Example page: Queen
	def self.links_in_content(page)
		return [] unless page and page.content
		links = page.content.scan(/\[\[[\w\s(|[^\]]+)?]+\]\]/)
		links.collect { |l| l[2..-3].split('|')[0] }
	end
	
	# Whether or not a page belongs to a given type
	def self.is_correct_type?(page, type, language)
		return false unless page and page.content
		cats = get_categories(type, language)
		# turn into regular expressions where we match ending
		cats = cats.collect { |c| Regexp.new(c, Regexp::IGNORECASE | Regexp::EXTENDED) }
		self.matches_any_category?(page, cats)
	end
	
	# Whether or not a page is a disambiguation page
	def self.is_disambiguation_page?(page, language)
		return false unless page and page.content
		categories = get_categories(:disambiguation, language)
		return false if categories.empty?
		self.matches_any_category?(page, categories)
	end
	
	# Turns a query (page title) into the name of an explicit
	# disambiguation page
	def self.disambiguatize(query, language)
		return query unless disambiguation_indicators[:title_suffixes].has_key? language
		suffixes = get_suffixes(query, :disambiguation, language)
		return query if suffixes.empty?
		return suffixes[0]
	end
	
	# Whether or not a page belongs to any in a list of categories
	#
	# A category can be a regular expression or a string
	def self.matches_any_category? (page, categories)
		return false unless page && page.categories
		logger.debug "needles:"
		logger.debug "  #{categories.inspect}"
		logger.debug "haystack:"
		logger.debug "  #{page.categories.inspect}"
		page.categories.each do |hay|
			categories.each do |needle|
				return true if needle.is_a?(Regexp) and needle.match(hay)
				return true if needle.is_a?(String) and needle == hay
			end
		end
		logger.debug "no match!"
		false
	end
	
	# Extract the infobox section from wikipedia markup
	def self.extract_infobox(content)
		return nil unless content.include? '{{Infobox'
		start = content.index '{{Infobox'
		level = 0
		stop = -1
		(start+2..content.length-1).each do |i|
			str = content[i..i+1]
			if str == '{{'
				level += 1
				i+=1
			elsif str == '}}' and level == 0
				stop = i+1
				break
			elsif str == '}}'
				level -= 1
				i+=1
			end
		end
		
		return nil if stop <= start
		
		return content[start..stop]
	end
	
	# Tries to parse a flat list inside a string and returns the list elements
	# as an array, or nil if unsuccessful
	def self.parse_list(s)
		begin
			logger.debug s.inspect
			m = s.match(/{{\s*(flat|plain)\s*list\s*\|\s*\n(?<l>[^{}]+)}}/)
			unless m
				m = s.match(/{{\s*(flat|plain)\s*list}}\n(?<l>[^\n]+\n){{\s*end(flat|plain)list\s*}}/)
			end
			return nil unless m
			l = m.captures.collect { |c| c.split("\n") }.flatten
			l.collect { |c| Wikipedia::Page.sanitize(c.gsub('*','').strip) }
		rescue Exception => e
			logger.error e.inspect
			nil
		end
	end
	
	# Tries to parse a date inside a string and return the date as a Date object
	# or nil if unsuccessful
	def self.parse_date(s)
		begin
			m = s.match(/{{\s*(bda|dob|\w+\s*date[\d\s\w]*)\s*(\|[\s\w=]*)*\|\s*(?<y>\d+)\s*\|\s*(?<m>\d+)\s*\|\s*(?<d>\d+)/)
			return nil unless m and m.captures.length > 2
			return Date.parse("#{m[:y]}-#{m[:m]}-#{m[:d]}")
		rescue Exception => e
			logger.error e.inspect
			return nil
		end
	end
	
	# Tries to parse a marriage inside a string and return the spouse and years
	# or nil if unsuccessful
	def self.parse_marriage(s)
		begin
			m = s.match(/{{\s*marriage\s*\|([^\{\}]+)}}/)
			return nil unless m
			fields = Wikipedia::Page.sanitize(m.captures[0]).split('|')
			name = nil
			start_date = nil
			end_date = nil
			fields.each do |f|
				next if f.strip.start_with? '()'
				if not name
					name = f.strip
				elsif not start_date
					if f.match(/^\d+$/)
						start_date = f.to_i
					else
						begin
							start_date = Date.parse(f)
						rescue
							break
						end
					end
				elsif not end_date
					if f.match(/^\d+$/)
						end_date = f.to_i
					else
						begin
							end_date = Date.parse(f)
						rescue
						end
					end
					break
				end
			end
			return {name: name, start_date: start_date, end_date: end_date}
		rescue Exception => e
			logger.error e.inspect
			return nil
		end
	end
	
	# Gets a list of categories for a given type and language
	def self.get_categories(type, language)
		return [] unless type_indicators[:categories].has_key? type
		return [] unless type_indicators[:categories][type].has_key? language
		return type_indicators[:categories][type][language]
	end
	
	# Gets a list of title suffixes for a given type and language
	def self.get_suffixes(title, type, language)
		return [] unless type_indicators[:title_suffixes].has_key? type
		return [] unless type_indicators[:title_suffixes][type].has_key? language
		suffixes = type_indicators[:title_suffixes][type][language]
		suffixes.collect { |s| title.end_with?(" (#{s})") ? title : "#{title} (#{s})" }
	end
	
	def self.get_fields_of_interest(type, language)
		return [] unless fields_of_interest.has_key? type
		return [] unless fields_of_interest[type].has_key? language
		return fields_of_interest[type][language]
	end
	
	# The categories and title suffixes for every type and language
	def self.type_indicators
		{
			title_suffixes:
			{
				artist:
				{
					en: ['band', 'artist', 'singer', 'rapper'],
					sv: ['band', 'artist', 'sångare']
				},
				disambiguation: {
					en: ['disambiguation'],
					sv: ['olika betydelser']
				}
			},
			categories:
			{
				artist: {
					en: ['musicians', 'artists', 'duos', 'music groups',
					'singers', 'guitarists', 'rappers'],
			
					sv: ['gitarrister', 'sångare', 'musiker', 'musikgrupper']	
				},
				disambiguation: {
					en: [
						"Category:All article disambiguation pages",
						"Category:All disambiguation pages",
						"Category:Disambiguation pages"
					],
					sv: [
						"Kategori:Förgreningssidor"
					]
				}
			}
		}
	end
	
	def self.fields_of_interest
		{
			artist:
			{
				en: ['origin', 'genre', 'years_active', 'label', 'current_members',
			'past_members', 'birth_date', 'death_date', 'birth_place', 'death_place',
			'alias', 'hometown', 'parents', 'spouse', 'children', 'tools',
			'instrument', 'residence', 'education', 'relations', 'relatives',
			'resting_place', 'death_cause', 'net_worth'],
				sv: ['ursprung', 'genre', 'aktiva_år', 'pseudonym(er)', 'fädd',
			'däd', 'instrument', 'skivbolag', 'medlemmar', 'tidigare_medlemmar',
			'inspiratörer', 'inspirerat'],
			}
		}
	end
end