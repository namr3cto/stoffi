module I18nHelper
	
	def t? key
		I18n.t key, raise: true rescue false
	end
	
	def current_lang
		lang(I18n.locale.to_s)
	end
	
	def current_locale
		case I18n.locale.to_s
		when 'us' then :us
		when 'uk' then :us
		else I18n.locale
		end
	end
	
	def lang(locale)
		case locale.to_s
		when 'se' then 'Svenska'
		when 'us' then 'English (US)'
		when 'uk' then 'English (UK)'
		when 'cn' then '简体中文'
		when 'no' then 'Norsk'
		when 'fi' then 'Suomi'
		when 'de' then 'Deutsch'
		when 'pt' then 'Português'
		else locale
		end
	end
	
	def langtag(locale)
		full_locale locale
	end
	
	def short_langtag(locale)
		case locale.to_s
		when 'se' then 'sv'
		when 'us' then 'en'
		when 'uk' then 'en'
		when 'cn' then 'zh'
		when 'de' then 'de'
		else locale
		end
	end
	
	def full_locale(locale)
		case locale.to_s
		when 'se' then 'sv_SE'
		when 'us' then 'en_US'
		when 'uk' then 'en_GB'
		when 'cn' then 'zh_CN'
		when 'de' then 'de_DE'
		else locale.to_s
		end
	end
	
	def lang2flag(lang)
		lang = case lang.to_s
		when 'uk' then 'gb'
		else lang
		end
		"flags/#{lang}.png"
	end
	
	def link_to_language(display, options)
		options[:host] = lang2host(options[:l].to_s)
		case options[:l].to_s
		when 'cn'
			options[:l] = nil
		end
		return link_to display, options
	end
	
	def lang2host(lang)
		host = request.host.split('.')
		unless host[-1].in? ['dev','io']
			case lang
			when 'cn' then host[-1] = 'cn'
			else host[-1] = 'com'
			end
		end
		host.join('.')
	end
end	