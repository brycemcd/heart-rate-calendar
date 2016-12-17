require 'rails_helper'

RSpec.describe ActivityJournal, type: :model do
  let(:user) { FactoryGirl.build(:user) }
  let(:heart_rate_data) { described_class.create!(user: user) }

  describe '#update_heart_rate_data!' do
    it 'updates heart rate data, for a user' do
      VCR.use_cassette("heart rate data today") do
        heart_rate_data.update_heart_rate_data!

        expect(heart_rate_data.reload.data).to be_truthy
      end
    end

    it "updates heart rate data, for a user, at specific date" do
      VCR.use_cassette("heart rate data 2016-07-29") do
        heart_rate_data.update_heart_rate_data!(date: '2016-07-29')

        expect(heart_rate_data.reload.data).to be_truthy
      end
    end

    describe "invalid date" do
      it "does not update heart rate data, for a user" do
        expect do
          heart_rate_data.update_heart_rate_data!(date: '20160729')
        end.to raise_error(ArgumentError, 'invalid date')
      end

      it "does not update heart rate data, for a user" do
        expect do
          heart_rate_data.update_heart_rate_data!(date: '29-07-2016')
        end.to raise_error(ArgumentError, 'invalid date')
      end

      it "does not update heart rate data, for a user" do
        expect do
          heart_rate_data.update_heart_rate_data!(date: '2016-07-99')
        end.to raise_error(ArgumentError, 'invalid date')
      end
    end
  end
end
