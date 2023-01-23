# frozen_string_literal: true

RSpec.feature "CAVC Dashboard", :all_dbs do
  let(:legacy_appeal) { create(:legacy_appeal, :with_veteran, vacols_case: create(:case)) }
  let(:non_cavc_appeal) { create(:appeal, :direct_review_docket) }
  let(:cavc_appeal) { create(:appeal, :direct_review_docket, :type_cavc_remand) }
  let(:authorized_user) { create(:user) }

  context "user is a member of OAI or OCC organizations" do
    before do
      User.authenticate!(user: authorized_user)
    end

    it "dashboard redirects if the appeal is a Legacy Appeal" do
      visit "/queue/appeals/#{legacy_appeal.vacols_id}/cavc_dashboard"
      expect(page).to have_text legacy_appeal.veteran.name.to_s
      expect(page).to have_current_path "/queue/appeals/#{legacy_appeal.vacols_id}"
    end

    it "dashboard redirects if the appeal does not have an associated cavcRemand" do
      visit "/queue/appeals/#{non_cavc_appeal.uuid}/cavc_dashboard"
      expect(page).to have_text non_cavc_appeal.veteran.name.to_s
      expect(page).to have_current_path "/queue/appeals/#{non_cavc_appeal.uuid}"
    end

    # this test will need to be updated once CavcDashboard component is built
    it "dashboard loads if the appeal has an associated cavcRemand" do
      visit "/queue/appeals/#{cavc_appeal.uuid}/cavc_dashboard"
      expect(page).to have_text "CAVC appeals for #{cavc_appeal.veteran.name}"
    end
  end
end
