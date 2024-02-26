# frozen_string_literal: true

class TranscriptFileIssues < ActionMailer::Base
  default from: "Board of Veterans' Appeals <BoardofVeteransAppealsHearings@messages.va.gov>"
  default to: "BVAHearingTeam@VA.gov"
  default cc: "OITAppealsHelpDesk@va.gov"
  layout "transcript_file_issues"

  def send_issue_details(details)
    @details = details
    @subject = "File #{details[:action]} Error - #{details[:provider]} #{details[:docket_number]}"
    mail(subject: @subject) do |format|
      format.html { render "transcript_file_issues" }
    end
  end
end
