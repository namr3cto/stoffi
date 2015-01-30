class ChartsController < ApplicationController
	
	before_filter :verify_admin, except: [:recent_listens_for_user]
	
	def recent_listens_for_user
		render json: User.group(:email).order(sign_in_count: :desc).limit(10).sum(:sign_in_count)
	end
	
	def active_users
		render json: User.group(:email).order(sign_in_count: :desc).limit(10).sum(:sign_in_count)
	end
	
	private
	
	def verify_admin
		return true if signed_in? and current_user.admin?
		
		respond_to do |format|
			format.html { redirect_to :new_user_session }
			format.json { head :forbidden }
			format.xml { head :forbidden }
		end
	end
	
end