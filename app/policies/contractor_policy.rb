class ContractorPolicy < ApplicationPolicy
  attr_reader :user, :contractor

  def initialize(user, contractor)
    @user = user
    @contractor = contractor
  end

  def create?
    user.admin?
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

  def search?
    user.general? || user.member? || user.admin?
  end

  def update?
    user.admin? || !contractor.active?
  end
end