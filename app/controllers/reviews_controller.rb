class ReviewsController < ApplicationController
  include ContractorsHelper

  before_action :authenticate_user!, except: %i[index show]
  before_action :authorize_user, except: %i[index show]
  before_action :set_review, only: %i[show edit update destroy]

  before_action :find_review, only: %i[edit update destroy]

  def index
    @reviews = current_user.reviews
  end

  def new
    @review = Review.new
    @contractor_options = search_contractors_for_options_select(params[:q])
  end

  def create
    @reviewer_id = current_user.id

    @review = Review.new(review_params.merge(homeowner_id: @reviewer_id))
    if @review.save
      flash_message = "Review was successfully created."
      render_success_message(flash_message)
    else
      render_error_message(@review)
    end
  end

  def edit
  end

  def update
    @reviewer_id = current_user.id  # Assuming current_user is the reviewer

    if @review.update(review_params.merge(homeowner_id: @reviewer_id))
      redirect_to reviews_path, notice: "Review updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @review.destroy
    redirect_to reviews_path, notice: "Review deleted successfully."
  end

  private

  def authorize_user
    authorize (@review || Review)
  end

  def set_review
    @review = Review.find(params[:id])
  end

  def find_review
    @review = Review.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:title, :rating, :content, :contractor_id)
  end

  def render_success_message(message)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('new_review', partial: "reviews/form", locals: { review: Review.new }),
          turbo_stream.prepend('reviews', partial: "reviews/review", locals: { review: @review }),
          turbo_stream.update("flash", partial: "shared/notices", locals: { msg_type: :alert, message: message })
        ]
      end
      format.html { redirect_to review_url(@review), notice: message }
      format.json { render :show, status: :created, location: @review }
    end
  end

  def render_error_message(model)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace('form-container', partial: "reviews/form", locals: { review: model }),
          turbo_stream.replace("form-container", partial: "shared/notices", locals: { msg_type: :error, message: full_messages(model.errors.full_messages) })
        ]
      end
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: model.errors, status: :unprocessable_entity }
    end
  end
end

