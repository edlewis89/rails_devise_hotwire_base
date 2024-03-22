module ContractorsHelper
  def search_contractors
    es_response = Profile.search_in_elastic(query_params[:query]).response
    profile_ids = []
    if es_response.present? && es_response['hits'].present? && es_response['hits']['hits'].present?
      es_response['hits']['hits'].each do |hit|
        profile_ids << hit['_id'] if hit['_source']['user_type'] == 'Contractor'
      end
    end
    contractors = Contractor.joins(:profile).where(profiles: { id: profile_ids.map(&:to_i) })
    @contractors = contractors.paginate(page: params[:page] || 1, per_page: 5)
    render_index_template
  end

  def search_contractors_for_options_select(term = '')
    es_response = Profile.search_elastic(term)
    profile_ids = []

    if es_response.present? && es_response['hits'].present? && es_response['hits']['hits'].present?
      es_response['hits']['hits'].each do |hit|
        profile_ids << hit['_id'] if hit['_source']['user_type'] == 'Contractor'
      end
    end

    contractors = Contractor.joins(:profile).where(profiles: { id: profile_ids.map(&:to_i) })
    #
    # # Assign the list of contractors to the instance variable
    # @contractors = contractors

    contractor_options = contractors.pluck(:id, :name, :email) # Assuming name is the field you want to display in the dropdown

    # Return both the contractors and the options for the dropdown
    { contractors: contractors, contractor_options: contractor_options }
  end
end
