# frozen_string_literal :true

# create correspondence seeds
module Seeds
  class MultiCorrespondences < Base

    def initialize
      initial_id_values
    end

    def seed!
      create_multi_correspondences
    end

    private

    def initial_id_values
      @file_number ||= 550_000_000
      @participant_id ||= 650_000_000
      while Veteran.find_by(file_number: format("%<n>09d", n: @file_number + 1))
        @file_number += 100
        @participant_id += 100
      end

      @cmp_packet_number ||= 2_000_000_000
      @cmp_packet_number += 10_000 while ::Correspondence.find_by(cmp_packet_number: @cmp_packet_number + 1)
    end

    def create_veteran(options = {})
      @file_number += 1
      @participant_id += 1
      params = {
        file_number: format("%<n>09d", n: @file_number),
        participant_id: format("%<n>09d", n: @participant_id)
      }
      create(:veteran, params.merge(options))
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def create_multi_correspondences
      veteran = create_veteran(first_name: "Adam", last_name: "West")
      21.times do
        corres = ::Correspondence.create!(
          uuid: SecureRandom.uuid,
          portal_entry_date: Time.zone.now,
          source_type: "Mail",
          package_document_type_id: 10182,
          correspondence_type_id: 4,
          cmp_queue_id: 1,
          cmp_packet_number: @cmp_packet_number,
          va_date_of_receipt: Time.zone.yesterday,
          notes: "Notes from CMP - Multi Correspondence Seed",
          assigned_by_id: 81,
          veteran_id: veteran.id,
          prior_correspondence_id: 1
        )
        CorrespondenceDocument.create!(
          document_file_number: veteran.file_number,
          uuid: SecureRandom.uuid,
          vbms_document_id: "1250",
          correspondence: corres
        )
        @cmp_packet_number += 1
      end

      veteran = create_veteran(first_name: "Michael", last_name: "Keaton")
      31.times do
        corres = ::Correspondence.create!(
          uuid: SecureRandom.uuid,
          portal_entry_date: Time.zone.now,
          source_type: "Mail",
          package_document_type_id: 1082,
          correspondence_type_id: 4,
          cmp_queue_id: 1,
          cmp_packet_number: @cmp_packet_number,
          va_date_of_receipt: Time.zone.yesterday,
          notes: "Notes from CMP - Multi Correspondence Seed",
          assigned_by_id: 81,
          veteran_id: veteran.id,
          prior_correspondence_id: 1
        )
        CorrespondenceDocument.create!(
          document_file_number: veteran.file_number,
          uuid: SecureRandom.uuid,
          vbms_document_id: "1250",
          correspondence: corres
        )
        @cmp_packet_number += 1
      end


      veteran = create_veteran(first_name: "Christian", last_name: "Bale")
      101.times do
        corres = ::Correspondence.create!(
          uuid: SecureRandom.uuid,
          portal_entry_date: Time.zone.now,
          source_type: "Mail",
          package_document_type_id: 1082,
          correspondence_type_id: 4,
          cmp_queue_id: 1,
          cmp_packet_number: @cmp_packet_number,
          va_date_of_receipt: Time.zone.yesterday,
          notes: "Notes from CMP - Multi Correspondence Seed",
          assigned_by_id: 81,
          veteran_id: veteran.id,
          prior_correspondence_id: 1
        )
        CorrespondenceDocument.create!(
          document_file_number: veteran.file_number,
          uuid: SecureRandom.uuid,
          vbms_document_id: "1250",
          correspondence: corres
        )
        @cmp_packet_number += 1
      end
    end
  end
end
