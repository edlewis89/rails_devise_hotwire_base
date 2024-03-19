class ServiceRequestPolicy < ApplicationPolicy
  attr_reader :user, :service_request

  def initialize(user, service_request)
    @user = user
    @service_request = service_request
  end

  def index
    show?
  end
  
  def show
    current_user.admin? || current_user == service_request.homeowner
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

  def bid?
    user.service_provider? && (user.pro? || user.premium?)
  end
end