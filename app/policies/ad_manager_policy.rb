class AdManagerPolicy < ApplicationPolicy
  attr_reader :user, :ad_manager

  def initialize(user, ad_manager)
    @user = user
    @ad_manager = ad_manager
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
    user.present? && (user.admin? || user.ad_manager?)
  end
end