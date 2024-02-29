# frozen_string_literal: true

RSpec.feature("The Correspondence Cases page") do
  include CorrespondenceTaskHelpers
  # alias this to avoid the method name collision
  alias_method :create_efolderupload_task, :create_efolderupload_failed_task
  context "correspondence cases unassigned tab" do
    let(:current_user) { create(:user) }
    before :each do
      MailTeamSupervisor.singleton.add_user(current_user)
      User.authenticate!(user: current_user)
    end
    let(:organization) { MailTeam.singleton }
    let(:mail_user) { User.authenticate!(roles: ["Mail Team"]) }
    let(:target_user) { create(:user, css_id: "TARGET_USER") }

    let(:wait_time) { 30 }

    before do
      organization.add_user(mail_user)
      mail_user.reload
    end

    before do
      organization.add_user(target_user)
      target_user.reload
    end

    before do
      Timecop.freeze(Time.zone.local(2020, 5, 15))
      5.times do
        corres_array = (1..4).map { create(:correspondence) }
        task_array = [ReassignPackageTask, RemovePackageTask, SplitPackageTask, MergePackageTask]

        corres_array.each_with_index do |corres, index|
          rpt = ReviewPackageTask.find_by(appeal_id: corres.id)
          task_array[index].create!(
            parent_id: rpt.id,
            appeal_id: corres.id,
            appeal_type: "Correspondence",
            assigned_to: MailTeamSupervisor.singleton,
            assigned_by_id: rpt.assigned_to_id
          )
        end
      end

      # Used to mock a single task to compare task sorting
      ReassignPackageTask.first.correspondence.update!(
        va_date_of_receipt: Date.new(2000, 10, 10),
        updated_by_id: current_user.id
      )
      ReassignPackageTask.last.correspondence.update!(
        va_date_of_receipt: Date.new(2050, 10, 10),
        updated_by_id: current_user.id
      )
      FeatureToggle.enable!(:correspondence_queue)
    end

    before do
      Timecop.freeze(Time.zone.local(2020, 5, 15))
      20.times do
        correspondence = create(:correspondence)
        parent_task = create_correspondence_intake(correspondence, target_user)
        create_efolderupload_task(correspondence, parent_task, user: target_user)
      end
    end

    it "successfully loads the unassigned tab" do
      visit "/queue/correspondence/team?tab=correspondence_unassigned"
      expect(page).to have_content("Correspondence owned by the Mail team are unassigned to an individual:")
      expect(page).to have_content("Assign to mail team user")
      expect(page).to have_button("Assign")
      expect(page).to have_button("Auto assign correspondence")
    end

    it "Verify the mail team user batch assignment with Assign button" do
      visit "/queue/correspondence/team?tab=correspondence_unassigned"
      expect(page).to have_content("Assign to mail team user")
      expect(page).to have_button("Assign", disabled: true)
      expect(page).to have_selector(".cf-select__input")
      all(".cf-select__input").first.click
      find_by_id("react-select-2-option-0").click
      page.execute_script('
        document.querySelectorAll(".cf-form-checkbox input[type=\'checkbox\']").forEach((checkbox, index) => {
          if (index < 3) {
            checkbox.click();
          }
        });
      ')
      expect(page).to have_button("Assign", disabled: false)
      find_by_id("button-Assign").click
      expect(page).to have_content("You have successfully assigned 3 Correspondence to #{mail_user.css_id}.")
      expect(page).to have_content("Please go to your individual queue to see any self-assigned correspondence.")
    end

    it "Verify the mail team user batch assignment with assign button with queue limit" do
      visit "/queue/correspondence/team?tab=correspondence_unassigned"
      expect(page).to have_content("Assign to mail team user")
      expect(page).to have_button("Assign", disabled: true)
      expect(page).to have_selector(".cf-select__input")
      all(".cf-select__input").first.click
      find_by_id("react-select-2-option-1").click
      page.execute_script('
        document.querySelectorAll(".cf-form-checkbox input[type=\'checkbox\']").forEach((checkbox, index) => {
          if (index < 3) {
            checkbox.click();
          }
        });
      ')
      expect(page).to have_button("Assign", disabled: false)
      find_by_id("button-Assign").click
    end
  end

end
