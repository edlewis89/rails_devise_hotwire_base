class HomeownersController < ApplicationController
  before_action :set_homeowner, only: %i[ show edit update destroy ]

  # GET /homeowners or /homeowners.json
  def index
    @homeowners = Homeowner.all
  end

  # GET /homeowners/1 or /homeowners/1.json
  def show
  end

  # GET /homeowners/new
  def new
    @homeowner = Homeowner.new
  end

  # GET /homeowners/1/edit
  def edit
  end

  # POST /homeowners or /homeowners.json
  def create
    @homeowner = Homeowner.new(homeowner_params)

    respond_to do |format|
      if @homeowner.save
        format.html { redirect_to homeowner_url(@homeowner), notice: "Homeowner was successfully created." }
        format.json { render :show, status: :created, location: @homeowner }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @homeowner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /homeowners/1 or /homeowners/1.json
  def update
    respond_to do |format|
      if @homeowner.update(homeowner_params)
        format.html { redirect_to homeowner_url(@homeowner), notice: "Homeowner was successfully updated." }
        format.json { render :show, status: :ok, location: @homeowner }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @homeowner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /homeowners/1 or /homeowners/1.json
  def destroy
    @homeowner.destroy!

    respond_to do |format|
      format.html { redirect_to homeowners_url, notice: "Homeowner was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_homeowner
      @homeowner = Homeowner.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def homeowner_params
      params.require(:homeowner).permit(:name, :description)
    end
end
