class User < ApplicationRecord
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      user.name = auth['info']['full_name']
      user.refresh_token = auth['credentials']['refresh_token']
    end
  end
end
