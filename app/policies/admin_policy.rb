class AdminPolicy < ApplicationPolicy
  attr_reader :user, :admin

  def initialize(user, admin)
    @user = user
    @admin = admin
  end

  def create?
    user.present? && user.admin?
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  def destroy?
    user.present? && (user.admin? || record.user == user)
  end

  def update?
    user.present? && (user.admin?)
  end
end