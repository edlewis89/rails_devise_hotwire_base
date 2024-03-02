class HomeownersController < ApplicationController

  before_action :authenticate_user!, except: %i[index show]
  before_action :authorize_user, except: %i[index show]
  before_action :set_homeowner, only: %i[ show edit update destroy ]

  # GET /homeowners or /homeowners.json
  def index
    @homeowners = Homeowner.order(created_at: :desc).paginate(page: params[:page], per_page: 5)
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
    @homeowner = Homeowner.find(params[:id])
    respond_to do |format|
      format.html # Render HTML template for editing
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@homeowner, partial: "homeowners/form", locals: { homeowner: @homeowner }) }
    end
  end

  # POST /homeowners or /homeowners.json
  def create
    @homeowner = Homeowner.new(homeowner_params)
    respond_to do |format|
      if @homeowner.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new_homeowner', partial: "homeowners/form", locals: { homeowner: Homeowner.new }),
            turbo_stream.prepend('homeowners', partial: "homeowners/homeowner", locals: { homeowner: @homeowner }),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Homeowner #{@homeowner.email} reated" })
          ]
        end
        format.html { redirect_to contractor_url(@homeowner), notice: "Homeowner was successfully created." }
        format.json { render :show, status: :created, location: @homeowner }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new_homeowner', partial: "homeowners/form", locals: { homeowner: @homeowner })
          ]
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @homeowner.errors, status: :unprocessable_entity }

        #render_flash(:alert, full_messages(@contractor.errors.full_messages))
      end
    end
  end

  # PATCH/PUT /homeowners/1 or /homeowners/1.json
  def update
    respond_to do |format|
      if @homeowner.update(homeowner_params) && @homeowner.profile.update(profile_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(@homeowner,
                                partial: "homeowners/homeowner",
                                locals: { homeowner: @homeowner }),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Homeowner #{@homeowner.email} Updated" })
          ]
        end
        format.html { redirect_to homeowner_url(@homeowner), notice: "Homeowner and profile was successfully updated." }
        format.json { render :show, status: :ok, location: @homeowner }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(@homeowner,
                                partial: "homeowners/form",
                                locals: { homeowner: @homeowner }),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :error, message: full_messages(@homeowner.errors.full_messages) })
          ]
  
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @homeowner.errors, status: :unprocessable_entity }
  
        #render_flash(:alert, full_messages(@contractor.errors.full_messages))
      end
    end
  end

  # DELETE /homeowners/1 or /homeowners/1.json
  def destroy
    begin
      @homeowner.destroy!
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(@homeowner),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Homeowner deleted" })
          ]

        end
        format.html { redirect_to homeowners_url, notice: "Homeowner was successfully destroyed." }
        format.json { head :no_content }
      end

    rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
      Rails.logger.error("Document not found in Elasticsearch: #{e.message}")
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(@homeowner),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Homeowner deleted" })
          ]

        end
        format.html { redirect_to homeowners_url, notice: "Homeowner was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  end

  private

  def authorize_user
    homeowner = @homeowner || Homeowner
    authorize homeowner
  end
    # Use callbacks to share common setup or constraints between actions.
  def set_homeowner
    @homeowner = Homeowner.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def homeowner_params
    params.require(:homeowner).permit(:name, :description)
  end
end
