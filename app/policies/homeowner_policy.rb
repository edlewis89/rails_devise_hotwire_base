class HomeownerPolicy < ApplicationPolicy
  attr_reader :user, :homeowner

  def initialize(user, homeowner)
    @user = user
    @homeowner = homeowner
  end

  def create?
    user.present? && user.property_owner?
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

  def search?
    user.general? || user.member? || user.admin?
  end

  def update?
    user.present? && (user.admin? || user.property_owner? || user.active? || record.user == user)
  end
end

