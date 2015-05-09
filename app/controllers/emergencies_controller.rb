class EmergenciesController < ApplicationController
  before_action :set_emergency, only: [:show, :update]
  before_action :new_emergency, only: [:create]

  def index
    render json: { emergencies: Emergency.all,
                   full_responses: Emergency.full_response_metrics
                 }, status: :ok
  end

  def show
    if @emergency
      render json: @emergency
    else
      fail ActiveRecord::RecordNotFound
    end
  end

  def create
    if @emergency.save
      @emergency.send_responders
      json_response = @emergency.as_json(methods: [:responders, :full_response])
      render json: { emergency: json_response }, status: :created
    else
      render json: { message: @emergency.errors }, status: :unprocessable_entity
    end
  end

  def update
    Emergency.responders_back(params)
    render json: @emergency if @emergency.update_attributes emergency_update_params
  end

  private

  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity)
  end

  def emergency_update_params
    params.require(:emergency).permit(:fire_severity, :police_severity, :medical_severity, :resolved_at)
  end

  def new_emergency
    @emergency = Emergency.new emergency_params
    responders = Responder.responders
    @emergency.assign_responders(responders)
  end

  def set_emergency
    @emergency ||= Emergency.find_by_code params[:id]
  end
end
