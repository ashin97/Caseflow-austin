# frozen_string_literal: true

class WorkQueue::AdministeredUserSerializer < WorkQueue::UserSerializer
  include FastJsonapi::ObjectSerializer

  attribute :admin do |object, params|
    params[:organization].user_is_admin?(object)
  end
  attribute :dvc do |object, params|
    if params[:organization].type == DvcTeam.name
      params[:organization].dvc&.eql?(object)
    end
  end
  attribute :meeting_type do |object,_params|
    object.meeting_type.service_name
  end
end
