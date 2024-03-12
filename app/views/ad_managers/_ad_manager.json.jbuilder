json.extract! ad_manager, :id, :name, :description, :created_at, :updated_at, :license_number, :insurance_provider, :insurance_policy_number, :have_insurance, :service_area, :years_of_experience, :specializations, :certifications, :languages_spoken, :hourly_rate, :active
json.url ad_manager_url(ad_manager, format: :json)
