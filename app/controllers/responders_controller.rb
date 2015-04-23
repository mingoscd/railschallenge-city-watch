class RespondersController < ApplicationController
  REQUEST_FIELDS = :type, :name, :capacity
  RESPONSE_FIELDS = :type, :name, :capacity, :emergency_code, :on_duty

  def index
    if params[:show] == 'capacity'
      capacity = Responder.capacity_statistics
      render json: { capacity: capacity }, status: 200
    else
      json_response = []
      if Responder.count > 0
        responders = Responder.all
        responders.each do |responder|
          json_response << JSON[responder.to_json(only: RESPONSE_FIELDS)]
        end
      end
      render json: { responders: json_response }, status: 200
    end
  end

  def show
    responder = Responder.find_by name: params[:id]
    if responder.nil?
      head 404
    else
      json_responder = JSON[responder.to_json(only: RESPONSE_FIELDS)]
      render json: { responder: json_responder }
    end
  end

  def new
    not_found
  end

  def create
    responder = Responder.new responder_params
    if responder.save
      json_response = JSON[responder.to_json(only: RESPONSE_FIELDS)]
      render json: { responder: json_response }, status: 201
    else
      json_response = JSON[responder.errors.to_json]
      render json: { message: json_response }, status: 422
    end
  rescue ActionController::UnpermittedParameters => err
    render json: { message: err.to_s }, status: 422
  end

  def edit
    not_found
  end

  def update
    responder = Responder.find_by name: params[:id]
    if responder.update_attributes responder_update_params
      json_responder = JSON[responder.to_json(only: RESPONSE_FIELDS)]
      render json: { responder: json_responder }
    end
  rescue ActionController::UnpermittedParameters => err
    render json: { message: err.to_s }, status: 422
  end

  def destroy
    not_found
  end

  private

  def responder_params
    params.require(:responder).permit(REQUEST_FIELDS)
  end

  def responder_update_params
    params.require(:responder).permit(:on_duty)
  end
end
