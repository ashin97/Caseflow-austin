# frozen_string_literal: true

RSpec.feature("Correspondence Intake submission") do
  include CorrespondenceHelpers

  context "user associates correspondence with prior mail" do
    describe "success" do
      it "displays a success banner and links the correspondence" do
        visit_intake_form_with_correspondence_load
        associate_with_prior_mail_radio_options[:yes].click
        page.all(".cf-form-checkbox")[1].click
        click_button("Continue")
        click_button("Continue")
        click_button("Submit")
        click_button("Confirm")
        using_wait_time(10) do
          expect(page).to have_content("You have successfully submitted a correspondence record")
        end
        expect(Correspondence.first.related_correspondences).to eq([Correspondence.second])
      end
    end
  end

  context "user selects completed mail tasks" do
    describe "success" do
      # pending feature
    end
  end

  context "user add tasks not related to an appeal" do
    describe "success" do
      # pending feature
    end

    describe "failure" do
      # pending feature
    end
  end

  context "user adds tasks related to an appeal" do
    describe "success" do
      it "displays a success banner, links the appeal, and creates the task" do
        visit_intake_form_step_2_with_appeals
        existing_appeal_radio_options[:yes].click
        using_wait_time(15) do
          within ".cf-case-list-table" do
            page.all(".cf-form-checkbox").last.click
          end
        end
        all("#reactSelectContainer")[0].click
        find_by_id("react-select-2-option-1").click
        find_by_id("content").fill_in with: "Correspondence Text"
        click_button("Continue")
        click_button("Submit")
        click_button("Confirm")
        using_wait_time(10) do
          expect(page).to have_content("You have successfully submitted a correspondence record")
        end
        expect(Correspondence.first.appeals).to eq([Appeal.fifth])
        expect(Correspondence.first.appeals[0].tasks.pluck(:type)).to include("ClearAndUnmistakeableErrorMailTask")
      end
    end

    describe "failure" do
      it "displays a failure banner, and does not link appeal" do
        # this fails because the seed appeal has no root task
        visit_intake_form_step_2_with_appeals_without_initial_tasks
        existing_appeal_radio_options[:yes].click
        using_wait_time(15) do
          within ".cf-case-list-table" do
            page.all(".cf-form-checkbox").last.click
          end
        end
        all("#reactSelectContainer")[0].click
        find_by_id("react-select-2-option-1").click
        find_by_id("content").fill_in with: "Correspondence Text"
        click_button("Continue")
        click_button("Submit")
        click_button("Confirm")
        using_wait_time(10) do
          expect(page).to have_content("The correspondence's documents have failed to upload to the eFolder")
        end
        expect(Correspondence.first.appeals).to eq([])
      end
    end
  end

  context "user waives evidence submission window task on an appeal" do
    describe "success" do
      it "completes the evidence submission window task" do
        active_evidence_submissions_tasks
        existing_appeal_radio_options[:yes].click
        using_wait_time(10) do
          page.all(".checkbox-wrapper-1").find(".cf-form-checkbox").first.click
        end
        find('label', text: 'Waive Evidence Window').click
        find_by_id("waiveReason").fill_in with: "test waive note"
        click_button("Continue")
        find(".cf-pdf-external-link-icon").click
        using_wait_time(15) do
          page.switch_to_window(page.windows.last)
          expect(page).to have_content("Evidence Submission Window Task")
        end
        page.switch_to_window(page.windows.first)
        click_button("Submit")
        click_button("Confirm")
        using_wait_time(15) do
          expect(page).to have_content("You have successfully submitted a correspondence record")
        end
        page.switch_to_window(page.windows.last)
        refresh
        using_wait_time(15) do
          page.switch_to_window(page.windows.last)
          expect(page).to have_no_content("Evidence Submission Window Task")
        end
      end
    end
  end
end