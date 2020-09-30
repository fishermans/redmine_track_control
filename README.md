# Redmine Tracker Control plugin

Plugin for controlling tracker wise issue creation

## Features

* Role based permission for creating issue with specific Tracker
* Role based permission to view issues
* Project Module to enable/disable tracker permission
* Projects without tracker control module do not follow any permission rules and will show up as usual
* Compatible with Redmine 4.1.1 (Should also work with Redmine 3.x)

## Installation

* Copy redmine_track_control directory to #{RAILS_ROOT}/plugins
* Restart Redmine
* Configure access control in the roles page
* Add _Tracker Permission_ module in the project settings -> modules