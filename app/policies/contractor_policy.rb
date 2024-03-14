class ContractorPolicy < ApplicationPolicy
  attr_reader :user, :contractor

  def initialize(user, contractor)
    @user = user
    @contractor = contractor
  end

  def index?
    user.admin? || user.property_owner?
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
    user.present? && (user.admin? || record&.user == user)
  end

  def search?
    user.admin? || user.property_owner? || user.general?
  end

  def update?
    user.present? && (user.admin? || user.property_owner? || user.service_provider? || user.pro? || user.premium? || user == record)
  end
end