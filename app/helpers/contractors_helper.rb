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
    contractor_options = contractors.pluck(:name, :id) # Pluck name and ID for dropdown options

    # Return contractor options as an array of arrays
    contractor_options.map { |contractor| [contractor[0], contractor[1]] }
  end
end
