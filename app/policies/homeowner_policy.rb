class HomeownerPolicy < ApplicationPolicy
  attr_reader :user, :homeowner

  def initialize(user, homeowner)
    @user = user
    @homeowner = homeowner
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
    return true if user.admin?
    # Are they homeowner
    return true if user.homeowner?
    # Are they active.  If they are active they can be searched.
    # So we want to update any info that needs to be.
    return true if user.active?

    false
  end
end

