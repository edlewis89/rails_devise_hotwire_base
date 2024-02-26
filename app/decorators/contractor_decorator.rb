class ContractorDecorator
  attr_reader :result

  def initialize(result)
    @result = result
  end
  #
  # def method_missing(method_name, *args, &block)
  #   @result.__send__(method_name, *args, &block)
  # end
  #
  # def respond_to_missing?(method_name, include_private = false)
  #   @result.respond_to?(method_name, include_private) || super
  # end

  def name
    result['_source']['name']
  end

  def email
    result['_source']['email']
  end

  def phone_number
    result['_source']['phone_number']
  end

  # Add more methods as needed for other attributes
end