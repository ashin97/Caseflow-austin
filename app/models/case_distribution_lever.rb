class CaseDistributionLever < ApplicationRecord

  validates :item, presence: true
  validates :title, presence: true
  validates :data_type, presence: true
  validates :value, presence: true, if: Proc.new { |lever| lever.data_type != 'number' }
  validates :is_active, inclusion: { in: [true, false] }
  validates :is_disabled, inclusion: { in: [true, false] }

  self.table_name = "case_distribution_levers"

  def update_levers(lever_list)
    lever_list.each do |updated_lever|
      updated_lever.save!
    end
  end
end