# Redmine Tracker Control

Access control for redmine trackers.

## Features

* Role based permission for creating issue with specific Tracker
* Role based permission to view issues
* Project Module to enable/disable tracker permission
* Projects without tracker control module do not follow any permission rules and will show up as usual
* Compatible with Redmine 4.1.1 (Requires Rails 5.x)

## Installation

* Copy redmine_track_control directory to #{RAILS_ROOT}/plugins
* Restart Redmine
* Configure access control in the roles page
* Add _Tracker Permission_ module in the project settings -> modules
