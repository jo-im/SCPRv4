Feature: Events

Background:
	Given the following events:
	 | title         | etype | starts_at     | is_published |
	 | A Rad Event   | comm  | tomorrow 2pm  | 1            |
	 | A Cool Event  | comm  | tomorrow 1pm  | 1            |
	 | Future Event  | spon  | tomorrow 8pm  | 1            |
	 | Awesome Event | spon  | tomorrow 8pm  | 1            |
	 | Event Tile 1  | pick  | tomorrow 11am | 1            |
	 | Event Title 2 | pick  | tomorrow 11am | 1            |
	 | Unpub Event   | comm  | tomorrow      | 0            |
	 | Past event    | comm  | yesterday     | 1            |
	 | Past event 2  | pick  | yesterday     | 1            |

Scenario: View "All" events list
	When I go to the events page
	And I filter by "all"
	Then I should see a list of 6 upcoming events
	And I should see 0 past events
	And I should see 0 unpublished events

Scenario: View "Forum" events list
	When I go to the events page
	And I filter by "forum"
	Then I should see a list of 2 upcoming "forum" events
	And I should see 0 past events
	And I should see 0 unpublished events

Scenario: View "Sponsored" events list
	When I go to the events page
	And I filter by "sponsored"
	Then I should see a list of 2 upcoming "sponsored" events
	And I should see 0 past events
	And I should see 0 unpublished events

Scenario: Pagination
	Given there are 12 events
	When I go to the events page
	Then I should see 10 events
	And there should be pagination

Scenario: View an individual event
	Given there is 1 event
	When I go to that event's page
	Then I should see the event's information
	And I should see article meta

Scenario: Visit a page for an event that doesn't exist
	When I go to an event page for an event that doesn't exist
	Then I should be redirected to the events page
