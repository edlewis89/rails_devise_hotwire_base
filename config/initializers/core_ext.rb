class Hash
  def deep_find(key, object=self, found=nil)
    if object.respond_to?(:key?) && object.key?(key)
      return object[key]
    elsif object.is_a? Enumerable
      object.find { |*a| found = deep_find(key, a.last) }
      return found
    end
  end
end

# Define MI_IN_KM if not already defined
module Geocoder
  module Calculations
    MI_IN_KM = 1.60934 unless defined?(MI_IN_KM)
  end
end