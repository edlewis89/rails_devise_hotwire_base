# custom_form_builder.rb
class CustomFormBuilder < ActionView::Helpers::FormBuilder

  # Custom method to render fields for nested associations
  def nested_fields_for(association, options = {}, &block)
    object = @object || objectify_options[:object]

    # Ensure the association object is correctly initialized as a Contractor
    association_object = object.send(association)
    association_object ||= object.addresses.first_or_initialize

    # If association object is nil or empty, build a new one
    if association_object.blank?
      association_object = object.addresses.send("first_or_initialize")
    end

    # Add a data attribute to indicate the association name
    options[:data] ||= {}
    options[:data][:association] = association.to_s

    fields_for(association, association_object, options, &block)

    fields_for(association, association_object, options, &block)
  end


  # Override the method to add 'required' attribute for fields with presence validation
  def text_field(method, options = {})
    add_required_attribute(method, options)
    super
  end

  def text_area(method, options = {})
    add_required_attribute(method, options)
    super
  end

  def select(method, choices = nil, options = {}, html_options = {}, &block)
    add_required_attribute(method, html_options)
    super
  end

  private

  def add_required_attribute(method, options)
    object_class = object.class
    if object_class.validators_on(method).any? { |v| v.is_a?(ActiveModel::Validations::PresenceValidator) }
      options[:required] = true unless options.key?(:required)
    end
  end
end