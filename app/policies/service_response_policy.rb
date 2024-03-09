class ServiceResponsePolicy < ApplicationPolicy
  attr_reader :user, :service_response

  def initialize(user, service_response)
    @user = user
    @service_response = service_response
  end

  def create?
    user.service_provider?
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin?
  end

  def update?
    user.service_provider? || user.admin?
  end

  def respond?
    user.property_owner?
  end
end