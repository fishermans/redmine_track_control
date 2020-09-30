require 'redmine_track_control/tracker_helper'

module RedmineTrackControl
  
  module ProjectsControllerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        if Rails::VERSION::MAJOR >= 5
          alias_method :show_without_trackcontrol, :show
          alias_method :show, :show_with_trackcontrol
        else
          alias_method_chain :show, :trackcontrol
        end
      end
    end

    module InstanceMethods
      def show_with_trackcontrol        
        # try to redirect to the requested menu item
        if params[:jump] && redirect_to_project_menu_item(@project, params[:jump])
          return
        end

        @users_by_role = @project.users_by_role
        @subprojects = @project.children.visible.to_a
        @news = @project.news.limit(5).includes(:author, :project).reorder("#{News.table_name}.created_on DESC").to_a
        
        @trackers = Tracker.where(:id => RedmineTrackControl::TrackerHelper.valid_trackers_ids_incl_assigned_to(@project, "show")).order("#{Tracker.table_name}.position").to_a
        @subprojects.each do |prj|
          @trackers |= Tracker.where(:id => RedmineTrackControl::TrackerHelper.valid_trackers_ids_incl_assigned_to(prj, "show")).order("#{Tracker.table_name}.position").to_a              
        end             
        @trackers = @trackers.compact.reject(&:blank?).uniq.sort    
    

        cond = @project.project_condition(Setting.display_subprojects_issues?)

        @open_issues_by_tracker = Issue.visible.open.where(cond).group(:tracker).count
        @total_issues_by_tracker = Issue.visible.where(cond).group(:tracker).count

        if User.current.allowed_to_view_all_time_entries?(@project)
          @total_hours = TimeEntry.visible.where(cond).sum(:hours).to_f
        end

        @key = User.current.rss_key

        respond_to do |format|
          format.html
          format.api
        end        
      end
    end
  end
end
