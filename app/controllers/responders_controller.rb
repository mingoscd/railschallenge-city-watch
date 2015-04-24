class RespondersController < ApplicationController
  REQUEST_FIELDS = :type, :name, :capacity
  RESPONSE_FIELDS = :type, :name, :capacity, :emergency_code, :on_duty

  def index
    if params[:show] == 'capacity'
      capacity = Responder.capacity_statistics
      render json: { capacity: capacity }, status: :ok
    else
      json_responders = Responder.all.as_json(only: RESPONSE_FIELDS)
      render json: { responders: json_responders }, status: :ok
    end
  end

  def show
    responder = Responder.find_by name: params[:id]
    if responder.nil?
      head 404
    else
      json_responder = responder.as_json(only: RESPONSE_FIELDS)
      render json: { responder: json_responder }
    end
  end

  def new
    not_found
  end

  def create
    responder = Responder.new responder_params
    if responder.save
      json_response = responder.as_json(only: RESPONSE_FIELDS)
      render json: { responder: json_response }, status: :created
    else
      json_response = responder.errors.as_json
      render json: { message: json_response }, status: :unprocessable_entity
    end
  rescue ActionController::UnpermittedParameters => err
    render json: { message: err.to_s }, status: :unprocessable_entity
  end

  def edit
    not_found
  end

  def update
    responder = Responder.find_by name: params[:id]
    if responder.update_attributes responder_update_params
      json_responder = responder.as_json(only: RESPONSE_FIELDS)
      render json: { responder: json_responder }
    end
  rescue ActionController::UnpermittedParameters => err
    render json: { message: err.to_s }, status: :unprocessable_entity
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
