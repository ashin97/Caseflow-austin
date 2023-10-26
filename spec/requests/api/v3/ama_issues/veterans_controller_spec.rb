# frozen_string_literal: true

require "test_prof/recipes/rspec/let_it_be"

# rubocop:disable Layout/LineLength
describe Api::V3::AmaIssues::VeteransController, :postgres, type: :request do
  let_it_be(:api_key) do
    ApiKey.create!(consumer_name: "ApiV3 Test VBMS Consumer").key_string
  end

  let_it_be(:authorization_header) do
    { "Authorization" => "Token #{api_key}" }
  end

  describe "#show" do
    context "when feature is not enabled" do
      before { FeatureToggle.disable!(:api_v3_ama_issues) }
      let!(:vet) { create(:veteran) }

      it "should return 'Not Implemented' error" do
        get(
          "/api/v3/ama_issues/veterans/#{vet.participant_id}",
          headers: authorization_header
        )
        expect(response).to have_http_status(501)
        expect(response.body).to include("Not Implemented")
      end
    end

    context "when feature is enabled" do
      before { FeatureToggle.enable!(:api_v3_ama_issues) }
      after { FeatureToggle.disable!(:api_v3_ama_issues) }

      context "when a veteran is not found" do
        it "should return veteran not found error" do
          get(
            "/api/v3/ama_issues/veterans/9999999999",
            headers: authorization_header
          )
          expect(response).to have_http_status(404)
          expect(response.body).to include("No Veteran found for the given identifier.")
        end
      end

      context "when a veteran is found" do
        context "when a veteran is found - but has no reqeust issues" do
          let(:vet) { create(:veteran) }
          it "should return request issues not found" do
            get(
              "/api/v3/ama_issues/veterans/#{vet.participant_id}",
              headers: authorization_header
            )
            expect(response).to have_http_status(404)
            expect(response.body).to include("No Request Issues found for the given veteran.")
          end
        end

        context "when a veteran is found - but an unexpected error has happened." do
          it "should return veteran not found error" do
            response = JSON.parse("{\"errors\":[{\"status\":\"500\",\"title\":\"Unknown error occured\",\"detail\":\"divided by 0 (Sentry event id: )\"}]}")
            expect(response["errors"].first["status"]).to include("500")
            expect(response["errors"].first["title"]).to include("Unknown error occured")
          end
        end

        context "when a veteran has a legacy appeal" do
          context "when a veteran has multiple request issues with multiple decision issues" do
            let_it_be(:vet) { create(:veteran, file_number: "123456789") }
            let_it_be(:vacols_case) { create(:case, bfcorlid: "123456789S") }
            include_context :multiple_ri_multiple_di
            let_it_be(:reqeust_issue_no_di) { create(:request_issue, veteran_participant_id: vet.participant_id) }
            let_it_be(:request_issue_for_vet_count) { RequestIssue.where(veteran_participant_id: vet.participant_id).count }

            it_behaves_like :it_should_respond_with_legacy_present, true
            it_behaves_like :it_should_respond_with_associated_request_issues, true, true
            it_behaves_like :it_should_respond_with_multiple_decision_issues_per_request_issues, true, true

            include_context :number_of_request_issues_exceeds_paginates_per, true
          end

          context "when a veteran has multiple decision issues with multiple request issues" do
            let_it_be(:vet) { create(:veteran, file_number: "123456789") }
            let_it_be(:vacols_case) { create(:case, bfcorlid: "123456789S") }
            let_it_be(:decision_issues) { create_list(:decision_issue, 2, participant_id: vet.participant_id) }
            include_context :multiple_di_multiple_ri
            let_it_be(:request_issue_for_vet_count) { RequestIssue.where(veteran_participant_id: vet.participant_id).count }

            it_behaves_like :it_should_respond_with_legacy_present, true
            it_behaves_like :it_should_respond_with_associated_request_issues, true, false
            it_behaves_like :it_should_respond_with_same_multiple_decision_issues, true

            include_context :number_of_request_issues_exceeds_paginates_per, true
          end
        end

        context "when a veteran does not have a legacy appeal" do
          context "when a veteran has multiple request issues with multiple decision issues" do
            let_it_be(:vet) { create(:veteran) }
            include_context :multiple_ri_multiple_di
            let_it_be(:reqeust_issue_no_di) { create(:request_issue, veteran_participant_id: vet.participant_id) }
            let_it_be(:request_issue_for_vet_count) { RequestIssue.where(veteran_participant_id: vet.participant_id).count }

            it_behaves_like :it_should_respond_with_legacy_present, false
            it_behaves_like :it_should_respond_with_associated_request_issues, false, true
            it_behaves_like :it_should_respond_with_multiple_decision_issues_per_request_issues, false, true

            include_context :number_of_request_issues_exceeds_paginates_per, false
          end

          context "when a veteran has multiple decision issues with multiple request issues" do
            let_it_be(:vet) { create(:veteran) }
            let_it_be(:decision_issues) { create_list(:decision_issue, 2, participant_id: vet.participant_id) }
            include_context :multiple_di_multiple_ri
            let_it_be(:request_issue_for_vet_count) { RequestIssue.where(veteran_participant_id: vet.participant_id).count }

            it_behaves_like :it_should_respond_with_legacy_present, false
            it_behaves_like :it_should_respond_with_associated_request_issues, false, false
            it_behaves_like :it_should_respond_with_same_multiple_decision_issues, false

            include_context :number_of_request_issues_exceeds_paginates_per, false
          end
        end
      end
    end
  end
end
# rubocop:enable Layout/LineLength
