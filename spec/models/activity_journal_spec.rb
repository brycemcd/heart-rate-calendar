require 'rails_helper'

RSpec.describe ActivityJournal, type: :model do
  describe "before_validation" do
    it 'assigns a hash value to the data' do
      aj = build(:activity_journal, data: {foo: :bar}.to_json)
      expect(aj.data_hash).to be_nil
      aj.valid?
      expect(aj.data_hash).to_not be_nil
    end

    it 'will not save the same data hash twice' do
      json_string = {foo: :bar}.to_json
      aj = build(:activity_journal, data: json_string)
      expect(aj.save).to be_truthy
      aj2 = build(:activity_journal, data: json_string)
      expect { aj2.save }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
