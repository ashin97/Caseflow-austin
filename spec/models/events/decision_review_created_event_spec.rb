# frozen_string_literal: true

RSpec.describe DecisionReviewCreatedEvent, type: :model do
  describe "inheritance" do
    subject { create(:decision_review_created_event) }
    it "is a child class of Event and is the correct type" do
      subject.reload
      expect(Event.count).to eq(1)
      expect(Event.first.id).to eq(subject.id)
      expect(Event.first.type).to eq(subject.class.name)
    end
  end

  describe "#completed?" do
    let!(:event) { create(:decision_review_created_event) }

    context "when an event is in progress" do
      it "should not be completed" do
        expect(event.completed?).to eq false
      end
    end

    context "when an event is completed" do
      it "should return completed status" do
        event.update(completed_at: Time.current)
        expect(event.completed?).to eq true
      end
    end
  end

  describe "event records association" do
    let!(:my_event) { create(:decision_review_created_event) }
    let!(:intake) { create(:intake)}
    let!(:event_record) {EventRecord.create!(event_id: my_event.id, backfill_record: intake)}

    it "should associate with it's event_records" do
      expect(my_event.event_records.count).to eq 1
    end

    it "should have event_records that have a 2 way relationship with itself" do
      expect(my_event.event_records.first.event_id).to eq my_event.id
    end
  end
end
