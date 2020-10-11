require 'redmine_track_control/tracker_helper'

module RedmineTrackControl

    module QueryPatch
        def self.included(base)
            # :nodoc:
            base.send(:include, InstanceMethods)

            base.class_eval do
                unloadable # Send unloadable so it will not be unloaded in development

                if Rails::VERSION::MAJOR >= 5
                    alias_method :trackers_without_trackcontrol, :trackers
                    alias_method :trackers, :trackers_with_trackcontrol
                else
                    alias_method_chain :trackers, :trackcontrol
                end
            end
        end

        module InstanceMethods
            def trackers_with_trackcontrol
                if project.nil?
                    @trackers = Tracker.sorted.to_a
                else
                    @trackers = []
                    project.self_and_descendants.each do |prj|
                        @trackers |= Tracker.where(:id => RedmineTrackControl::TrackerHelper.valid_trackers_ids_incl_assigned_to(prj, "show")).order("#{Tracker.table_name}.position")
                    end
                    @trackers = @trackers.compact.reject(&:blank?).uniq.sort
                end
            end
        end
    end
end
