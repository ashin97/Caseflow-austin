# frozen_string_literal: true

class MailRequest
  include ActiveModel::Model
  include ActiveModel::Validations

  include MailRequestValidator::Distribution
  include MailRequestValidator::DistributionDestination

  attr_accessor :recipient_type, :name, :first_name, :middle_name, :last_name,
                :participant_id, :poa_code, :claimant_station_of_jurisdiction, :destination_type,
                :address_line_1, :address_line_2, :address_line_3, :address_line_4, :address_line_5,
                :address_line_6, :city, :country_code, :postal_code, :state, :treat_line_2_as_addressee,
                :treat_line_3_as_addressee, :country_name, :vbms_distribution_id, :comm_package_id

  def initialize(recipient_and_destination_hash)
    @recipient_type = recipient_and_destination_hash[:recipient_type]
    @name = recipient_and_destination_hash[:name]
    @first_name = recipient_and_destination_hash[:first_name]
    @middle_name = recipient_and_destination_hash[:middle_name]
    @last_name = recipient_and_destination_hash[:last_name]
    @participant_id = recipient_and_destination_hash[:participant_id]
    @poa_code = recipient_and_destination_hash[:poa_code]
    @claimant_station_of_jurisdiction = recipient_and_destination_hash[:claimant_station_of_jurisdiction]
    @destination_type = recipient_and_destination_hash[:destination_type]
    @address_line_1 = recipient_and_destination_hash[:address_line_1]
    @address_line_2 = recipient_and_destination_hash[:address_line_2]
    @address_line_3 = recipient_and_destination_hash[:address_line_3]
    @address_line_4 = recipient_and_destination_hash[:address_line_4]
    @address_line_5 = recipient_and_destination_hash[:address_line_5]
    @address_line_6 = recipient_and_destination_hash[:address_line_6]
    @city = recipient_and_destination_hash[:city]
    @country_code = recipient_and_destination_hash[:country_code]
    @postal_code = recipient_and_destination_hash[:postal_code]
    @state = recipient_and_destination_hash[:state]
    @treat_line_2_as_addressee = recipient_and_destination_hash[:treat_line_2_as_addressee]
    @treat_line_3_as_addressee = recipient_and_destination_hash[:treat_line_3_as_addressee]
    @country_name = recipient_and_destination_hash[:country_name]
    @vbms_distribution_id = nil
    @comm_package_id = nil
  end

  def call
    if valid?
      distribution = create_a_vbms_distribution
      @vbms_distribution_id = distribution.id
      create_a_vbms_distribution_destination
    else
      fail Caseflow::Error::MissingRecipientInfo
    end
  end

  private

  def create_a_vbms_distribution
    VbmsDistribution.create!(recipient_params_parse)
  end

  def create_a_vbms_distribution_destination
    VbmsDistributionDestination.create!(destination_params_parse)
  end

  def destination_params_parse
    {
      destination_type: @destination_type,
      address_line_1: @address_line_1,
      address_line_2: @address_line_2,
      address_line_3: @address_line_3,
      address_line_4: @address_line_4,
      address_line_5: @address_line_5,
      address_line_6: @address_line_6,
      city: @city,
      country_code: @country_code,
      postal_code: @postal_code,
      state: @state,
      treat_line_2_as_addressee: @treat_line_2_as_addressee,
      treat_line_3_as_addressee: @treat_line_3_as_addressee,
      country_name: @country_name,
      vbms_distribution_id: @vbms_distribution_id

    }
  end

  def recipient_params_parse
    {
      recipient_type: @recipient_type,
      name: @name,
      first_name: @first_name,
      middle_name: @middle_name,
      last_name: @last_name,
      participant_id: @participant_id,
      poa_code: @poa_code,
      claimant_station_of_jurisdiction: @claimant_station_of_jurisdiction
    }
  end
end
