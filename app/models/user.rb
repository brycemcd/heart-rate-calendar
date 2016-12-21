class User < ApplicationRecord
  has_many :activity_journals, dependent: :destroy

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      user.name = auth['info']['full_name']
      user.refresh_token = auth['credentials']['refresh_token']
      user.access_token = auth['credentials']['token']
      user.token_expires_at = auth['credentials']['expires_at']
    end
  end
end
