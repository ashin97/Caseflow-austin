# frozen_string_literal: true

RSpec.describe CaseDistributionLeversController, :all_dbs, type: :controller do
  let!(:lever_user) { create(:lever_user) }

  let!(:lever1) {create(:case_distribution_lever,
    item: "lever_1",
    title: "lever 1",
    description: "This is the first lever. It is a boolean with the default value of true. Therefore there should be a two radio buttons that display true and false as the example with true being the default option chosen. This lever is active so it should be in the active lever section",
    data_type: "boolean",
    value: true,
    unit: ""
  )}
  let!(:lever2) {create(:case_distribution_lever,
    item: "lever_2",
    title: "Lever 2",
    description: "This is the second lever. It is a number data type with the default value of 42. Therefore there should be a number input that displays 42 and 'days' as the unit. This lever is active so it should be in the active lever section",
    data_type: "number",
    value: 55,
    unit: "Days"
  )}
  let!(:radio_lever) {create(:case_distribution_lever,
    item: "radio_lever",
    title: "Radio Lever",
    description: "This is the second lever. It is a number data type with the default value of 42. Therefore there should be a number input that displays 42 and 'days' as the unit. This lever is active so it should be in the active lever section",
    data_type: Constants.LEVER_ATTRIBUTES.RADIO,
    value: Constants.LEVER_ATTRIBUTES.VALUE,
    unit: "Days",
    options: [
      {
        item: Constants.LEVER_ATTRIBUTES.VALUE,
        data_type: 'number',
        value: 55,
        text: 'Attempt distribution to current judge for max of:',
        unit: 'days'
      },
      {
        item: Constants.LEVER_ATTRIBUTES.INFINITE,
        data_type: '',
        value: Constants.LEVER_ATTRIBUTES.INFINITE,
        text: 'Always distribute to current judge',
        unit: ''
      },
      {
        item: Constants.LEVER_ATTRIBUTES.OMIT,
        data_type: '',
        value: Constants.LEVER_ATTRIBUTES.OMIT,
        text: 'Omit variable from distribution rules',
        unit: ''
      }
    ]
  )}
  let!(:combo_lever) {create(:case_distribution_lever,
    item: "lever_2",
    title: "Lever 2",
    description: "This is the second lever. It is a number data type with the default value of 42. Therefore there should be a number input that displays 42 and 'days' as the unit. This lever is active so it should be in the active lever section",
    data_type: Constants.LEVER_ATTRIBUTES.COMBO,
    value: 770,
    unit: 'days',
    options: [
      {
        item: 'option_1',
        data_type: 'boolean',
        value: true,
        text: 'This feature is turned on or off',
        unit: ''
      }
    ]
  )}

  let!(:audit_lever_entry1) {create(:case_distribution_audit_lever_entry,
    user: lever_user,
    user_name: "john smith",
    created_at: "2023-07-01 10:10:01",
    title: 'Lever 1',
    previous_value: 10,
    update_value: 42,
    case_distribution_lever: lever2
  )}
  let!(:audit_lever_entry2) {create(:case_distribution_audit_lever_entry,
    user: lever_user,
    user_name: "john smith",
    created_at: "2023-07-01 10:11:01",
    title: 'Lever 1',
    previous_value: 42,
    update_value: 55,
    case_distribution_lever: lever2
  )}
  let!(:old_audit_lever_entry) {create(:case_distribution_audit_lever_entry,
    user: lever_user,
    user_name: "john smith",
    created_at: "2020-07-01 10:11:01",
    title: 'Lever 1',
    previous_value: 42,
    update_value: 55,
    case_distribution_lever: lever2
  )}

  let!(:levers) {[lever1, lever2, radio_lever, combo_lever]}
  let!(:lever_history) {[audit_lever_entry1, audit_lever_entry2]}

  before do
    CDAControlGroup.singleton.add_user(lever_user)
  end

  describe "GET acd_lever_index", :type => :request do
    it "redirects the user to the unauthorized page if they are not authorized" do
      User.authenticate!(user: create(:user))
      get "/acd-controls"

      expect(response.status).to eq 302
      expect(response.body).to match(/unauthorized/)
    end

    it "renders a page with the correct levers, lever history, and user admin status when user is allowed to view the page" do
      User.authenticate!(user: lever_user)
      get "/acd-controls"

      request_levers = @controller.view_assigns["acd_levers"]
      request_history = @controller.view_assigns["acd_history"]
      request_user_is_an_admin = @controller.view_assigns["user_is_an_acd_admin"]

      expect(response.status).to eq 200
      expect(request_levers.count).to eq(4)
      expect(request_levers).to include(lever1)
      expect(request_levers).to include(lever2)
      expect(request_history.count).to eq(2)
      expect(request_history).to include(audit_lever_entry1)
      expect(request_history).to include(audit_lever_entry2)
      expect(request_history).not_to include(old_audit_lever_entry)
      expect(request_user_is_an_admin).to be_falsey
    end

    it "renders a page with the correct levers, lever history, and user admin status when user is an admin" do
      User.authenticate!(user: lever_user)
      OrganizationsUser.make_user_admin(lever_user, CDAControlGroup.singleton)
      get "/acd-controls"

      request_levers = @controller.view_assigns["acd_levers"]
      request_history = @controller.view_assigns["acd_history"]
      request_user_is_an_admin = @controller.view_assigns["user_is_an_acd_admin"]

      expect(response.status).to eq 200
      expect(request_levers.count).to eq(4)
      expect(request_levers).to include(lever1)
      expect(request_levers).to include(lever2)
      expect(request_history.count).to eq(2)
      expect(request_history).to include(audit_lever_entry1)
      expect(request_history).to include(audit_lever_entry2)
      expect(request_history).not_to include(old_audit_lever_entry)
      expect(request_user_is_an_admin).to be_truthy
    end
  end

  describe "GET acd_lever_index with case-distribution-controls path", :type => :request do
    it "redirects the user to the unauthorized page if they are not authorized" do
      User.authenticate!(user: create(:user))
      get "/case-distribution-controls"

      expect(response.status).to eq 302
      expect(response.body).to match(/unauthorized/)
    end

    it "renders a page with the correct levers, lever history, and user admin status when user is allowed to view the page" do
      User.authenticate!(user: lever_user)
      get "/case-distribution-controls"

      request_levers = @controller.view_assigns["acd_levers"]
      request_history = @controller.view_assigns["acd_history"]
      request_user_is_an_admin = @controller.view_assigns["user_is_an_acd_admin"]

      expect(response.status).to eq 200
      expect(request_levers.count).to eq(25)
      expect(request_levers).to include(lever1)
      expect(request_levers).to include(lever2)
      expect(request_history.count).to eq(2)
      expect(request_history).to include(audit_lever_entry1)
      expect(request_history).to include(audit_lever_entry2)
      expect(request_history).not_to include(old_audit_lever_entry)
      expect(request_user_is_an_admin).to be_falsey
    end

    it "renders a page with the correct levers, lever history, and user admin status when user is an admin" do
      User.authenticate!(user: lever_user)
      OrganizationsUser.make_user_admin(lever_user, CDAControlGroup.singleton)
      get "/case-distribution-controls"

      request_levers = @controller.view_assigns["acd_levers"]
      request_history = @controller.view_assigns["acd_history"]
      request_user_is_an_admin = @controller.view_assigns["user_is_an_acd_admin"]

      expect(response.status).to eq 200
      expect(request_levers.count).to eq(25)
      expect(request_levers).to include(lever1)
      expect(request_levers).to include(lever2)
      expect(request_history.count).to eq(2)
      expect(request_history).to include(audit_lever_entry1)
      expect(request_history).to include(audit_lever_entry2)
      expect(request_history).not_to include(old_audit_lever_entry)
      expect(request_user_is_an_admin).to be_truthy
    end
  end

  describe "POST update_levers_and_history" do
    it "redirects the user to the unauthorized page if they are not authorized" do
      User.authenticate!(user: create(:user))
      post "update_levers_and_history"

      expect(response.status).to eq 302
      expect(response.body).to match(/unauthorized/)
    end

    it "updates all provided levers" do
      User.authenticate!(user: lever_user)
      OrganizationsUser.make_user_admin(lever_user, CDAControlGroup.singleton)

      updated_lever_1 = {
        id: lever1.id,
        item: lever1.item,
        title: lever1.title,
        description: lever1.description,
        data_type: lever1.data_type,
        value: false,
        unit: lever1.unit
      }

      save_params = {
        current_levers: [updated_lever_1, lever2, radio_lever, combo_lever].to_json,
        audit_lever_entries: [].to_json
      }

      post "update_levers_and_history", params: save_params

      expect(CaseDistributionLever.find(lever1.id).value).to eq("f")
      expect(CaseDistributionLever.all).to include(lever2)
      expect(CaseDistributionLever.find(lever1.id).value).to_not eq("t")
      expect(JSON.parse(response.body)["successful"]).to be_truthy
      expect(JSON.parse(response.body)["errors"]).to be_empty
    end

    it "returns an error message then the format of a lever in invalid" do
      User.authenticate!(user: lever_user)
      OrganizationsUser.make_user_admin(lever_user, CDAControlGroup.singleton)

      invalid_updated_lever_1 = {
        id: lever1.id,
        item: 1,
        title: nil,
        description: lever1.description,
        data_type: nil,
        value: false,
        unit: lever1.unit
      }

      save_params = {
        current_levers: [invalid_updated_lever_1, lever2, radio_lever, combo_lever].to_json,
        audit_lever_entries: [].to_json
      }

      post "update_levers_and_history", params: save_params

      expect(CaseDistributionLever.find(lever1.id).value).to eq("t")
      expect(CaseDistributionLever.all).to include(lever2)
      expect(CaseDistributionLever.find(lever1.id).value).to_not eq("f")
      expect(JSON.parse(response.body)["successful"]).to be_falsey
      expect(JSON.parse(response.body)["errors"]).not_to be_empty
    end

    it "creates records for the provided audit lever entries in the database" do
      User.authenticate!(user: lever_user)
      OrganizationsUser.make_user_admin(lever_user, CDAControlGroup.singleton)
      created_at_date = Time.now
      audit_lever_entry3 = {
        case_distribution_lever_id: lever1.id,
        user_id: lever_user.id,
        user_name: lever_user.full_name,
        title: lever1.title,
        created_at: created_at_date
      }
      audit_lever_entry4 = {
        case_distribution_lever_id: lever2.id,
        user_id: lever_user.id,
        user_name: lever_user.full_name,
        title: lever2.title,
        created_at: created_at_date
      }

      save_params = {
        current_levers: [].to_json,
        audit_lever_entries: [audit_lever_entry3, audit_lever_entry4].to_json
      }

      expect(CaseDistributionAuditLeverEntry.past_year.count).to eq(2)

      post "update_levers_and_history", params: save_params

      expect(CaseDistributionAuditLeverEntry.past_year.count).to eq(4)
      expect(JSON.parse(response.body)["successful"]).to be_truthy
      expect(JSON.parse(response.body)["errors"]).to be_empty.or be_nil
    end

    it "returns an error message when the format of the audit lever entry is invalid" do
      User.authenticate!(user: lever_user)
      OrganizationsUser.make_user_admin(lever_user, CDAControlGroup.singleton)
      created_at_date = Time.now
      audit_lever_entry3 = {
        case_distribution_lever_id: lever1.id,
        user_id: lever_user.id,
        user_name: lever_user.full_name,
        title: lever1.title,
        created_at: created_at_date
      }
      audit_lever_entry4 = {
        case_distribution_lever_id: nil,
        user_id: lever_user.id,
        user_name: lever_user.full_name,
        title: lever2.title,
        created_at: created_at_date
      }

      save_params = {
        current_levers: [].to_json,
        audit_lever_entries: [audit_lever_entry3, audit_lever_entry4].to_json
      }

      expect(CaseDistributionAuditLeverEntry.past_year.count).to eq(2)

      post "update_levers_and_history", params: save_params

      expect(CaseDistributionAuditLeverEntry.past_year.count).to eq(2)
      expect(JSON.parse(response.body)["successful"]).to be_falsey
      expect(JSON.parse(response.body)["errors"]).not_to be_empty
    end

    it "updates a radio lever" do
      User.authenticate!(user: lever_user)
      OrganizationsUser.make_user_admin(lever_user, CDAControlGroup.singleton)

      expect(CaseDistributionLever.all).to eq(levers)
      updated_radio_lever = {
        id: radio_lever.id,
        item: radio_lever.item,
        title: radio_lever.title,
        description: radio_lever.description,
        data_type: radio_lever.data_type,
        value: Constants.LEVER_ATTRIBUTES.VALUE,
        unit: radio_lever.unit,
        options: [
          {
            item: Constants.LEVER_ATTRIBUTES.VALUE,
            data_type: 'number',
            value: 21,
            text: 'Attempt distribution to current judge for max of:',
            unit: 'days'
          },
          {
            item: Constants.LEVER_ATTRIBUTES.INFINITE,
            data_type: '',
            value: Constants.LEVER_ATTRIBUTES.INFINITE,
            text: 'Always distribute to current judge',
            unit: ''
          },
          {
            item: Constants.LEVER_ATTRIBUTES.OMIT,
            data_type: '',
            value: Constants.LEVER_ATTRIBUTES.OMIT,
            text: 'Omit variable from distribution rules',
            unit: ''
          }
        ]
      }

      save_params = {
        current_levers: [lever1, lever2, updated_radio_lever, combo_lever].to_json,
        audit_lever_entries: [].to_json
      }

      post "update_levers_and_history", params: save_params

      rl = CaseDistributionLever.find(radio_lever.id)
      expect(rl.value).to eq("value")
      expect(rl.value).to_not eq(Constants.LEVER_ATTRIBUTES.INFINITE)
      expect(rl.options.find {|option| option["item"] == rl.value}["value"]).to eq(21)
      # binding.pry
      expect(JSON.parse(response.body)["successful"]).to be_truthy
      expect(JSON.parse(response.body)["errors"]).to be_empty
    end

    it "updates a combination lever" do
      User.authenticate!(user: lever_user)
      OrganizationsUser.make_user_admin(lever_user, CDAControlGroup.singleton)

      expect(CaseDistributionLever.all).to eq(levers)
      updated_combo_lever = {
        id: combo_lever.id,
        item: combo_lever.item,
        title: combo_lever.title,
        description: combo_lever.description,
        data_type: combo_lever.data_type,
        value: 66,
        unit: combo_lever.unit,
        options: [
          {
            item: 'option_1',
            data_type: 'boolean',
            value: true,
            text: 'This feature is turned on or off',
            unit: ''
          }
        ]

      }

      save_params = {
        current_levers: [lever1, lever2, radio_lever, updated_combo_lever].to_json,
        audit_lever_entries: [].to_json
      }

      post "update_levers_and_history", params: save_params

      cl = CaseDistributionLever.find(combo_lever.id)

      expect(cl.value).to eq("66")
      expect(cl.value).to_not eq("f")
      expect(cl.options.find {|option| option["item"] == "option_1"}["value"]).to eq(true)
      expect(JSON.parse(response.body)["successful"]).to be_truthy
      expect(JSON.parse(response.body)["errors"]).to be_empty
    end


  end

end
