# frozen_string_literal: true

RSpec.feature("The Correspondence Intake page") do
  context "intake form feature toggle" do
    before :each do
      User.authenticate!(roles: ["Mail Intake"])
      @correspondence_uuid = "123456789"
    end

    it "routes user to /unauthorized if the feature toggle is disabled" do
      FeatureToggle.disable!(:correspondence_queue)
      visit "/queue/correspondence/#{@correspondence_uuid}/intake"
      expect(page).to have_current_path("/unauthorized")
    end

    it "routes to intake if feature toggle is enabled" do
      FeatureToggle.enable!(:correspondence_queue)
      visit "/queue/correspondence/#{@correspondence_uuid}/intake"
      expect(page).to have_current_path("/queue/correspondence/#{@correspondence_uuid}/intake")
    end
  end

  context "intake form shell" do
    before :each do
      FeatureToggle.enable!(:correspondence_queue)
      User.authenticate!(roles: ["Mail Intake"])
      @correspondence_uuid = "123456789"
      visit "/queue/correspondence/#{@correspondence_uuid}/intake"
    end

    it "the intake page exists" do
      expect(page).to have_current_path("/queue/correspondence/#{@correspondence_uuid}/intake")
    end

    it "successfully navigates on cancel link click" do
      click_on("button-Cancel")
      expect(page).to have_current_path("/queue/correspondence")
    end

    it "successfully advances to the second step" do
      click_on("button-continue")
      expect(page).to have_button("Continue")
      expect(page).to have_button("Back")
      expect(page).to have_no_button("Submit")
    end

    it "successfully advances to the final step" do
      click_on("button-continue")
      click_on("button-continue")
      expect(page).to have_button("Submit")
      expect(page).to have_button("Back")
      expect(page).to have_no_button("Continue")
    end

    it "successfully returns to the first step" do
      click_on("button-continue")
      click_on("button-back-button")

      expect(page).to have_button("Continue")
      expect(page).to have_no_button("Back")
      expect(page).to have_no_button("Submit")
    end

    it "successfully returns to the second step" do
      click_on("button-continue")
      click_on("button-continue")
      click_on("button-back-button")

      expect(page).to have_button("Continue")
      expect(page).to have_button("Back")
      expect(page).to have_no_button("Submit")
    end
  end

  context "access 'Tasks not Related to an Appeals'" do
    before :each do
      FeatureToggle.enable!(:correspondence_queue)
      User.authenticate!(roles: ["Mail Intake"])
      @correspondence_uuid = "12345"
      visit "/queue/correspondence/#{@correspondence_uuid}/intake"
    end

    it "Paragraph text appears below the title" do
      click_on("button-continue")
      expect(page).to have_button("+ Add tasks")
      expect(page).to have_text("Add new tasks related to this correspondence or " +
        "to an appeal not yet created in Caseflow.")
    end
  end

  context "The mail team user is able to click an 'add tasks' button" do
    before :each do
      FeatureToggle.enable!(:correspondence_queue)
      User.authenticate!(roles: ["Mail Intake"])
      @correspondence_uuid = "12345"
      visit "/queue/correspondence/#{@correspondence_uuid}/intake"
      click_on("button-continue")
    end

    it "The user can add additional tasks to correspondence by selecting the '+add tasks' button again" do
      click_on("+ Add tasks")
      expect(page).to have_button("+ Add tasks")
    end

    it "Two tasks is the limit for the user" do
      click_on("+ Add tasks")
      click_on("+ Add tasks")
      expect(page).to have_button("+ Add tasks", disabled: true)
    end

    it "Two unrelated tasks have been added." do
      click_on("+ Add tasks")
      expect(page).to have_text("Provide context and instruction on this task")
      expect(page.all(".cf-form-textarea").count).to eq(1)
      click_on("+ Add tasks")
      expect(page.all(".cf-form-textarea").count).to eq(2)
    end

    it "Closes out new section when unrelated tasks have been removed." do
      click_on("+ Add tasks")
      expect(page).to have_text("Provide context and instruction on this task")
      click_on("button-Remove")
      expect(page).to_not have_text("New Tasks")
    end
  end

  context "The user is able to use the autotext feature" do
    before :each do
      FeatureToggle.enable!(:correspondence_queue)
      User.authenticate!(roles: ["Mail Intake"])
      @correspondence_uuid = "12345"
      visit "/queue/correspondence/#{@correspondence_uuid}/intake"
      click_on("button-continue")
      click_on("+ Add tasks")
    end

    it "The user can open the autotext modal" do
      find_by_id("addAutotext").click
      # using clear all button because it's unique to the modal.
      expect(page).to have_text("Clear all")
    end

    it "The user can close the modal with the cancel button." do
      find_by_id("addAutotext").click
      expect(page).to have_text("Clear all")
      find_by_id("Add-autotext-button-id-0").click
      expect(page).to_not have_text("Clear all")
    end

    it "The user can close the modal with the x button located in the top right." do
      find_by_id("addAutotext").click
      expect(page).to have_text("Clear all")
      find_by_id("Add-autotext-button-id-close").click
      expect(page).to_not have_text("Clear all")
    end

    it "The user is able to add autotext" do
      fill_in "Task Information", with: "debug data for autofill"
      expect(find_by_id("Task Information").text).to eq "debug data for autofill"
      find_by_id("addAutotext").click
      first_checkbox_text = ""
      within find_by_id("autotextModal") do
        first_checkbox = all(class: "cf-form-checkbox").first
        first_checkbox_text = first_checkbox.text
        first_checkbox.click
        find_by_id("Add-autotext-button-id-1").click
      end
      expect(find_by_id("Task Information").text).to eq first_checkbox_text
    end

    it "Persists data if the user hits the back button, then returns" do
      find_by_id("addAutotext").click
      first_checkbox_text = ""
      within find_by_id("autotextModal") do
        first_checkbox = all(class: "cf-form-checkbox").first
        first_checkbox_text = first_checkbox.text
        first_checkbox.click
        find_by_id("Add-autotext-button-id-1").click
      end
      click_on("button-back-button")
      click_on("button-continue")
      expect(find_by_id("Task Information").text).to eq first_checkbox_text
    end
  end
end
