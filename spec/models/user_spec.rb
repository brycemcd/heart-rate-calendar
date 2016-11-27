require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) do
    User.create(
      provider: 'fitbit',
      uid: '123',
      name: 'Tom',
      refresh_token: '123456ab',
      access_token: '123.56abds'
    )
  end

  it "User should have correct attributes" do
    expect(user.valid?).to eq(true)
  end
end
