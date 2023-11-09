# frozen_string_literal: true

class CorrespondenceController < ApplicationController
  before_action :verify_feature_toggle
  before_action :correspondence, only: [:show, :update]

  def intake
    respond_to do |format|
      format.html { return render "correspondence/intake" }
      format.json do
        render json: {
          correspondence: correspondence_load
        }
      end
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

  def show
    response_json = {
      correspondence: @correspondence,
      package_document_type: @correspondence.package_document_type,
      general_information: general_information
    }
    render({ json: response_json }, status: :ok)
  end

  def update
    if veteran_by_correspondence.update(veteran_params) && @correspondence.update(correspondence_params)
      render json: { status: :ok }
    else
      render json: { error: "Failed to update records" }, status: :unprocessable_entity
    end
  end

  private

  def correspondence
    @correspondence ||= Correspondence.find(params[:id])
  end

  def general_information
    vet = veteran_by_correspondence
    {
      notes: @correspondence.notes,
      file_number: vet.file_number,
      veteran_name: vet.name,
      correspondence_type_id: @correspondence.correspondence_type_id,
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

  def correspondence_load
    @correspondence ||= correspondence_by_uuid
    vet = veteran_by_correspondence
    @all_correspondence = Correspondence.where(veteran_id: vet.id).where.not(uuid: params[:correspondence_uuid])
  end

  def correspondence_by_uuid
    Correspondence.find_by(uuid: params[:correspondence_uuid])
  end

  def veteran_by_correspondence
    @veteran_by_correspondence ||= Veteran.find(@correspondence.veteran_id)
  end

  def veterans_with_correspondences
    veterans = Veteran.includes(:correspondences).where(correspondences: { id: Correspondence.select(:id) })
    veterans.map { |veteran| vet_info_serializer(veteran, veteran.correspondences.first) }
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
end
