class ReviewsController < ApplicationController
  before_action :find_review, only: [:edit, :update, :destroy]

  def index
    @reviews = current_user.reviews
  end

  def new
    @review = Review.new
  end

  def create
    @review = Review.new(review_params)
    if @review.save
      redirect_to reviews_path, notice: "Review created successfully."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @review.update(review_params)
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

  def find_review
    @review = Review.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:title, :body, :rating, :contractor_id, :homeowner_id)
  end
end

