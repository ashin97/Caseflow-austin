# frozen_string_literal: true

class ClaimHistoryEvent
  attr_reader :task_id, :event_type, :event_date, :assigned_at, :days_waiting,
              :veteran_file_number, :claim_type, :claimant_name, :facility,
              :benefit_type, :issue_type, :issue_description, :decision_date,
              :disposition, :decision_description, :withdrawal_request_date,
              :task_status, :disposition_date, :intake_completed_date, :event_user_name

  class << self
    def from_change_data(event_type, change_data)
      new(event_type, change_data)
    end

    # TODO: This is not amazing, but I guess the service class has to manage not creating more than 1 or 2
    def create_completed_disposition_event(change_data)
      if change_data["disposition"]
        from_change_data(:completed_disposition, change_data)
      end
    end

    def create_claim_creation_event(change_data)
      from_change_data(:claim_creation, change_data.merge("event_date" => change_data["intake_completed_at"]))
    end

    # TODO: This method only creates and event for the current state
    def old_create_status_events(change_data)
      event_type = task_status_to_event_type(change_data["task_status"])
      from_change_data(event_type, change_data)
    end

    # TODO: This is not great since it's more DB calls inside of the loop
    def no_database_create_status_events(change_data)
      status_events = []
      task = Task.find(change_data["task_id"])
      # TODO: Might also need to set the user data to System for all of these
      versions = task.versions
      if versions.present?
        first_version, *rest_of_versions = task.versions

        # Assume that if the dates are equal then it should be a assigned -> on_hold status event that is recorded
        # Due to the way intake is processed and shouldn't be recorded
        if first_version.changeset["updated_at"][0].round != first_version.changeset["updated_at"][1].round
          status_events.push event_from_version(first_version, 0, change_data)
        end

        # status_events.push event_from_version(first_version, 0, change_data)
        status_events.push event_from_version(first_version, 1, change_data)

        rest_of_versions.map do |version|
          status_events.push event_from_version(version, 1, change_data)
        end
      else
        # No versions so just make one with the current status?
        event_type = task_status_to_event_type(change_data["task_status"])
        # Probably need to set event_date here as well to the intake date or created at date?
        status_events.push from_change_data(event_type, change_data)
      end

      status_events
    end

    # TODO: Implement this based on the database query if possible
    def database_create_status_events(change_data)
      change_data
    end

    def create_issue_events(change_data)
      issue_events = []
      # puts change_data["request_issue_update_id"].inspect
      # puts change_data["after_request_issue_ids"].inspect
      # puts change_data["before_request_issue_ids"].inspect
      # puts change_data["withdrawn_request_issue_ids"].inspect
      # puts change_data["edited_request_issue_ids"].inspect

      # TODO: before request issue ids does NOT contain withdrawn issues, but after issues does
      # This is definitely not correct
      before_request_issue_ids = change_data["before_request_issue_ids"].scan(/\d+/).map(&:to_i)
      after_request_issue_ids = change_data["after_request_issue_ids"].scan(/\d+/).map(&:to_i)
      withdrawn_request_issue_ids = change_data["withdrawn_request_issue_ids"].scan(/\d+/).map(&:to_i)
      edited_request_issue_ids = change_data["edited_request_issue_ids"].scan(/\d+/).map(&:to_i)
      # added_request_issue_ids = (after_request_issue_ids - before_request_issue_ids)
      removed_request_issue_ids = (before_request_issue_ids - after_request_issue_ids)

      update_user_name = change_data["update_user_name"]
      update_time = change_data["request_issue_update_time"]
      updates_hash = {
        "event_date" => update_time,
        "event_user_name" => update_user_name,
        "user_facility" => change_data["update_user_regional_office"] ||
                           change_data["update_user_station_id"]
      }

      # Possibly might move this block external to the updates and let each row handle the addition based on the request issues created at date?
      # added_request_issue_ids.map do |added_issue_id|
      #   issue_data_hash = retrieve_issue_data(added_issue_id, "adding")
      #   # puts "should be adding an event for added issue with these values:"
      #   # puts issue_data_hash.inspect
      #   # Hack to avoid adding an event for withdrawn issue because of weirdness in request issues updates
      #   if issue_data_hash
      #     issue_events.push from_change_data(:added_issue, change_data.merge(issue_data_hash))
      #   end
      # end

      # # TODO: Move these blocks into a helper that takes the ids and type and returns an array probably
      # withdrawn_request_issue_ids.map do |withdrawn_issue_id|
      #   withdrawn_hash = updates_hash.merge(retrieve_issue_data(withdrawn_issue_id))

      #   # TODO: Withdrawn is possibly special and should be the withdrawn date instead of request issue updates created at?

      #   issue_events.push from_change_data(:withdrew_issue, change_data.merge(withdrawn_hash))
      # end

      # removed_request_issue_ids.map do |removed_issue_id|
      #   removed_hash = updates_hash.merge(retrieve_issue_data(removed_issue_id))
      #   issue_events.push from_change_data(:removed_issue, change_data.merge(removed_hash))
      # end

      # edited_request_issue_ids.map do |edited_issue_id|
      #   edited_hash = updates_hash.merge(retrieve_issue_data(edited_issue_id))
      #   issue_events.push from_change_data(:added_decision_date, change_data.merge(edited_hash))
      # end

      # Adds events to the issue events array
      # TODO: Withdrawn might need to add withdrawn date to the updates hash before sending it in
      process_issue_ids!(withdrawn_request_issue_ids, :withdrew_issue, change_data, updates_hash, issue_events)
      process_issue_ids!(removed_request_issue_ids, :removed_issue, change_data, updates_hash, issue_events)
      process_issue_ids!(edited_request_issue_ids, :added_decision_date, change_data, updates_hash, issue_events)

      # puts "event_types added for request_issue_id: #{change_data['request_issue_update_id']}"
      # puts issue_events.map(&:event_type).inspect

      issue_events
    end

    # This is a mutating function of the issue_events array
    def process_issue_ids!(request_issue_ids, event_type, change_data, updates_hash, issue_events)
      request_issue_ids.each do |request_issue_id|
        request_issue_data = updates_hash.merge(retrieve_issue_data(request_issue_id))
        issue_events.push from_change_data(event_type, change_data.merge(request_issue_data))
      end
    end

    def create_add_issue_event(change_data)
      # puts change_data["intake_completed_at"]
      # puts change_data["request_issue_created_at"]
      # puts change_data["intake_user_name"]
      # puts change_data["update_user_name"]

      # Make a guess that it was the same transaction as intake. If not it was a probably an update
      same_transaction = (change_data["intake_completed_at"].to_datetime -
                          change_data["request_issue_created_at"].to_datetime).abs < 1
      event_hash = if same_transaction
                     {
                       "event_date" => change_data["request_issue_created_at"],
                       "event_user_name" => change_data["intake_user_name"],
                       "user_facility" => change_data["intake_user_regional_office"] ||
                         change_data["intake_user_station_id"]
                     }
                   else
                     {
                       "event_date" => change_data["request_issue_created_at"],
                       "event_user_name" => change_data["update_user_name"],
                       "user_facility" => change_data["update_user_regional_office"] ||
                         change_data["update_user_station_id"]
                     }
                   end
      # data_hash = { "event_date" => change_data["request_issue_created_at"], "event_user_name" => event_user_name }

      from_change_data(:added_issue, change_data.merge(event_hash))
    end

    private

    # TODO: Still needs work
    # def attributes_from_change_history_data(change_data)
    #   # Set attributes based on change data
    #   attributes = {
    #     task_id: change_data["task_id"],
    #     task_status: change_data["task_status"],
    #     intake_completed_date: change_data["completed_at"],

    #     # TODO: This is going to change based on event type
    #     event_date: change_data["event_date"],

    #     # Event type might affect the issue fields as well as the decision date and disposition.
    #     # TODO: Currently adds another database call to RequestIssue which is bad.
    #     issue_type: change_data["nonrating_issue_category"],
    #     issue_description: change_data["nonrating_issue_description"],
    #     decision_date: change_data["decision_date"],

    #     benefit_type: change_data["request_issue_benefit_type"],
    #     disposition: change_data["disposition"],
    #     disposition_date: change_data["caseflow_decision_date"],
    #     decision_description: change_data["decision_description"],

    #     # This is going to be the same for all request issue update events
    #     withdrawal_request_date: change_data["request_issue_update_time"],

    #     # TODO: Figure out what to do with this Probably depends on event_type.
    #     event_user: change_data["eventUser"]
    #   }

    #   # Return the attributes hash
    #   attributes
    # end

    def retrieve_issue_data(request_issue_id, type = "not_add")
      # TODO: If this fails for some reason what do I do?
      # Example: The thing was removed so it's gone now should I just nullsafe and return nulls?
      # TODO: This also does not work if the issue has changed since the update could
      # have changed in a different request issue update. So this is a guess at best.
      request_issue = if type == "not_add"
                        RequestIssue.find_by(id: request_issue_id)
                      else
                        RequestIssue.find_by(id: request_issue_id, closed_status: nil)
                      end
      # Gross
      if request_issue
        {
          "nonrating_issue_category" => request_issue.nonrating_issue_category,
          "nonrating_issue_description" => request_issue.nonrating_issue_description,
          "decision_date" => request_issue.decision_date
        }
      end
    end

    def task_status_to_event_type(task_status)
      if task_status == "in_progress" || task_status == "assigned"
        # "Claim Status - In Progress"
        :in_progress
      elsif task_status == "on_hold"
        # "Claim Status - Incomplete"
        :incomplete
      else
        # "Claim Closed"
        :completed
      end
    end

    def event_from_version(version, index, change_data)
      changes = version.changeset
      event_type = task_status_to_event_type(changes["status"][index])
      event_date = changes["updated_at"][index]
      event_date_hash = { "event_date" => event_date, "event_user_name" => "System" }
      from_change_data(event_type, change_data.merge(event_date_hash))
    end
  end

  def initialize(event_type, change_data)
    set_attributes_from_change_history_data(event_type, change_data)
  end

  # def to_csv_array
  #   [
  #     @task_id, @event_type, @event_date, @event_user,
  #     @benefit_type, @issue_type, @issue_description, @decision_date,
  #     @disposition, @decision_description, @withdrawal_request_date,
  #     @task_status, @disposition_date, @intake_completed_date
  #   ]
  # end

  def to_csv_array
    [
      @veteran_file_number, @claimant_name, build_task_url, task_status_mapper,
      days_waiting, readable_claim_type, @facility, user_name_helper, format_date_string(@event_date),
      event_type_to_readable_name, status_information, issue_information, disposition_information
    ]
  end

  private

  # TODO: Convert this into a hash that gets passed to new(attrs)
  # Maybe not idk
  # Probably should but I'm lazy
  def set_attributes_from_change_history_data(event_type, change_data)
    @event_type = event_type
    @task_id = change_data["task_id"]
    @task_status = change_data["task_status"]
    @intake_completed_date = change_data["completed_at"]
    @veteran_file_number = change_data["veteran_file_number"]
    @claim_type = change_data["appeal_type"]
    @assigned_at = change_data["assigned_at"]
    @days_waiting = days_waiting_helper

    # Pulled from the person model
    # Probably have to change it to do that stupid abbreviation crap though
    @claimant_name = FullName.new(change_data["first_name"], "", change_data["last_name"]).formatted(:readable_short)

    # Event type might affect the issue fields as well as the decision date and disposition.
    # TODO: Currently adds another database call to RequestIssue which is bad.
    @issue_type = change_data["nonrating_issue_category"]
    @issue_description = change_data["nonrating_issue_description"]
    @decision_date = change_data["decision_date"]

    @benefit_type = change_data["request_issue_benefit_type"]
    @disposition = change_data["disposition"]
    @disposition_date = change_data["caseflow_decision_date"]
    @decision_description = change_data["decision_description"]

    # This is going to be the same for all request issue update events
    # TODO: Should probably use event date instead of this
    @withdrawal_request_date = change_data["request_issue_update_time"]

    # ALL THESE DEPEND ON EVENT TYPE

    # Event Date is going to be interesting and will probably change quite a bit depending on what it is
    # TODO: Rig this to be the date for every event.
    # e.g. withdrawl_request_date, added_issue_date, removed_issue_date, intake_completed_date
    @event_date = change_data["event_date"]

    # TODO: Figure out what to do with this Probably depends on event_type.
    # @event_user = change_data["event_user"]

    # Facility is going to depend on the event user which will depend on the event type
    # TODO: Figure this out
    # It will probably be one of these two fields or maybe both idk
    #  selected_regional_office: nil,
    #  station_id: "317",
    @facility = change_data["user_facility"] || change_data["selected_regional_office"] || change_data["station_id"]

    # User name is going to depend on the event user
    # TODO: Same stuff
    @event_user_name = change_data["event_user_name"] || change_data["full_name"]
  end

  ############ CSV and Serializer Helpers ############

  def event_type_to_readable_name
    {
      in_progress: "Claim status - In Progress",
      incomplete: "Claim status - Incomplete",
      completed: "Claim closed",
      claim_creation: "Claim created",
      completed_disposition: "Completed disposition",
      added_issue: "Added Issue",
      withdrew_issue: "Withdrew issue",
      removed_issue: "Removed issue",
      added_decision_date: "Added decision date"
    }[@event_type]
  end

  def build_task_url
    # TODO: idk how to get the base url
    # Ideas
    # 1. hard code it based on env
    # 2. Get the base url from the request and pass it down to this object
    "https://www.caseflowdemo.com/decision_reviews/vha/tasks/#{@task_id}"
  end

  def days_waiting_helper
    # Should this be based on assigned_at or receipt date
    assigned_on = DateTime.parse(@assigned_at)
    (Time.zone.today - assigned_on).to_i
  end

  def readable_claim_type
    {
      "HigherLevelReview" => "Higher-Level Review",
      "SupplementalClaim" => "Supplemental Claim"
    }[@claim_type]
  end

  def user_name_helper
    if @event_user_name == "System"
      @event_user_name
    elsif @event_user_name.present?
      abbreviated_user_name
    end
  end

  def abbreviated_user_name
    first_name, last_name = @event_user_name.split(" ")
    FullName.new(first_name, "", last_name).formatted(:readable_fi_last_formatted)
  end

  def task_status_mapper
    {
      "assigned" => "in progress",
      "in_progress" => "in progress",
      "on_hold" => "incomplete",
      "completed" => "completed"
    }[@task_status]
  end

  # TODO: Check to see if I should still return blank strings here instead
  def issue_information
    if issue_event?
      [@issue_type, @issue_description, format_date_string(@decision_date)]
    end
  end

  def disposition_information
    if disposition_event?
      [@disposition, @decision_description, format_date_string(@disposition_date)]
    end
  end

  def status_information
    if status_event?
      [nil, status_description]
    end
  end

  def status_description
    {
      in_progress: "Claim can be processed.",
      incomplete: "Claim cannot be processed until decision date is entered.",
      completed: "Claim closed.",
      claim_creation: "Claim created."
    }[@event_type]
  end

  def issue_event?
    [:completed_disposition, :added_issue, :withdrew_issue, :removed_issue].include?(@event_type)
  end

  def disposition_event?
    @event_type == :completed_disposition
  end

  def status_event?
    [:in_progress, :incomplete, :completed, :claim_creation].include?(@event_type)
  end

  def format_date_string(date_string)
    # puts date_string.inspect
    # puts date_string.class.inspect
    if date_string.class == String
      Time.zone.parse(date_string).strftime("%-m/%-d/%Y")
    elsif date_string.present?
      date_string.strftime("%-m/%-d/%Y")
    end
  end
end
