# frozen_string_literal: true
module Hyrax
  module Workflow
    # This is a built in function for workflow, so that a workflow action can be created that
    # grants the creator the ability to alter it.
    module GrantEditToDepositor
      # @param [#read_users=, #read_users] target (likely an ActiveRecord::Base) to which we are adding edit_users for the depositor
      # @return void
      def self.call(target:, **)
        return true unless target.try(:depositor)
        target.edit_users = target.edit_users.to_a + Array.wrap(target.depositor) # += works in Ruby 2.6+
        target.try(:permission_manager)&.acl&.save
        # If there are a lot of members, granting access to each could take a
        # long time. Do this work in the background.
        GrantEditToMembersJob.perform_later(target, target.depositor)
      end
    end
  end
end
