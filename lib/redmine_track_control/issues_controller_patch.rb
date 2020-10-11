require 'redmine_track_control/tracker_helper'

module RedmineTrackControl
    module IssuesControllerPatch
        extend ActiveSupport::Concern

        included do
            prepend InstanceMethods
        end

        module InstanceMethods

            def self.prepended(base)
                base.class_eval do
                    before_action :check_tracker_id_with_trackcontrol, :only => [:new, :create, :update]
                end
            end

            # default params[:tracker_id] is taken from project settings @project.trackers.first
            # fields (defined by permissions) to display on the form are based on this value
            # predefine params[:tracker_id] with value according plugin settings
            def build_new_issue_from_params
                params[:tracker_id] ||= get_tracker_ids.first
                super
            end

            def update_issue_from_params
                params[:tracker_id] ||= get_tracker_ids.first
                super
            end

            # nullify tracker_id if it is not allowed
            def check_tracker_id_with_trackcontrol
                tracker_ids = allowed_tracker_ids_with_trackcontrol
                if @issue.tracker_id_changed? && tracker_ids.exclude?(@issue.tracker_id)
                    @issue.tracker_id = nil
                end
            end

            # build possible trackers for issue.
            # Possible trackers for user are:
            # predefined trackers by admin in "Roles and Permissions" + current issue's tracker (it allows user update issue and leave current tracker)
            def allowed_tracker_ids_with_trackcontrol
                # join trackers from permissions
                tracker_ids = get_tracker_ids

                # add current issue's tracker if issue exists and tracker_ids contains smth
                tracker_ids << @issue.tracker_id_was if @issue && @issue.persisted? && tracker_ids.any?
                tracker_ids
            end

            private

            # join trackers from permissions
            def get_tracker_ids(permtype = "create")
                @tracker_ids = RedmineTrackControl::TrackerHelper.valid_trackers_ids(@project, permtype)
                @tracker_ids.flatten.uniq
            end
        end
    end
end

unless IssuesController.included_modules.include? RedmineTrackControl::IssuesControllerPatch
    IssuesController.send :include, RedmineTrackControl::IssuesControllerPatch
end
