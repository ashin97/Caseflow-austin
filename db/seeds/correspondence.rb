# frozen_string_literal: true

module Seeds
  class Correspondence < Base
    def initialize
      initial_id_values
    end

    def seed!
      create_correspondences
    end

    private

    def initial_id_values
      @file_number ||= 500_000_000
      @participant_id ||= 850_000_000
      while Veteran.find_by(file_number: format("%<n>09d", n: @file_number + 1))
        @file_number += 100
        @participant_id += 100
      end

      @cmp_packet_number ||= 1_000_000_000
      while ::Correspondence.find_by(cmp_packet_number: @cmp_packet_number + 1)
        @cmp_packet_number += 10000
      end
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

    def create_correspondences
      10.times do
        veteran = create_veteran
        corres = ::Correspondence.create!(
          uuid: SecureRandom.uuid,
          portal_entry_date: Time.zone.now,
          source_type: "Mail",
          package_document_type_id: 15,
          correspondence_type_id:  9,
          cmp_queue_id: 1,
          cmp_packet_number: @cmp_packet_number,
          va_date_of_receipt: Time.zone.yesterday,
          notes: "This is a note from CMP.",
          assigned_by_id: 81,
          veteran_id: veteran.id
        )
        CorrespondenceDocument.create!(
          document_file_number: veteran.file_number,
          uuid: SecureRandom.uuid,
          vbms_document_id: 1250,
          correspondence: corres
        )
        @cmp_packet_number += 1
      end

      for package_doc_id in 1..77 do
        veteran = create_veteran
        corres = ::Correspondence.create!(
          uuid: SecureRandom.uuid,
          portal_entry_date: Time.zone.now,
          source_type: "Mail",
          package_document_type_id: package_doc_id,
          correspondence_type_id:  9,
          cmp_queue_id: 1,
          cmp_packet_number: @cmp_packet_number,
          va_date_of_receipt: Time.zone.yesterday,
          notes: "This is a note from CMP.",
          assigned_by_id: 81,
          veteran_id: veteran.id
        )
        CorrespondenceDocument.create!(
          document_file_number: veteran.file_number,
          uuid: SecureRandom.uuid,
          vbms_document_id: 1250,
          correspondence: corres
        )
        @cmp_packet_number += 1
      end

      for corres_type_id in 1..24 do
        veteran = create_veteran
        corres = ::Correspondence.create!(
          uuid: SecureRandom.uuid,
          portal_entry_date: Time.zone.now,
          source_type: "Mail",
          package_document_type_id: 15,
          correspondence_type_id:  corres_type_id,
          cmp_queue_id: 1,
          cmp_packet_number: @cmp_packet_number,
          va_date_of_receipt: Time.zone.yesterday,
          notes: "This is a note from CMP.",
          assigned_by_id: 81,
          veteran_id: veteran.id
        )
        CorrespondenceDocument.create!(
          document_file_number: veteran.file_number,
          uuid: SecureRandom.uuid,
          vbms_document_id: 1250,
          correspondence: corres
        )
        @cmp_packet_number += 1
      end

      for cmp_queue_id in 1..17 do
        veteran = create_veteran
        corres = ::Correspondence.create!(
          uuid: SecureRandom.uuid,
          portal_entry_date: Time.zone.now,
          source_type: "Mail",
          package_document_type_id: 15,
          correspondence_type_id:  9,
          cmp_queue_id: cmp_queue_id,
          cmp_packet_number: @cmp_packet_number,
          va_date_of_receipt: Time.zone.yesterday,
          notes: "This is a note from CMP.",
          assigned_by_id: 81,
          veteran_id: veteran.id
        )
        CorrespondenceDocument.create!(
          document_file_number: veteran.file_number,
          uuid: SecureRandom.uuid,
          vbms_document_id: 1250,
          correspondence: corres
        )
        @cmp_packet_number += 1
      end
    end
  end
end
