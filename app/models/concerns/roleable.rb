module Roleable
  extend ActiveSupport::Concern

  included do
    enum role: [:admin, :general, :homeowner, :contractor]
  end
end