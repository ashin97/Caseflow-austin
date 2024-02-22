# frozen_string_literal: true

# This script will print appeal ID for appeals which have an 'assigned' DistributionTask but do not pass the check
# appeal.can_redistribute_appeal? which prevents the appeal from being distributed
#
# To run from caseflow root directory:
#    bundle exec rails runner lib/helper/find_blocked_appeals.rb arg1 arg2 arg3
#
# Required arguments:
#   priority: true or false; if no blocking appeals found, provide the other boolean
#   number of appeals: the number of appeals per docket to check
#
# Optional arguments:
#   treee: whether or not to print the appeal "treee" method output to the console

if ARGV[1].blank? || ARGV[2].blank?
  fail "Required arguments: priority and number of appeals"
end

fail "priority must be true or false" unless %w[true false].include?(ARGV[1])
fail "number of appeals must be a non-zero integer" unless ARGV[2].to_i > 0
fail "treee must be true or false" unless ARGV[3].blank? || %w[true false].include?(ARGV[3])

priority = ARGV[1]
number_of_appeals = ARGV[2].to_i
treee = ARGV[3].presence ? ARGV[3] : false

# silence ActiveRecord logging
ActiveRecord::Base.logger = nil

dockets = [DirectReviewDocket.new, HearingRequestDocket.new, EvidenceSubmissionDocket.new]

res = dockets.flat_map { |d| d.appeals(priority: priority, ready: true).limit(number_of_appeals) }

res.reject!(&:can_redistribute_appeal?)

return puts "No blocking appeals found" if res.empty?

res.map { |a| puts a.treee } if treee
puts "These Appeal IDs are being selected but are unable to be distributed: #{res.map(&:id).sort}"

exit # rubocop:disable Rails/Exit
