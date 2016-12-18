require 'rails_helper'

RSpec.describe ActivityJournal, type: :model do
  let(:user) { FactoryGirl.build(:user) }
  let(:heart_rate_data) { described_class.create!(user: user,
                                                  activity_type: 'heart_rate') }

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

  describe "#update_step_count_data!" do
    let(:aj) { described_class.new }
    let(:fb_client) { instance_double('FitbitClient',
                                      activity_intraday_time_series: {foo: :bar}.to_json) }

    context 'valid date' do
      it 'calls the api for an intraday time series and updates a record' do
        expect(aj).to receive(:client).and_return(fb_client)
        expect(aj).to receive(:update!).and_return(true)
        expect(fb_client).to receive(:activity_intraday_time_series).
          and_return({foo: :bar}.to_json)

        aj.update_step_count_data!
      end

      it 'does not call update and returns false if no data is returned from the api' do
        expect(aj).to receive(:client).and_return(fb_client)
        expect(aj).to_not receive(:update!)
        expect(fb_client).to receive(:activity_intraday_time_series).
          and_return(nil)

        expect(aj.update_step_count_data!).to be_falsey
      end
    end

    context 'invalid date' do
      it "exits false" do
        expect do
          aj.update_step_count_data!(date: 'bunk')
        end.to raise_error(ArgumentError, 'invalid date')
      end
    end
  end

  it 'does the right thing if the API returns empty data (user has not synced for the date given)'
end
