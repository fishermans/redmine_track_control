# Helper module
module RedmineTrackControl
    module TrackerHelper
        def self.is_trackcontrol_enabled(project)
            if project
                project.enabled_modules.where(:name => "tracker_permissions").count == 1
            else
                false
            end
        end

        def self.add_tracker_permission(tracker, permtype)
            Redmine::AccessControl.map { |map| map.project_module(:tracker_permissions) { |map| map.permission(permission(tracker, permtype), {:issues => :index}, {}) } }
        end

        def self.remove_tracker_permission(tracker, permtype)
            perm = Redmine::AccessControl.permission(permission(tracker, permtype))
            Redmine::AccessControl.permissions.delete perm unless perm.nil?
        end

        def self.permission(tracker, permtype = 'create')
            (permtype + "_tracker#{tracker.id}").to_sym
        end

        # Gets the list of valid trackers for the project for the current user
        def self.valid_trackers_list(project, permtype = 'create')
            if project
                ltrackers = project.trackers
                if permtype == 'show' and Setting.display_subprojects_issues?
                    if ltrackers.empty?
                        ltrackers = project.rolled_up_trackers
                    end
                end
                if is_trackcontrol_enabled (project)
                    ltrackers.select { |t| User.current.allowed_to?(permission(t, permtype), project, :global => true) }.collect { |t| [t.name, t.id] }
                else
                    ltrackers.collect { |t| [t.name, t.id] }
                end
            else
                Tracker.all.collect { |t| [t.name, t.id] }
            end
        end

        # Gets the list of valid trackers for the project for the current user
        def self.trackers_ids_by_role(role, permtype = 'create')
            if role
                Tracker.all.select { |t| role.allowed_to?(permission(t, permtype)) }.map { |t| t.id }
            else
                Tracker.all.collect { |t| t.id }
            end
        end

        # Gets the list of valid trackers for the project for the current user
        def self.valid_trackers_ids(project, permtype = 'create', usr = nil)
            if project
                ltrackers = permtype == "create" ? project.trackers : project.rolled_up_trackers
                if is_trackcontrol_enabled(project)
                    ltrackers.select { |t| (usr || User.current).allowed_to?(permission(t, permtype), project, :global => true) }.collect { |t| t.id }.uniq.sort
                else
                    ltrackers.collect { |t| t.id }.uniq.sort
                end
            else
                Tracker.all.collect { |t| t.id }
            end
        end

        # Gets the list of valid trackers for the project for the current user
        def self.valid_trackers_ids_incl_assigned_to(project, permtype = 'create', usr = nil)
            if project
                ltrackers = valid_trackers_ids(project, permtype, usr)
                if unless (permtype == 'create' || project.issues.nil? || !is_trackcontrol_enabled(project))
                       project.issues.each do |iss|
                           if !ltrackers.include?(iss.tracker.id) and ((usr || User.current).admin? || iss.visible?(usr || User.current))
                               ltrackers.push(iss.tracker.id)
                           end
                       end
                   end
                end
                ltrackers.uniq.sort;
            else
                Tracker.all.collect { |t| t.id }
            end
        end

        # Gets the list of valid trackers for the project for the current user
        def self.issue_has_valid_tracker?(issue, permtype = 'create', usr = nil)
            if issue
                unless issue.project.nil?
                    if is_trackcontrol_enabled (issue.project)
                        l_trackers = valid_trackers_ids(issue.project, permtype, usr)
                        return !l_trackers.nil? && !l_trackers.empty? && (l_trackers.include?(issue.tracker.id) || (issue.author == (usr || User.current)) || (usr || User.current).is_or_belongs_to?(issue.assigned_to))
                    else
                        issue.project.trackers.count > 0
                    end
                end
            end
            return true
        end
    end
end
