class ServicesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :authorize_user, except: %i[index show]

  before_action :set_service, only: [:edit, :update, :destroy]

  # Define the show action
  def show
    # Your code here
  end

  def index
    @services = Service.all
  end

  def new
    @service = Service.new
  end

  def create
    @service = Service.new(service_params)
    if @service.save
      redirect_to services_path, notice: 'Service was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @service.update(service_params)
      redirect_to services_path, notice: 'Service was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @service.destroy
    redirect_to services_path, notice: 'Service was successfully destroyed.'
  end

  private

  def authorize_user
    service = @service || Service
    authorize service
  end

  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    params.require(:service).permit(:name)
  end
end
