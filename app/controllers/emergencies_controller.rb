class EmergenciesController < ApplicationController
  DEFAULT_PARAM_FIELDS = :code, :fire_severity, :police_severity, :medical_severity
  UPDATE_PARAM_FIELDS = :fire_severity, :police_severity, :medical_severity, :resolved_at
  UPDATE_FIELDS = :code, :fire_severity, :police_severity, :medical_severity, :resolved_at

  def index
    response, served = [], 0
    if Emergency.count > 0
      emergencies = Emergency.all
      emergencies.each do |emergency|
        served += 1 if emergency.served
        response << JSON[emergency.to_json(only: DEFAULT_PARAM_FIELDS)]
      end
    end
    served_emergencies = [served, Emergency.count]
    render json: { emergencies: response, full_responses: served_emergencies }, status: 200
  end

  def show
    emergency = Emergency.find_by code: params[:id]
    if emergency.nil?
      head 404
    else
      json_emergency = emergency.to_json(only: DEFAULT_PARAM_FIELDS)
      render json: { emergency: JSON[json_emergency] }
    end
  end

  def new
    not_found
  end

  def create
    emergency = new_emergency
    if emergency.save
      emergency.send_responders
      json_response = JSON[emergency.to_json(only: DEFAULT_PARAM_FIELDS, methods: [:responders, :full_response])]
      render json: { emergency: json_response }, status: 201
    else
      json_response = JSON[emergency.errors.to_json]
      render json: { message: json_response }, status: 422
    end
  rescue ActionController::UnpermittedParameters => err
    render json: { message: err.to_s }, status: 422
  end

  def edit
    not_found
  end

  def update
    emergency = Emergency.find_by code: params[:id]
    Emergency.responders_back(params)

    if emergency.update_attributes emergency_update_params
      json_response = JSON[emergency.to_json(only: UPDATE_FIELDS)]
      render json: { emergency: json_response }
    end
  rescue ActionController::UnpermittedParameters => err
    render json: { message: err.to_s }, status: 422
  end

  def destroy
    not_found
  end

  def new_emergency
    emergency = Emergency.new emergency_params
    responders = Responder.responders
    emergency.assign_responders(responders)
    emergency
  end

  private

  def emergency_params
    params.require(:emergency).permit(DEFAULT_PARAM_FIELDS)
  end

  def emergency_update_params
    params.require(:emergency).permit(UPDATE_PARAM_FIELDS)
  end
end
