# frozen_string_literal: true

class Api::V1::MpiController < Api::ApplicationController
  # {POST Method for Veteran ID, Deceased Indicator, Deceased Time}
  def veteran_updates
    Rails.logger.info(
      "Queue ART says start. veterans_id: #{allowed_params[:veterans_ssn]} " \
      "veterans_pat: #{allowed_params[:veterans_pat]} deceased_time: #{allowed_params[:deceased_time]}"
    )
    response_info_column = veteran.dup

    mpi_update = MpiUpdatePersonEvent.create!(api_key: api_key, created_at: Time.zone.now, update_type: :started)
    result = VACOLS::Correspondent.update_veteran_nod(veteran).to_sym
    handle_successful_update!(result, response_info_column, mpi_update)
    handle_response(result)
  rescue StandardError => error
    response_info_column[:error] = error
    mpi_update.update!(update_type: :error, completed_at: Time.zone.now, info: response_info_column)
    raise error
  end

  def allowed_params
    params.permit(:veterans_ssn, :veterans_pat, :deceased_time)
  end

  def veteran
    {
      veterans_ssn: allowed_params[:veterans_ssn],
      veterans_pat: allowed_params[:veterans_pat].split("^")[0],
      deceased_time: allowed_params[:deceased_time]
    }
  end

  def invalid_result?(result)
    result == :no_veteran || result == :missing_deceased_info
  end

  def handle_response(result)
    status = invalid_result?(result) ? :bad_request : :ok
    render json: { result: result }, status: status
  end

  def handle_successful_update!(result, response_info_column, mpi_update)
    if [:successful, :already_deceased_time_changed].include?(result)
      updated_veteran = VACOLS::Correspondent.find_by(stafkey: veteran[:veterans_pat]) ||
                        VACOLS::Correspondent.find_by(ssn: veteran[:veterans_ssn])

      response_info_column[:updated_column] = "deceased_time"
      response_info_column[:updated_deceased_time] = updated_veteran.sfnod if updated_veteran

      mpi_update.update!(update_type: result, completed_at: Time.zone.now, info: response_info_column)
    end
  end
end
