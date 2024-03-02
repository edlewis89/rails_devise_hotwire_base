class TypeOfWorksController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :authorize_user, except: %i[index show]

  before_action :set_type_of_work, only: [:edit, :update, :destroy]

  # Define the show action
  def show
    # Your code here
  end

  def index
    @type_of_works = TypeOfWork.all
  end

  def new
    @type_of_work = TypeOfWork.new
  end

  def create
    @type_of_work = TypeOfWork.new(type_of_work_params)
    if @type_of_work.save
      redirect_to type_of_works_path, notice: 'Type of work was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @type_of_work.update(type_of_work_params)
      redirect_to type_of_works_path, notice: 'Type of work was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @type_of_work.destroy
    redirect_to type_of_works_path, notice: 'Type of work was successfully destroyed.'
  end

  private

  def authorize_user
    type_of_work = @type_of_work || TypeOfWork
    authorize type_of_work
  end

  def set_type_of_work
    @type_of_work = TypeOfWork.find(params[:id])
  end

  def type_of_work_params
    params.require(:type_of_work).permit(:name)
  end
end
