module Verify
  class TwoFactorsController < ApplicationController
    before_action :timeout_temp_user_in_session

    def new
      # TODO: make this configurable per user
      if true #not @temp_user.two_factors.activated?
        auth_success and return
      end
    end

    def create
      two_factor = temp_user.two_factors.by_type(params[:two_factor][:type])
      two_factor.assign_attributes(two_factor_params)

      if two_factor.verify
        auth_success
      else
        redirect_to new_verify_two_factor_path, alert: t('.error')
      end
    end

    private

    def two_factor_params
      params.require(:two_factor).permit(:otp)
    end

    def timeout_temp_user_in_session
      redirect_to signin_path, notice: t('.timeout') if temp_user.nil?
    end

    def auth_success
      member_id = session[:temp_member_id]
      reset_session
      session[:member_id] = member_id
      send_signin_notification
      if current_user.activated? and (current_user.id_document and current_user.id_document_verified?)
        redirect_to market_path(current_market)
      else
        redirect_to settings_path
      end
    end

    def send_signin_notification
      # false below will be placed by a method that return true if user sign in at different ip
      if false && current_user.activated?
        MemberMailer.notify_signin(member_id).deliver
      end
    end

    def temp_user
      @temp_user ||= Member.find_by_id(session[:temp_member_id])
    end
  end
end
