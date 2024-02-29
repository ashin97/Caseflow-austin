# frozen_string_literal: true

require "rails_helper"

RSpec.describe TranscriptFileIssuesMailer, type: :mailer do
  describe "#send_issue_details" do
    let(:details) do
      {
        action: "convert",
        provider: "rtf",
        docket_number: "12345"
      }
    end
    let(:appeal_id) { "12345678" }
    let(:mail) { described_class.send_issue_details(details, appeal_id).deliver_now }

    it "renders the subject" do
      expect(mail.subject).to eq("File #{details[:action]} Error - #{details[:provider]} #{details[:docket_number]}")
    end

    it "renders the receiver email" do
      expect(mail.to).to eq(["BVAHearingTeam@VA.gov"])
    end

    it "renders the sender email" do
      expect(mail.from).to eq(["BoardofVeteransAppealsHearings@messages.va.gov"])
    end

    it "assigns @details" do
      expect(mail.body.encoded).to match(details[:action])
      expect(mail.body.encoded).to match(details[:provider])
      expect(mail.body.encoded).to match(details[:docket_number])
    end

    it "assigns @case_link" do
      expect(mail.body.encoded).to match("localhost:3000/queue/appeals/#{appeal_id}")
    end

    it "assigns @case_link for demo environment" do
      allow(Rails).to receive(:deploy_env).and_return(:demo)
      mail = described_class.send_issue_details(details, appeal_id).deliver_now
      expect(mail.body.encoded).to match("https://caseflowdemo.com/queue/appeals/#{appeal_id}")
    end

    it "assigns @case_link for staging environment" do
      allow(Rails).to receive(:deploy_env).and_return(:staging)
      mail = described_class.send_issue_details(details, appeal_id).deliver_now
      expect(mail.body.encoded).to match("https://appeals.cf.uat.ds.va.gov/queue/appeals/#{appeal_id}")
    end

    it "assigns @case_link for prod environment" do
      allow(Rails).to receive(:deploy_env).and_return(:prod)
      mail = described_class.send_issue_details(details, appeal_id).deliver_now
      expect(mail.body.encoded).to match("https://appeals.cf.ds.va.gov/queue/appeals/#{appeal_id}")
    end
  end

  describe "#webex_recording_list_issues" do
    let(:details) do
      {
        action: "retrieve ",
        provider: "webex",
        docket_number: "12345"
      }
    end
    let(:appeal_id) { "12345678" }
    let(:mail) { described_class.webex_recording_list_issues(details).deliver_now }

    it "renders the subject" do
      expect(mail.subject).to eq("File #{details[:action]} Error - #{details[:provider]}")
    end

    it "renders the receiver email" do
      expect(mail.to).to eq(["BVAHearingTeam@VA.gov"])
    end

    it "renders the sender email" do
      expect(mail.from).to eq(["BoardofVeteransAppealsHearings@messages.va.gov"])
    end

    it "assigns @details" do
      expect(mail.body.encoded).to match(details[:action])
      expect(mail.body.encoded).to match(details[:provider])
    end

    it "assigns @details" do
      expect(mail.body.encoded).to match(details[:action])
      expect(mail.body.encoded).to match(details[:provider])
      expect(mail.body.encoded).to match(details[:docket_number])
    end

    it "does not assign @case_link if times is present" do
      details[:times] = "10:00 AM"
      expect(mail.body.encoded).not_to match("localhost:3000/queue/appeals/#{appeal_id}")
    end

    it "renders the correct message for FileConversionError" do
      details[:error] = TranscriptionTransformer::FileConversionError
      expected_message = "Please investigate this issue further to ensure continued " \
                          "communication with Caseflow."
      expect(mail.body.encoded).to match(expected_message)
    end

    it "renders the correct message for other errors" do
      details[:error] = "SomeOtherError"
      expected_message = "Please investigate this issue further to ensure continued " \
                      "communication between Caseflow and #{details[:provider]}."
      expect(mail.body.encoded).to match(expected_message)
    end
  end
end
