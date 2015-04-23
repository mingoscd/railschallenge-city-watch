class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  def not_found
    render json: { message: 'page not found' }, status: 404
  end
end
