class SerializableSleepRecord < JSONAPI::Serializable::Resource
  type "sleep_records"

  attributes :clock_in_at, :clock_out_at, :duration_seconds, :created_at, :updated_at

  attribute :duration_formatted do
    if @object.duration_seconds.present?
      hours = @object.duration_seconds / 3600
      minutes = (@object.duration_seconds % 3600) / 60
      "#{hours}h #{minutes}m"
    else
      "N/A"
    end
  end

  has_one :user do
    data do
      @object.user
    end

    link :related do
      @url_helpers.api_v1_user_sleep_records_url(@object.user_id)
    end
  end

  link :self do
    @url_helpers.following_records_api_v1_user_sleep_records_url(@object.id)
  end

  def jsonapi_cache_key(*)
    [ @object.cache_key_with_version ]
  end
end
