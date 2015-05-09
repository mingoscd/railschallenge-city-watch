class RespondersController < ApplicationController
  before_action :set_responder, only: [:show, :update]

  def index
    if params[:show] == 'capacity'
      render json: { capacity: Responder.capacity_statistics }
    else
      render json: Responder.all, root: 'responders'
    end
  end

  def show
    if @responder
      render json: @responder
    else
      fail ActiveRecord::RecordNotFound
    end
  end

  def create
    @responder = Responder.new responder_params
    if @responder.save
      render json: @responder, root: 'responder', status: :created
    else
      render json: { message: @responder.errors }, status: :unprocessable_entity
    end
  end

  def update 
    render json: @responder if @responder.update_attributes responder_update_params
  end

  private

  def responder_params
    params.require(:responder).permit(:type, :name, :capacity)
  end

  def responder_update_params
    params.require(:responder).permit(:on_duty)
  end

  def set_responder
    @responder ||= Responder.find_by_name params[:id]
  end
end
