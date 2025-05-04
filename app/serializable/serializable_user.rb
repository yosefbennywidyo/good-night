class SerializableUser < JSONAPI::Serializable::Resource
  type "users"

  attributes :name

  attribute :date do
    @object.created_at
  end

  has_many :following do
    data do
      @object.following
    end

    link :related do
      @url_helpers.api_v1_user_followings_url(@object.id)
    end

    meta do
      {
        total: @object.following.count
      }
    end
  end

  has_many :followers do
    data do
      @object.followers
    end

    link :related do
      @url_helpers.api_v1_user_followings_url(@object.id)
    end

    meta do
      {
        total: @object.followers.count
      }
    end
  end

  has_many :sleep_records do
    data do
      @object.sleep_records
    end

    link :related do
      @url_helpers.api_v1_user_sleep_records_url(@object.id)
    end

    meta do
      {
        total: @object.sleep_records.count
      }
    end
  end

  link :following_records do
    @url_helpers.following_records_api_v1_user_sleep_records_url(@object.id)
  end

  link :self do
    @url_helpers.api_v1_user_url(@object.id)
  end

  link :related do
    @url_helpers.api_v1_user_url(@object.id)
  end

  def jsonapi_cache_key(*)
    [ @object.cache_key_with_version ]
  end
end
