# frozen_string_literal: true

RSpec.feature "AMA Non-priority Distribution Goals by Docket Levers" do
  let!(:current_user) do
    user = create(:user, css_id: "BVATTWAYNE")
    CDAControlGroup.singleton.add_user(user)
    User.authenticate!(user: user)
  end

  let(:ama_hearings) {Constants.DISTRIBUTION.ama_hearings_start_distribution_prior_to_goals}
  let(:ama_direct_reviews) {Constants.DISTRIBUTION.ama_direct_review_start_distribution_prior_to_goals}
  let(:ama_evidence_submissions) {Constants.DISTRIBUTION.ama_evidence_submission_start_distribution_prior_to_goals}

  let(:ama_hearings_field) {Constants.DISTRIBUTION.ama_hearings_docket_time_goals}
  let(:ama_direct_reviews_field) {Constants.DISTRIBUTION.ama_direct_review_docket_time_goals}
  let(:ama_evidence_submissions_field) {Constants.DISTRIBUTION.ama_evidence_submission_docket_time_goals}

  let(:disabled_color) {"rgba(117, 117, 117, 1)"}
  let(:enabled_color) {"rgba(33, 33, 33, 1)"}

  context "user is in Case Distro Algorithm Control organization but not an admin" do
    scenario "visits the lever control page", type: :feature do
      visit "case-distribution-controls"
      confirm_page_and_section_loaded

      expect(find(:css, "##{ama_hearings}-lever-value > span").native.style('color')).to eq(disabled_color)
      expect(find(:css, "##{ama_direct_reviews}-lever-value > span").native.style('color')).to eq(enabled_color)
      expect(find(:css, "##{ama_evidence_submissions}-lever-value > span").native.style('color')).to eq(disabled_color)

      expect(find(:css, "##{ama_hearings}-lever-toggle > div > span").native.style('color')).to eq(disabled_color)
      expect(find(:css, "##{ama_direct_reviews}-lever-toggle > div > span").native.style('color')).to eq(disabled_color)
      expect(find(:css, "##{ama_evidence_submissions}-lever-toggle > div > span").native.style('color')).to eq(disabled_color)
    end
  end

  context "user is a Case Distro Algorithm Control admin" do
    before do
      OrganizationsUser.make_user_admin(current_user, CDAControlGroup.singleton)
    end

    scenario "visits the lever control page" do
      visit "case-distribution-controls"
      confirm_page_and_section_loaded

      expect(page).to have_field("#{ama_hearings_field}", readonly: true)
      expect(page).to have_field("#{ama_direct_reviews_field}", readonly: false)
      expect(page).to have_field("#{ama_evidence_submissions_field}", readonly: true)

      expect(page).to have_button("toggle-switch-#{ama_hearings}", disabled: true)
      expect(page).to have_button("toggle-switch-#{ama_direct_reviews}", disabled: true)
      expect(page).to have_button("toggle-switch-#{ama_evidence_submissions}", disabled: true)
    end

    scenario "changes the AMA Direct Review lever value to an invalid input" do
      visit "case-distribution-controls"
      confirm_page_and_section_loaded

      fill_in ama_direct_reviews_field, with: "ABC"
      expect(page).to have_field(ama_direct_reviews_field, with: '')
    end

    scenario "changes the AMA Direct Review lever value to a valid input" do
      visit "case-distribution-controls"
      confirm_page_and_section_loaded

      fill_in ama_direct_reviews_field, with: "365"
      expect(page).to have_field(ama_direct_reviews_field, with: '365')
    end

    scenario "lever history displays on page" do
      visit "case-distribution-controls"
      confirm_page_and_section_loaded
      fill_in ama_direct_reviews_field, with: "123"
      find("#LeversSaveButton").click
      find(".cf-submit").click

      expect(page).to have_css(".entry-updated-values > ol > li", text: "123")

    end
  end
end

def confirm_page_and_section_loaded
  expect(page).to have_content(COPY::CASE_DISTRIBUTION_DOCKET_TIME_GOALS_SECTION_TITLE)
  expect(page).to have_content("AMA Hearings")
  expect(page).to have_content("AMA Direct Review")
  expect(page).to have_content("AMA Evidence Submission")
end
