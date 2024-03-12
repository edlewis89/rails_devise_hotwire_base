class AdvertisementPolicy < ApplicationPolicy

  attr_reader :user, :ad

  def initialize(user, ad)
    @user = user
    @ad = ad
  end

  def create?
    user.admin? || user.ad_manager?
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  def destroy?
    user.present? && (user.admin? || user.ad_manager?)
  end

  def update?
    user.present? && (user.admin? || user.ad_manager?)
  end
end