class AdvertisementsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :authorize_user, except: %i[index show]
  before_action :set_ad, only: [:show, :edit, :update, :destroy]

  def index
    @user_zipcode = current_user.primary_address_zipcode
    @services = Service.pluck(:name) # Retrieve all service names

    # Find advertisements matching the user's zipcode for all services
    @ads = Advertisement.joins(:addresses)
                        .where(addresses: { zipcode: @user_zipcode })
                        .includes(:service)
                        .order(created_at: :desc)
    #.paginate(page: params[:page] || 1, per_page: 5)
  end

  def edit
    @ad = Advertisement.find(params[:id])
    @services = Service.all
  end

  def new
    @ad = Advertisement.new
    @ad.addresses.build  # Build nested address object
  end

  def create
    @ad = Advertisement.new(ad_params)

    if @ad.save
      redirect_to @ad, notice: 'Ad was successfully created.'
    else
      render :new
    end
  end

  def update
    @ad = Advertisement.find(params[:id])
    if @ad.update(ad_params)
      redirect_to @ad, notice: 'Ad was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @ad.destroy

    respond_to do |format|
      format.html { redirect_to advertisements_url, notice: "Ad was successfully destroyed." }
      format.turbo_stream { render turbo_stream: destroy_stream }
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("Record not found: #{e.message}")
    respond_to do |format|
      format.html { redirect_to advertisements_url, alert: "Ad not found." }
    end
  end

  # def destroy
  #   begin
  #     @ad.destroy!
  #     respond_to do |format|
  #       format.turbo_stream do
  #         render turbo_stream: [
  #           turbo_stream.remove(@ad),
  #           turbo_stream.replace("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Ad deleted" })
  #         ]
  #
  #       end
  #       format.html { redirect_to advertisements_url, notice: "Ad was successfully destroyed." }
  #       format.json { head :no_content }
  #     end
  #
  #   rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
  #     Rails.logger.error("Document not found in Elasticsearch: #{e.message}")
  #     respond_to do |format|
  #       format.turbo_stream do
  #         render turbo_stream: [
  #           turbo_stream.remove(@ad),
  #           turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Ad deleted" })
  #         ]
  #
  #       end
  #       format.html { redirect_to admins_url, notice: "Ad was successfully destroyed." }
  #       format.json { head :no_content }
  #     end
  #   end
  # end


  # other CRUD actions...

  private

  def destroy_stream
    if @ad.destroyed?
      [
        turbo_stream.remove(@ad),
        turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Ad deleted" })
      ]
    else
      turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Failed to delete ad" })
    end
  end


  def authorize_user
    ad = @ad || Advertisement
    authorize ad
  end

  def set_ad
    @ad = Advertisement.find(params[:id])
  end

  def ad_params
    params.require(:advertisement).permit(:title, :image_data, :url, :service_id,
                                          addresses_attributes: [:addressable_id, :street, :city, :state, :zipcode])
  end
end