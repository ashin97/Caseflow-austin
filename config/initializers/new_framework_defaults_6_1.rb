# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease your Rails 6.1 upgrade.
#
# Once upgraded flip defaults one by one to migrate to the new default.
#
# Read the Guide for Upgrading Ruby on Rails for more info on each option.

# Change the default HTTP status code to `308` when redirecting non-GET/HEAD
# requests to HTTPS in `ActionDispatch::SSL` middleware.
# Rails.application.config.action_dispatch.ssl_default_redirect_status = 308

# Use new connection handling API. For most applications this won't have any
# effect. For applications using multiple databases, this new API provides
# support for granular connection swapping.
# Rails.application.config.active_record.legacy_connection_handling = false

# Make `form_with` generate non-remote forms by default.
# Rails.application.config.action_view.form_with_generates_remote_forms = false

# Set the default queue name for the analysis job to the queue adapter default.
# Rails.application.config.active_storage.queues.analysis = nil

# Set the default queue name for the purge job to the queue adapter default.
# Rails.application.config.active_storage.queues.purge = nil

# Set the default queue name for the incineration job to the queue adapter default.
# Rails.application.config.action_mailbox.queues.incineration = nil

# Set the default queue name for the routing job to the queue adapter default.
# Rails.application.config.action_mailbox.queues.routing = nil

# Set the default queue name for the mail deliver job to the queue adapter default.
# Rails.application.config.action_mailer.deliver_later_queue_name = nil

# Generate a `Link` header that gives a hint to modern browsers about
# preloading assets when using `javascript_include_tag` and `stylesheet_link_tag`.
# Rails.application.config.action_view.preload_links_header = true
