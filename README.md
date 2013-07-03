TimeTracker
===========

The TimeTracker project for the database class in SS 2013.

Functional Specification
========================
Projects:
- [x] The user can create several projects.
- [x] The user can edit the name of projects.
- [x] The user can delete projects.

Issues:
- [x] The user can create issues in the app itself (with a name and a short description).
- [x] The user can edit issues he created in the app.
- [x] The user can delete issues he created in the app.

Tracking:
- [x] The user can select a project and start tracking time.
- [x] Each time a user starts tracking the generated log entry is associated with an issues the user selects - per default it will be the last issue he tracked time for or the „default issue“ if he hasn‘t chosen or created a specific issue yet.
- [x] The user can also create log entries by entering the time and date he started working on an issue and when he finished it.
- [x] The user can delete existing log entries.

Report:
- [x] The user can view all issues and all log entries to see when he spend how much time on which issue.
- [x] The user can see summarized information about the time spent per project and issue.

External Links:
- [x] The user can create several account links for external project management systems like GitHub, JIRA, Pivotal Tracker or similar services (design the system in way it can be expanded easily).
- [x] The user can link each project with one project that exists in the external project management system (either by choosing an existing service link or creating a new link).
- [x] The app will synchronize all issues of this project with the external project management system.
- [x] The user can remove links to external project management systems and “unlink” projects from their counterpart in the external project management system.
- [x] All log entries are exported to the external project management system - either as comments on the issue or in a similar way, depending on what possibilities the external system offers. This can either happen automatically or on explicit user request.

iCloud:
- [ ] The user can sync their data via iCloud between different iOS devices

Optional Features 1:
- [ ] (optional) If the user deletes an issue of a project that is linked with an external system that issue is also deleted from the external system.
- [ ] (optional) If the user creates an issue for a project that is linked with an external system that issue is also created in the external system.
- [ ] (optional) If the user edits an issue for a project that is linked with an external system that issue is also edited in the external system.

Optional Features 2:
- [ ] (optional) The user can create, remove and edit comments on log entries.
- [ ] (optional) In case of GitHub the user can also see all comments on an issue and can browse the list of commits. (all data should be available offline, so all data needs to be stored via CoreData).
- [ ] (optional) The user can export their data as csv, json and other textual formats.
