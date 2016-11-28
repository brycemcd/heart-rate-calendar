require 'rails_helper'

RSpec.describe HeartRateData, type: :model do

  let(:user) { FactoryGirl.create(:user) }
  let(:heart_rate_data) { described_class.create!(user: user) }

  describe "#update_heart_rate_data!" do
    it "updates heart rate data, for a user" do
      heart_rate_data.update_heart_rate_data!

      expect(heart_rate_data.reload.data).to be_truthy
    end
  end
end
