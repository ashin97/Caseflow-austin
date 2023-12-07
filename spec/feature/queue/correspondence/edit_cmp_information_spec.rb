# frozen_string_literal: true

# rubocop:disable Layout/LineLength
RSpec.feature("The Correspondence Review Package page") do
  let(:veteran) { create(:veteran) }
  let(:package_document_type) { PackageDocumentType.create(id: 15, active: true, created_at: Time.zone.now, name: 10_182, updated_at: Time.zone.now) }
  let(:correspondence) { create(:correspondence, veteran_id: veteran.id, package_document_type_id: package_document_type.id) }
  let(:correspondence_documents) { create(:correspondence_document, correspondence: correspondence, document_file_number: veteran.file_number) }
  let(:mail_team_user) { create(:user) }
  let(:mail_team_org) { MailTeam.singleton }

  context "Review package feature toggle" do
    before :each do
      User.authenticate!(roles: ["Mail Intake"])
    end

    it "routes user to /unauthorized if the feature toggle is disabled" do
      FeatureToggle.disable!(:correspondence_queue)
      visit "/queue/correspondence/#{correspondence.uuid}/review_package"
      expect(page).to have_current_path("/unauthorized")
    end
  end

  context "Review package form shell" do
    before :each do
      FeatureToggle.enable!(:correspondence_queue)
      User.authenticate!(roles: ["Mail Intake"])
      visit "/queue/correspondence/#{correspondence.uuid}/review_package"
    end

    it "the Review package page exists" do
      expect(page).to have_current_path("/queue/correspondence/#{correspondence.uuid}/review_package")
    end
    it "check for CMP Edit button" do
      expect(page).to have_content("Edit")
      click_button "Edit"
    end
    it "the save button is disabled at first" do
      click_button "Edit"
      expect(page).to have_field("VA DOR")
      expect(page).to have_field("Package document type")
      expect(page).to have_button("Cancel")
      expect(page).to have_button("Save", disabled: true)
    end

    it "Checking the VA DOR and Package document type values in modal" do
      click_button "Edit"
      expect(page).to have_content(correspondence.va_date_of_receipt.strftime("%m/%d/%Y"))
      expect(page).to have_content(package_document_type.name.to_s)
    end

    it "Saving the VA DOR and Package document type values in modal" do
      click_button "Edit"
      fill_in "VA DOR", with: 6.days.ago.strftime("%m/%d/%Y")
      click_button "Save"
      expect(page).to have_content(6.days.ago.strftime("%m/%d/%Y"))
    end

    it "displays request package action dropdown" do
      expect(page).to have_content("Request package action")
    end

    context "when request package action dropdown is clicked" do
      before do
        first(".cf-select__control").click
      end

      it "displays 4 package actions" do
        expect(page).to have_content("Reassign package")
        expect(page).to have_content("Remove package from Caseflow")
        expect(page).to have_content("Split package")
        expect(page).to have_content("Merge package")
      end

      context "when Reassign Package is selected" do
        before do
          find(:xpath, '//div[text()="Reassign package"]').click
        end

        it "modal opens with disabled confirm button" do
          expect(page).to have_content(
            "You have selected the following correspondence cases for reassignment to another users. Please confirm your selection(s) below:"
          )
          expect(page).to have_button("Confirm request", disabled: true)
        end

        it "providing a reason enables confirm button" do
          fill_in "Provide a reason for reassignment", with: "Reason for reassignment"
          expect(page).to have_button("Confirm request", disabled: false)
        end
      end
    end
  end
end

# rubocop:enable Layout/LineLength