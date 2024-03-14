class ServiceRequestPolicy < ApplicationPolicy
  attr_reader :user, :service_request

  def initialize(user, service_request)
    @user = user
    @service_request = service_request
  end

  def create?
    user.property_owner?
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
    user.property_owner? || user.admin?
  end

  def respond?
    user.service_provider? && (user.pro? || user.premium?) && !user.responses_for_request(record).present?
  end
end