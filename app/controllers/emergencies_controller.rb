class EmergenciesController < ApplicationController
  DEFAULT_PARAM_FIELDS = :code, :fire_severity, :police_severity, :medical_severity
  UPDATE_PARAM_FIELDS = :fire_severity, :police_severity, :medical_severity, :resolved_at
  UPDATE_FIELDS = :code, :fire_severity, :police_severity, :medical_severity, :resolved_at

  def index
    response, full_response = [], 0
    if Emergency.count > 0
      emergencies = Emergency.all
      emergencies.each do |emergency|
        full_response += 1 if emergency.full_response
        response << emergency.as_json(only: DEFAULT_PARAM_FIELDS)
      end
    end
    full_response_emergencies = [full_response, Emergency.count]
    render json: { emergencies: response, full_responses: full_response_emergencies }, status: :ok
  end

  def show
    emergency = Emergency.find_by code: params[:id]
    if emergency.nil?
      head :not_found
    else
      json_emergency = emergency.as_json(only: DEFAULT_PARAM_FIELDS)
      render json: { emergency: json_emergency }
    end
  end

  def new
    not_found
  end

  def create
    emergency = new_emergency
    if emergency.save
      emergency.send_responders
      json_response = emergency.as_json(only: DEFAULT_PARAM_FIELDS, methods: [:responders, :full_response])
      render json: { emergency: json_response }, status: :created
    else
      json_response = emergency.errors.as_json
      render json: { message: json_response }, status: :unprocessable_entity
    end
  rescue ActionController::UnpermittedParameters => err
    render json: { message: err.to_s }, status: :unprocessable_entity
  end

  def edit
    not_found
  end

  def update
    emergency = Emergency.find_by code: params[:id]
    Emergency.responders_back(params)

    if emergency.update_attributes emergency_update_params
      json_response = emergency.as_json(only: UPDATE_FIELDS)
      render json: { emergency: json_response }
    end
  rescue ActionController::UnpermittedParameters => err
    render json: { message: err.to_s }, status: :unprocessable_entity
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
