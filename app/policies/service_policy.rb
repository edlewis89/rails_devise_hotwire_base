class ServicePolicy < ApplicationPolicy
  attr_reader :user, :service

  def initialize(user, service)
    @user = user
    @service = service
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
end