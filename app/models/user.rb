class User < ApplicationRecord
  has_many :heart_rate_datas, dependent: :destroy

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

  def add_heart_rate_data!(date: 'today')
    heart_rate_datas << HeartRateData.new
    heart_rate_datas.last.update_heart_rate_data!(date: date)
  end
end
