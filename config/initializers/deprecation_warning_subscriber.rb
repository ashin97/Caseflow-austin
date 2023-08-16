# frozen_string_literal: true

# @note For use in conjuction with setting `Rails.application.config.active_support.deprecation = :notify`.
#   Whenever a “deprecation.rails” notification is published, it will dispatch the event
#   (ActiveSupport::Notifications::Event) to method #deprecation.
class DeprecationWarningSubscriber < ActiveSupport::Subscriber
  class DisallowedDeprecationError < StandardError; end

  # Regular expressions for Rails 5.2 deprecation warnings that we have addressed in the codebase
  RAILS_5_2_FIXED_DEPRECATION_WARNING_REGEXES = [
    /Dangerous query method \(method whose arguments are used as raw SQL\) called with non\-attribute argument\(s\)/
  ]

  # Regular expressions for deprecation warnings that should raise exceptions in `development` and `test` environments
  DISALLOWED_DEPRECATION_WARNING_REGEXES = [
    *RAILS_5_2_FIXED_DEPRECATION_WARNING_REGEXES
  ]

  APP_NAME = "caseflow"
  SLACK_ALERT_CHANNEL = "#appeals-deprecation-alerts"

  attach_to :rails

  def deprecation(event)
    emit_warning_to_application_logs(event)
    emit_warning_to_sentry(event)
    emit_warning_to_slack_alerts_channel(event)
  rescue StandardError => error
    Raven.capture_exception(error)
  ensure
    # Temporary solution for disallowed deprecation warnings.
    #   To be replaced be ActiveSupport Disallowed Deprecations, introduced in Rails 6.1:
    #   https://rubyonrails.org/2020/12/9/Rails-6-1-0-release#disallowed-deprecation-support
    raise disallowed_deprecation_error_for(event) if disallowed_deprecation_warning?(event)
  end

  private

  def emit_warning_to_application_logs(event)
    Rails.logger.warn(event.payload[:message])
  end

  def emit_warning_to_sentry(event)
    # Pre-emptive bugfix for future versions of the `sentry-raven` gem:
    #   Need to convert callstack elements from `Thread::Backtrace::Location` objects to `Strings`
    #   to avoid a `TypeError` on `options.deep_dup` in `Raven.capture_message`:
    #   https://github.com/getsentry/sentry-ruby/blob/2e07e0295ba83df4c76c7bf3315d199c7050a7f9/lib/raven/instance.rb#L114
    callstack_strings = event.payload[:callstack].map(&:to_s)

    Raven.capture_message(
      event.payload[:message],
      level: "warning",
      extra: {
        message: event.payload[:message],
        gem_name: event.payload[:gem_name],
        deprecation_horizon: event.payload[:deprecation_horizon],
        callstack: callstack_strings,
        environment: Rails.env
      }
    )
  end

  def emit_warning_to_slack_alerts_channel(event)
    slack_alert_title = "Deprecation Warning - #{APP_NAME} (#{ENV['DEPLOY_ENV']})"

    SlackService
      .new(url: ENV["SLACK_DISPATCH_ALERT_URL"])
      .send_notification(event.payload[:message], slack_alert_title, SLACK_ALERT_CHANNEL)
  end

  def disallowed_deprecation_warning?(event)
    (Rails.env.development? || Rails.env.test?) &&
      DISALLOWED_DEPRECATION_WARNING_REGEXES.any? { |re| re.match?(event.payload[:message]) }
  end

  def disallowed_deprecation_error_for(event)
    DisallowedDeprecationError.new("The following deprecation warning is not allowed: #{event.payload[:message]}")
  end
end
