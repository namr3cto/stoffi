# -*- encoding : utf-8 -*-
module DonationsHelper
	def too_many_donations?
		Donation.pending_artists_count >= @site_config.pending_donations_limit
	end
	
	def price_tagify(amount)
		whole = amount.to_i
		part = (amount - whole) * 100
		raw "$#{number_with_delimiter(whole)}<sup>%02d</sup>" % part.round
	end
end