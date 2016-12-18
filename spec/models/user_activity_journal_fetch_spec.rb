require 'rails_helper'

RSpec.describe UserActivityJournalFetch, type: :model do
  let(:u) { User.new }
  let(:at) { :steps }
  let(:dc) { described_class.new(user: u, activity_type: at) }
  let(:heart_dc) { described_class.new(user: u, activity_type: :heart_rate) }

  describe "#init" do
    it 'sets the readers attrs' do
      expect(dc.activity_type).to eql(at)
      expect(dc.user).to eql(u)
      expect(dc.date).to eql(Date.today.to_s)
    end
  end

  describe "#valid?" do
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
  end

  describe "#client" do
    it 'should use the shoddy (but best) gem we found' do
      expect(dc.client).to be_kind_of Fitbit::Client
    end
  end

  describe 'fetching data from the api' do
    let(:default_return_data) { {foo: :bar}.to_json }
    it 'will not make an api call unless params are valid' do
      expect(dc).to receive(:valid?).and_return(false)

      expect(dc.create_journal_entry).to be_falsey
    end

    it 'will make a step count call if activity_type is steps' do
      client = double('client', activity_intraday_time_series: default_return_data)
      expect(dc).to receive(:client).and_return(client)
      expect(dc).to receive(:return_data_valid?).and_return(true)

      expected_hash = dc.fitbit_intraday_default_hash.merge(resource_path: 'activities/steps')
      expect(client).to receive(:activity_intraday_time_series).with(expected_hash)

      dc.create_journal_entry
    end

    it 'will make a heart_rate call if activity_type is heart_rate' do
      dc = UserActivityJournalFetch.new(user: u, activity_type: :heart_rate)

      client = double('client', heart_rate_intraday_time_series: default_return_data)
      expect(dc).to receive(:client).and_return(client)
      expect(dc).to receive(:return_data_valid?).and_return(true)

      expected_hash = dc.fitbit_intraday_default_hash
      expect(client).to receive(:heart_rate_intraday_time_series).with(expected_hash)

      dc.create_journal_entry
    end

    it 'will return false when the response is nil' do
      expect(dc).to receive(:api_call).and_return(nil)

      expect(dc.create_journal_entry).to be_falsey
      expect(dc.errors).to_not be_empty
    end

    it 'will return false if HEART data has not been synced to fitbit on the day in question' do
      raw_data = <<-EOF
      {"activities-heart":[{"customHeartRateZones":[],"dateTime":"today","heartRateZones":[{"max":92,"min":30,"name":"Out of Range"},{"max":129,"min":92,"name":"Fat Burn"},{"max":157,"min":129,"name":"Cardio"},{"max":220,"min":157,"name":"Peak"}],"value":"0"}],"activities-heart-intraday":{"dataset":[],"datasetInterval":1,"datasetType":"minute"}}
      EOF
      return_data = JSON.parse(raw_data)

      obj = heart_dc
      expect(obj).to receive(:api_call).and_return(return_data)

      expect(obj.create_journal_entry).to be_falsey
      expect(obj.errors).to_not be_empty
    end

    it 'will return false if STEP data has not been synced to fitbit on the day in question' do
      raw_data = <<-EOF
      {"activities-steps":[{"dateTime":"today","value":"0"}],"activities-steps-intraday":{"dataset":[{"time":"00:00:00","value":0}]}}
      EOF
      return_data = JSON.parse(raw_data)

      obj = dc
      expect(obj).to receive(:api_call).and_return(return_data)

      expect(obj.create_journal_entry).to be_falsey
      expect(obj.errors).to_not be_empty
    end
  end

  describe "#create_journal_entry" do
    it 'should create a new record when the api response is valid'
  end
end
