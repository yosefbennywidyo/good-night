class SerializableFollowing < JSONAPI::Serializable::Resource
  type "followings"

  attributes :created_at, :updated_at

  has_one :follower do
    data do
      @object.follower
    end

    link :related do
      @url_helpers.api_v1_user_url(@object.follower_id)
    end
  end

  has_one :followed do
    data do
      @object.followed
    end

    link :related do
      @url_helpers.api_v1_user_url(@object.followed_id)
    end
  end

  link :self do
    @url_helpers.api_v1_following_url(@object.id)
  end

  def jsonapi_cache_key(*)
    [ @object.cache_key_with_version ]
  end
end
