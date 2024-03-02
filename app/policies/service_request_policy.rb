class ServiceRequestPolicy < ApplicationPolicy
  attr_reader :user, :service_request

  def initialize(user, service_request)
    @user = user
    @service_request = service_request
  end

  def create?
    user.homeowner?
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
    user.homeowner? || user.admin?
  end

  def respond?
    user.contractor?
  end
end