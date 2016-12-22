require 'rails_helper'

RSpec.describe ActivityJournal, type: :model do
  describe "before_validation" do
    it 'assigns a hash value to the data' do
      aj = build(:activity_journal, data: {foo: :bar})
      expect(aj.data_hash).to be_nil
      aj.valid?
      expect(aj.data_hash).to_not be_nil
    end
  end

  describe "keeping a running log of a single day" do
    it 'archives older records', tag: :db_expensive do
      u1 = create(:user)
      u2 = create(:user)
      journal_date = Date.today - 3

      # base
      aj1 = create(:activity_journal,
                   user: u1,
                   journal_date: journal_date,
                   data: {foo: :bar}.to_json)
      # different data (and thus hash)
      aj2 = create(:activity_journal,
                   user: u1,
                   journal_date: journal_date,
                   data: {foo: :bar, baz: :woo}.to_json)
      # different user
      aj3 = create(:activity_journal,
                   user: u2,
                   journal_date: journal_date,
                   data: {foo: :bar, baz: :woo}.to_json)
      # different data
      aj4 = create(:activity_journal,
                   user: u1,
                   journal_date: journal_date,
                   data: {baz: :woo}.to_json)

      [aj1, aj2, aj3, aj4].map(&:reload)

      expect(aj1.archived?).to be_truthy
      expect(aj2.archived?).to be_truthy
      expect(aj3.archived?).to be_falsey
      expect(aj4.archived?).to be_falsey
    end
  end
end
