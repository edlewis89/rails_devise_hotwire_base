class TypeOfWorkPolicy < ApplicationPolicy
  attr_reader :user, :type_of_work

  def initialize(user, type_of_work)
    @user = user
    @type_of_work = type_of_work
  end

  def create?
    user.admin? || user.homeowner?
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin? || user.homeowner?
  end

  def update?
    user.admin? || user.homeowner?
  end
end