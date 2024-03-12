json.extract! admin, :id, :name, :description, :created_at, :updated_at, :license_number, :insurance_provider, :insurance_policy_number, :have_insurance, :service_area, :years_of_experience, :specializations, :certifications, :languages_spoken, :hourly_rate, :active
json.url admin_url(admin, format: :json)
