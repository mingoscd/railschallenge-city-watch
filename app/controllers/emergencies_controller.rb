class EmergenciesController < ApplicationController
  before_action :set_emergency, only: [:show, :update]

  def index
    response, full_response = [], 0
    if Emergency.count > 0
      emergencies = Emergency.all
      emergencies.each do |emergency|
        full_response += 1 if emergency.full_response
        response << emergency
      end
    end
    full_response_emergencies = [full_response, Emergency.count]
    render json: { emergencies: response, full_responses: full_response_emergencies }, status: :ok
  end

  def show
    if @emergency
      render json: @emergency
    else
      fail ActiveRecord::RecordNotFound
    end
  end

  def create
    emergency = new_emergency
    if emergency.save
      emergency.send_responders
      json_response = emergency.as_json(methods: [:responders, :full_response])
      render json: { emergency: json_response }, status: :created
    else
      render json: { message: emergency.errors }, status: :unprocessable_entity
    end
  end

  def update
    Emergency.responders_back(params)  
    render json: @emergency if @emergency.update_attributes emergency_update_params
  end

  def new_emergency
    emergency = Emergency.new emergency_params
    responders = Responder.responders
    emergency.assign_responders(responders)
    emergency
  end

  private

  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity)
  end

  def emergency_update_params
    params.require(:emergency).permit(:fire_severity, :police_severity, :medical_severity, :resolved_at)
  end

  def set_emergency
    @emergency ||= Emergency.find_by_code params[:id]
  end
end
