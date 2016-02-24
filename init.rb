require 'redmine'
require 'redmine_track_control/tracker_helper'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'tracker'
  Tracker.send(:include, RedmineTrackControl::TrackerPatch)

  require_dependency 'issue'
  Issue.send(:include, RedmineTrackControl::IssuePatch)

  require_dependency 'roles_controller'
  RolesController.send(:include, RedmineTrackControl::RolesControllerPatch)

  require_dependency 'issues_controller'
  IssuesController.send(:include, RedmineTrackControl::IssuesControllerPatch)

  require_dependency 'query'
  IssueQuery.send(:include, RedmineTrackControl::QueryPatch)

  require_dependency 'context_menus_controller'
  ContextMenusController.send(:include, RedmineTrackControl::ContextMenusControllerPatch)

  require_dependency 'versions_controller'
  VersionsController.send(:include, RedmineTrackControl::VersionsControllerPatch)

  require_dependency 'projects_controller'
  ProjectsController.send(:include, RedmineTrackControl::ProjectsControllerPatch)  

  require_dependency 'redmine_track_control/hooks'
end

Redmine::Plugin.register :redmine_track_control do
  name 'Redmine Tracker Control plugin'
  author 'Jijesh Mohan refactored by Tiemo Vorschuetz'
  description 'Plugin for controlling tracker wise issue creation. Code improved and refactored based on "Redmine tracker accessible" from https://github.com/twinslash/redmine_tracker_accessible'
  version '3.0.0'
   requires_redmine :version_or_higher => '3.2.0'
  url 'https://github.com/fishermans/redmine_track_control'

  project_module :tracker_permissions do
    if ActiveRecord::Base.connection.table_exists? Tracker.table_name
      Tracker.all.each do |t|
        RedmineTrackControl::TrackerHelper.add_tracker_permission(t,"create")
        RedmineTrackControl::TrackerHelper.add_tracker_permission(t,"show")
      end
    end
  end
end

# Little hack for deface in redmine:
# - redmine plugins are not railties nor engines, so deface overrides are not detected automatically
# - deface doesn't support direct loading anymore ; it unloads everything at boot so that reload in dev works
# - hack consists in adding "app/overrides" path of all plugins in Redmine's main #paths
Rails.application.paths["app/overrides"] ||= []
Dir.glob("#{Rails.root}/plugins/*/app/overrides").each do |dir|
  Rails.application.paths["app/overrides"] << dir unless Rails.application.paths["app/overrides"].include?(dir)
end