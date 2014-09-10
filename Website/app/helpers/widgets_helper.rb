module WidgetsHelper
	
	def twitter_widget(username, options = {})
		options.reverse_merge!(
		{
			:version => 2,
			:type => 'profile',
			:rpp => 4,
			:interval => 30000,
			:width => 'auto',
			:height => 300,
			:theme =>
			{
				:shell => 
				{
					:background => '#0091ff',
					:color => '#ffffff'
				},
				:tweets =>
				{
					:background => '#ffffff',
					:color => '#000000',
					:links => '#0091ff'
				}
			},
			:features =>
			{
				:live => true,
				:scrollbar => false,
				:loop => false,
				:behavior => 'all'
			}
		})
		
		options[:width] = "'#{options[:width]}'" if options[:width].is_a?(String)
		
		raw("<div class='widget'>
		<script charset='utf-8' src='http://widgets.twimg.com/j/2/widget.js'></script>
		<script>
		new TWTR.Widget({
		  version: #{options[:version]},
		  type: '#{options[:type]}',
		  rpp: #{options[:rpp]},
		  interval: #{options[:interval]},
		  width: #{options[:width]},
		  height: #{options[:height]},
		  lang: '#{langtag(I18n.locale)}',
		  theme: {
			shell: {
			  background: '#{options[:theme][:shell][:background]}',
			  color: '#{options[:theme][:shell][:color]}'
			},
			tweets: {
			  background: '#{options[:theme][:tweets][:background]}',
			  color: '#{options[:theme][:tweets][:color]}',
			  links: '#{options[:theme][:tweets][:links]}'
			}
		  },
		  features: {
			scrollbar: #{options[:features][:scrollbar]},
			loop: #{options[:features][:loop]},
			live: #{options[:features][:live]},
			behavior: '#{options[:features][:behavior]}'
		  }
		}).render().setUser('#{username}').start();
		</script></div>")
	end
	
	def facebook_widget(username, options = {})
		options.reverse_merge!(
		{
			:width => 210,
			:show_faces => true,
			:stream => false,
			:header => false
		})
		
		raw("<div class='fb-like-box'
		data-lang='#{langtag(I18n.locale)}'
		data-href='http://www.facebook.com/#{username}'
		data-width='#{options[:width]}'
		data-show-faces='#{options[:show_faces]}'
		data-stream='#{options[:stream]}'
		data-header='#{options[:header]}'></div>")
	end
	
	def soundcloud_widget(username, options = {})
		raw("<div class='center'>
		<a href='https://soundcloud.com/#{username}' style=\"text-align: left; display: block; margin: 0 auto; width: 160px; height: 92px; font-size: 11px; padding: 68px 0 0 0; background: transparent url(http://a1.sndcdn.com/images/badges/imonsc/square/blue.png?c052af5) top left no-repeat; color: #ffffff; text-decoration: none; font-family: 'Lucida Grande', Helvetica, Arial, sans-serif; line-height: 1.3em; text-align: center; outline: 0;\" class='soundcloud-badge'>http://soundcloud.com/<span style='display: block; width: 137px; height: 20px; margin: 0px 0 0 12px; overflow: hidden; -o-text-overflow: ellipsis; text-overflow: ellipsis'>#{username}</span></a>
		</div>")
	end
end