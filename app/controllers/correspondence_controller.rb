# frozen_string_literal: true

class CorrespondenceController < ApplicationController
  before_action :verify_correspondence_access
  before_action :verify_feature_toggle
  before_action :correspondence
  before_action :auto_texts
  before_action :veteran_information

  def intake
    respond_to do |format|
      format.html { return render "correspondence/intake" }
      format.json do
        render json: {
          currentCorrespondence: current_correspondence,
          correspondence: correspondence_load,
          veteranInformation: veteran_information
        }
      end
    end
  end

  def current_step
    intake = CorrespondenceIntake.find_by(user: current_user, correspondence: current_correspondence) ||
      CorrespondenceIntake.new(user: current_user, correspondence: current_correspondence)

    intake.update(
      current_step: params[:current_step],
      redux_store: params[:redux_store]
    )

    if intake.valid?
      intake.save!

      render json: {}, status: :ok and return
    else
      render json: intake.errors.full_messages, status: :unprocessable_entity and return
    end
  end

  def correspondence_cases
    respond_to do |format|
      format.html { "correspondence_cases" }
      format.json do
        render json: { vetCorrespondences: veterans_with_correspondences }
      end
    end
  end

  def review_package
    render "correspondence/review_package"
  end

  def intake_update
    tasks = Task.where("appeal_id = ? and appeal_type = ?", @correspondence.id, "Correspondence")
    begin
      tasks.map do |task|
        if task.type == "ReviewPackageTask"
          task.instructions.push("An appeal intake was started because this Correspondence is a 10182")
          task.assigned_to_id = @correspondence.assigned_by_id
          task.assigned_to = User.find(@correspondence.assigned_by_id)
        end
        task.status = "cancelled"
        task.save
      end
      if upload_documents_to_claim_evidence
        render json: { correspondence: @correspondence }
      else
        render json: {}, status: bad_request
      end
    rescue StandardError => error
      Rails.logger.error(error.to_s)
      render json: {}, status: bad_request
    end
  end

  def veteran
    render json: { veteran_id: veteran_by_correspondence&.id, file_number: veteran_by_correspondence&.file_number }
  end

  def package_documents
    packages = PackageDocumentType.all
    render json: { package_document_types: packages }
  end

  def current_correspondence
    @current_correspondence ||= correspondence
  end

  def veteran_information
    @veteran_information ||= veteran_by_correspondence
  end

  def show
    corres_docs = correspondence.correspondence_documents
    response_json = {
      correspondence: correspondence,
      package_document_type: correspondence&.package_document_type,
      general_information: general_information,
      user_can_edit_vador: MailTeamSupervisor.singleton.user_has_access?(current_user),
      correspondence_documents: corres_docs.map do |doc|
        WorkQueue::CorrespondenceDocumentSerializer.new(doc).serializable_hash[:data][:attributes]
      end
    }
    render({ json: response_json }, status: :ok)
  end

  def update
    veteran = Veteran.find_by(file_number: veteran_params["file_number"])
    if veteran && correspondence.update(
      correspondence_params.merge(
        veteran_id: veteran.id,
        updated_by_id: RequestStore.store[:current_user].id
      )
    )
      render json: { status: :ok }
    else
      render json: { error: "Please enter a valid Veteran ID" }, status: :unprocessable_entity
    end
  end

  def update_cmp
    correspondence.update(
      va_date_of_receipt: params["VADORDate"].in_time_zone,
      package_document_type_id: params["packageDocument"]["value"].to_i
    )
    render json: { status: 200, correspondence: correspondence }
  end

  def document_type_correspondence
    data = vbms_document_types
    render json: { data: data }
  end

  def pdf
    document = Document.find(params[:pdf_id])

    document_disposition = "inline"
    if params[:download]
      document_disposition = "attachment; filename='#{params[:type]}-#{params[:id]}.pdf'"
    end

    # The line below enables document caching for a month.
    expires_in 30.days, public: true
    send_file(
      document.serve,
      type: "application/pdf",
      disposition: document_disposition
    )
  end

  def process_intake
    correspondence_id = Correspondence.find_by(uuid: params[:correspondence_uuid])&.id
    ActiveRecord::Base.transaction do
      begin
        create_correspondence_relations(correspondence_id)
        add_tasks_to_related_appeals(correspondence_id)
        complete_waived_evidence_submission_tasks(correspondence_id)
      rescue ActiveRecord::RecordInvalid
        render json: { error: "Failed to update records" }, status: :bad_request
        raise ActiveRecord::Rollback
      rescue ActiveRecord::RecordNotUnique
        render json: { error: "Failed to update records" }, status: :bad_request
        raise ActiveRecord::Rollback
      else
        set_flash_intake_success_message
        render json: {}, status: :created
      end
    end
  end

  private

  def vbms_document_types
    begin
      data = ExternalApi::ClaimEvidenceService.document_types
    rescue StandardError => error
      Rails.logger.error(error.full_message)
      data ||= demo_data
    end
    data["documentTypes"].map { |document_type| { id: document_type["id"], name: document_type["description"] } }
  end

  def demo_data
    json_file_path = "vbms doc types.json"
    JSON.parse(File.read(json_file_path))
  end

  def set_flash_intake_success_message
    # intake error message is handled in client/app/queue/correspondence/intake/components/CorrespondenceIntake.jsx
    vet = veteran_by_correspondence
    flash[:correspondence_intake_success] = [
      "You have successfully submitted a correspondence record for #{vet.name}(#{vet.file_number})",
      "The mail package has been uploaded to the Veteran's eFolder as well."
    ]
  end

  def create_correspondence_relations(correspondence_id)
    params[:related_correspondence_uuids]&.map do |uuid|
      CorrespondenceRelation.create!(
        correspondence_id: correspondence_id,
        related_correspondence_id: Correspondence.find_by(uuid: uuid)&.id
      )
    end
  end

  def complete_waived_evidence_submission_tasks(correspondence_id)
    params[:waived_evidence_submission_window_tasks]&.map do |task|
      evidence_submission_window_task = EvidenceSubmissionWindowTask.find(task[:task_id])
      instructions = evidence_submission_window_task.instructions
      appeal = evidence_submission_window_task&.appeal
      CorrespondencesAppeal.find_or_create_by(correspondence_id: correspondence_id, appeal_id: appeal.id)
      evidence_submission_window_task.when_timer_ends
      evidence_submission_window_task.update!(instructions: (instructions << task[:waive_reason]))
    end
  end

  def add_tasks_to_related_appeals(correspondence_id)
    params[:tasks_related_to_appeal]&.map do |data|
      appeal = Appeal.find(data[:appeal_id])
      CorrespondencesAppeal.find_or_create_by(correspondence_id: correspondence_id, appeal_id: appeal.id)
      data[:klass].constantize.create_from_params(
        {
          appeal: appeal,
          parent_id: appeal.root_task&.id,
          assigned_to: data[:assigned_to].constantize.singleton,
          instructions: data[:content]
        }, current_user
      )
    end
  end

  def verify_correspondence_access
    return true if MailTeamSupervisor.singleton.user_has_access?(current_user) ||
                   MailTeam.singleton.user_has_access?(current_user)

    redirect_to "/unauthorized"
  end

  def general_information
    vet = veteran_by_correspondence
    {
      notes: correspondence.notes,
      file_number: vet.file_number,
      veteran_name: vet.name,
      correspondence_type_id: correspondence.correspondence_type_id,
      correspondence_types: CorrespondenceType.all
    }
  end

  def correspondence_params
    params.require(:correspondence).permit(:notes, :correspondence_type_id)
  end

  def veteran_params
    params.require(:veteran).permit(:file_number)
  end

  def verify_feature_toggle
    if !FeatureToggle.enabled?(:correspondence_queue)
      redirect_to "/unauthorized"
    end
  end

  def correspondence
    return @correspondence if @correspondence.present?

    if params[:id].present?
      @correspondence = Correspondence.find(params[:id])
    elsif params[:correspondence_uuid].present?
      @correspondence = Correspondence.find_by(uuid: params[:correspondence_uuid])
    end

    @correspondence
  end

  def correspondence_load
    Correspondence.where(veteran_id: veteran_by_correspondence.id).where.not(uuid: params[:correspondence_uuid])
  end

  def veteran_by_correspondence
    return unless correspondence&.veteran_id

    @veteran_by_correspondence ||= begin
      veteran = Veteran.find_by(id: correspondence.veteran_id)
      if veteran.nil?
      end
      veteran
    end
  end

  def veterans_with_correspondences
    veterans = Veteran.includes(:correspondences).where(correspondences: { id: Correspondence.select(:id) })
    veterans.map { |veteran| vet_info_serializer(veteran, veteran.correspondences.last) }
  end

  def vet_info_serializer(veteran, correspondence)
    {
      firstName: veteran.first_name,
      lastName: veteran.last_name,
      fileNumber: veteran.file_number,
      cmPacketNumber: correspondence.cmp_packet_number,
      correspondenceUuid: correspondence.uuid,
      packageDocumentType: correspondence.correspondence_type_id
    }
  end

  def auto_texts
    @auto_texts ||= AutoText.all.pluck(:name)
  end

  def upload_documents_to_claim_evidence
    if Rails.env.development? || Rails.env.demo? || Rails.env.test?
      true
    else
      begin
        correspondence.correspondence_documents.all.each do |doc|
          ExternalApi::ClaimEvidenceService.upload_document(
            doc.pdf_location,
            veteran_by_correspondence.file_number,
            doc.claim_evidence_upload_json
          )
        end
        true
      rescue StandardError => error
        Rails.logger.error(error.to_s)
        create_efolder_upload_failed_task
        false
      end
    end
  end

  def create_efolder_upload_failed_task
    rpt = ReviewPackageTask.find_by(appeal_id: correspondence.id, type: ReviewPackageTask.name)
    euft = EfolderUploadFailedTask.find_or_create_by(
      appeal_id: correspondence.id,
      appeal_type: "Correspondence",
      type: EfolderUploadFailedTask.name,
      assigned_to: current_user,
      parent_id: rpt.id
    )

    euft.update!(status: Constants.TASK_STATUSES.in_progress)
  end
end
