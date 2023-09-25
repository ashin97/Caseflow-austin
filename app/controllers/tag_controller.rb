# frozen_string_literal: true

class TagController < ApplicationController
  before_action :verify_access

  def create
    # getting params
    document_id = params[:document_id]

    # finding the document and adding tags
    document = Document.find(document_id)
    errors = []

    tags_request = tag_params[:tags]
    tags_request.each do |tag|
      new_tag = Tag.find_or_create_by(tag)
      begin
        document.tags << new_tag
      rescue ActiveRecord::RecordNotUnique
        errors.push(new_tag.text => "This tag already exists for the document.")
      end
    end

    response_json = { tags: document.tags }
    errors.any? && response_json[:errors] = errors
    render({ json: response_json }, status: :ok)
  end

  def destroy
    document_id = params[:document_id]
    tag_id = params[:id]

    document = Document.find(document_id)

    document.tags.destroy(tag_id)
    render(json: { status: :no_content })
  end

  def auto_tag
    begin
      AutotaggedDocumentJob.perform_now(params[:document_id])
      render(json: { status: :ok })
    rescue StandardError
      errors = { 'message' => 'We are unable to generate auto tags for this document' }
      Rails.logger.info("Document is not ready for auto-tagging.")
      render({ json: { errors: errors } }, status: :not_found)
    end
  end

  private

  def tag_params
    params.permit(tags: [:text])
  end

  def verify_access
    verify_authorized_roles("Reader")
  end
end
