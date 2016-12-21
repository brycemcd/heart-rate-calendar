require 'rails_helper'

RSpec.describe UserActivityJournalFetch, type: :model do
  let(:u) { User.new }
  let(:at) { :steps }
  let(:dc) { described_class.new(user: u, activity_type: at) }
  let(:invalid_dc) { described_class.new(user: u, activity_type: :bunk) }
  let(:heart_dc) { described_class.new(user: u, activity_type: :heart_rate) }
  let(:default_return_data) { {foo: :bar}.to_json }

  describe '#init' do
    it 'sets the readers attrs' do
      expect(dc.activity_type).to eql(at)
      expect(dc.user).to eql(u)
      expect(dc.date).to eql(Date.today.to_s)
    end
  end

  describe '#valid?' do
    it 'is invalid if a date is not parseable' do
      invalid_date = 'foo'
      dc = described_class.new(user: u, activity_type: at, date: invalid_date)

      expect(dc.valid?).to be_falsey
      expect(dc.errors).to_not be_empty
    end

    it 'is not valid if user is not a user' do
      u = Object.new
      dc = described_class.new(user: u, activity_type: at)

      expect(dc.valid?).to be_falsey
      expect(dc.errors).to_not be_empty
    end

    it 'is not valid if activity_type is not :steps or :heart_rate' do
      at = :foo
      dc = described_class.new(user: u, activity_type: at)

      expect(dc.valid?).to be_falsey
      expect(dc.errors).to_not be_empty
    end

    it 'will not make an api call unless params are valid' do
      expect(dc).to receive(:valid?).and_return(false)

      expect(dc.fetch_data).to be_falsey
    end
  end

  describe '#client' do
    it 'should use the shoddy (but best) gem we found' do
      expect(dc.client).to be_kind_of Fitbit::Client
    end
  end

  describe 'fetching data from the api' do
    context 'when valid? is true' do
      it 'will make a step count call if activity_type is steps' do
        client = double('client',
                        activity_intraday_time_series: default_return_data)
        expect(dc).to receive(:client).and_return(client)
        expect(dc).to receive(:valid?).and_return(true)

        expected_hash = dc.fitbit_intraday_default_hash.merge(resource_path: 'activities/steps')
        expect(client).to receive(:activity_intraday_time_series).with(expected_hash)

        dc.fetch_data
      end

      it 'will make a heart_rate call if activity_type is heart_rate' do
        dc = invalid_dc

        client = double('client',
                        heart_rate_intraday_time_series: default_return_data)
        expect(dc).to receive(:client).and_return(client)
        expect(dc).to receive(:valid?).and_return(true)

        expected_hash = dc.fitbit_intraday_default_hash
        expect(client).to receive(:heart_rate_intraday_time_series).with(expected_hash)

        dc.fetch_data
      end
    end

    context 'when the object is invalid' do
      it 'will return false when the object is not valid' do
        dc = invalid_dc

        expect(dc.fetch_data).to be_falsey
        expect(dc.errors).to_not be_empty
      end
    end
  end

  describe '#api_response_valid?' do
    it 'makes a call to fetch the data' do
      expect(dc.api_response_data).to be_nil

      expect(dc).to receive(:fetch_data)
      expect(dc).to receive(:return_data_valid?).and_return(true)

      dc.api_response_valid?
    end

    context 'invalid step response' do
      it 'will return false if STEP data has not been synced to fitbit on the day in question' do
        raw_data = <<-EOF
        {"activities-steps":[{"dateTime":"today","value":"0"}],"activities-steps-intraday":{"dataset":[{"time":"00:00:00","value":0}]}}
        EOF
        return_data = JSON.parse(raw_data)

        expect(dc).to receive(:api_call).and_return(return_data)

        expect(dc.api_response_valid?).to be_falsey
        expect(dc.errors).to_not be_empty

      end
    end

    context 'invalid heart response' do
      it 'will return false if HEART data has not been synced to fitbit on the day in question' do
        raw_data = <<-EOF
        {"activities-heart":[{"customHeartRateZones":[],"dateTime":"today","heartRateZones":[{"max":92,"min":30,"name":"Out of Range"},{"max":129,"min":92,"name":"Fat Burn"},{"max":157,"min":129,"name":"Cardio"},{"max":220,"min":157,"name":"Peak"}],"value":"0"}],"activities-heart-intraday":{"dataset":[],"datasetInterval":1,"datasetType":"minute"}}
        EOF
        return_data = JSON.parse(raw_data)

        obj = heart_dc
        expect(obj).to receive(:api_call).and_return(return_data)

        expect(obj.api_response_valid?).to be_falsey
        expect(obj.errors).to_not be_empty
      end
    end
  end

  describe '#create_journal_entry' do
    it "fetches api data if it hasn't been fetched yet and saves the record" do
      expect(dc).to receive(:fetch_data).and_return(default_return_data)
      expect(u.activity_journals).to receive(:create).and_return(true)

      dc.create_journal_entry
    end

    it 'returns false if any of the object is invalid' do
      expect(invalid_dc.create_journal_entry).to be_falsey
    end
  end
end
