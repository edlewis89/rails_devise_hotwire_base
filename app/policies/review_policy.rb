class ReviewPolicy < ApplicationPolicy
  attr_reader :user, :review

  def initialize(user, review)
    @user = user
    @review = review
  end

  def create?
    user.admin? || user.property_owner?
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin? || user.property_owner?
  end

  def update?
    user.admin? || user.property_owner?
  end

  def autocomplete?
    user.admin? || user.property_owner?
  end
end