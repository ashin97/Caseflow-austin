# frozen_string_literal: true

RSpec.feature "SpecialCaseMovementTask", :all_dbs do
  let(:scm_user) { create(:user) }

  let(:judge_user) { create(:user) }
  let!(:vacols_judge) { create(:staff, :judge_role, sdomainid: judge_user.css_id) }
  let!(:judgeteam) { JudgeTeam.create_for_judge(judge_user) }
  let(:veteran) { create(:veteran, first_name: "Samuel", last_name: "Purcell") }
  let(:ssn) { Generators::Random.unique_ssn }

  let(:appeal) { create(:legacy_appeal, vacols_case: create(:case, bfcorlid: "#{ssn}S")) }
  let(:root_task) { create(:root_task, appeal: appeal) }
  let(:distribution_task) { create(:distribution_task, parent: root_task) }
  let(:hearing_task) { create(:hearing_task, parent: distribution_task) }

  before do
    SpecialCaseMovementTeam.singleton.add_user(scm_user)
    User.authenticate!(user: scm_user)
  end
  describe "Accessing task actions" do
    context "With the Appeal in the right state" do
      it "successfully assigns the task to judge when blocked" do
        visit("queue/appeals/#{hearing_task.appeal.external_id}")
        dropdown = find(".cf-select__control", text: COPY::TASK_ACTION_DROPDOWN_BOX_LABEL)
        dropdown.click
        expect(page).to have_content(Constants.TASK_ACTIONS.BLOCKED_SPECIAL_CASE_MOVEMENT_LEGACY.label)
      end

      xit "successfully assigns the task to judge without blocked" do
        visit("queue/appeals/#{distribution_task.appeal.external_id}")
        dropdown = find(".cf-select__control", text: COPY::TASK_ACTION_DROPDOWN_BOX_LABEL)
        dropdown.click
        expect(page).to have_content(Constants.TASK_ACTIONS.SPECIAL_CASE_MOVEMENT_LEGACY.label)
      end

      it "Checking validations on hearing task is cancelled and case assigns to judge" do
        visit("/queue")
        visit("/queue/appeals/#{hearing_task.appeal.external_id}")
        prompt = COPY::TASK_ACTION_DROPDOWN_BOX_LABEL
        text = Constants.TASK_ACTIONS.BLOCKED_SPECIAL_CASE_MOVEMENT_LEGACY.label
        click_dropdown(prompt: prompt, text: text)

        # check modal content
        expect(page).to have_content(format(COPY::BLOCKED_SPECIAL_CASE_MOVEMENT_PAGE_SUBTITLE))

        expect(page).to have_button("Continue", disabled: true)

        page.all(".cf-form-radio-option > label")[1].click
        expect(page).to have_button("Continue", disabled: true)

        # fill out instructions
        fill_in("cancellationInstructions", with: "instructions")
        expect(page).to have_button("Continue", disabled: false)

        # remove instructions in text field
        fill_in("cancellationInstructions", with: "")
        expect(page).to have_button("Continue", disabled: true)

        click_button "Cancel"
        expect(page).to have_content "Currently active tasks"
      end
    end
  end
end
