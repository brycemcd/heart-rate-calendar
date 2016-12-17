require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) do
    User.create(
      provider: 'fitbit',
      uid: '123',
      name: 'Tom',
      refresh_token: '123456ab',
      access_token: '123.56abds',
      token_expires_at: '1480273437'
    )
  end

  it "User should have correct attributes" do
    expect(user.valid?).to eq(true)
  end

  describe "#add_heart_rate_data!" do
    it "creates heart rate data for today" do
      expect { user.add_heart_rate_data! }.to change { user.activity_journals.count }.from(0).to(1)
    end

    it "creates heart rate data for specified date" do
      expect_any_instance_of(ActivityJournal).to receive(:update_heart_rate_data!).with(date: '2016-07-01')
      user.add_heart_rate_data!(date: '2016-07-01')
    end
  end
end
