Feature: Programs

Scenario: No Programs
	Given there are 0 kpcc programs
	And there are 0 other programs
	When I go to the programs page
	Then I should not see any programs

Scenario: See the featured programs on the index page
	Given kpcc programs with the following attributes:
		| slug				| title						|
		| madeleine-brand	| The Madeleine Brand Show	|
		| airtalk			| Airtalk					|
		| patt-morrison		| Patt Morrison				|
		| offramp			| Off-Ramp					|
		
	When I go to the programs page
	Then I should see the featured programs in the correct order

Scenario: Attempt to go to a program page that doesn't exist
	Given a kpcc program with the following attributes:
	| slug           |
	| some-cool-show |
	When I go to a program page with slug "not-a-show"
	Then I should be on the programs page

Scenario Outline: View a Featured Program's page
	Given a program titled "<title>" with slug "<slug>"
	When I go to the program's page
	Then I should see the program's information
	Then I should see a headshot of the program's host
	
	Examples:
		| slug				| title						|
		| madeleine-brand	| The Madeleine Brand Show	|
		| airtalk			| Airtalk					|
		| patt-morrison		| Patt Morrison				|
		| offramp			| Off-Ramp					|
		
Scenario: View a KPCC Program's page
	Given there is 1 kpcc program
	When I go to the program's page
	Then I should see the program's information
	And I should not see a video
	
Scenario: View an Other Program's page
	Given there is 1 other program
	When I go to the program's page
	Then I should see the program's information
	And I shouldn't see anything about episodes

Scenario: View cached podcast feed for Other Program
	Given an other program with the following attributes:
	 | podcast_url                     | rss_url |
	 | http://oncentral.org/rss/latest |         |

	And the feeds are cached
	When I go to the program's page
	Then I should see a list of that program's podcast entries
	And I should not see any RSS entries

Scenario: View cached RSS feed for Other Program
	Given an other program with the following attributes:
	 | podcast_url | rss_url                         |
	 |             | http://oncentral.org/rss/latest |

	And the feeds are cached
	When I go to the program's page
	Then I should see a list of that program's RSS entries
	And I should not see any podcast entries

Scenario: View Other Program without rss or podcast
	Given an other program with the following attributes:
	 | podcast_url | rss_url |
	 |             |         |

	When I go to the program's page
	Then I should see that there is nothing to list
	
Scenario: See a program's segments
	Given a kpcc program with the following attributes:
	 | display_segments | display_episodes | segment_count | segment[asset_count] |
	 | 1                | 0                | 2             | 1                    |

	When I go to the program's page
	Then I should see a list of that program's segments
	And I should see each segment's primary asset

Scenario: See an episodic program's episodes
	Given a kpcc program with the following attributes:
	 | display_segments | display_episodes | episode_count | episode[asset_count] |
	 | 0                | 1                | 2             | 1                    |
	
	When I go to the program's page
	Then I should see a list of older episodes below the current episode
	And I should see each episode's primary asset
	
Scenario: See an episodic program's current episode
	Given a kpcc program with the following attributes:
	 | display_segments | display_episodes | episode_count | episode[segment_count] | episode[asset_count] |
	 | 0                | 1                | 2             | 2                      | 1                    |

	When I go to the program's page
	Then I should see the current episode's information
	And I should see the episode's primary asset
	And I should see a list of the current episode's segments

Scenario: See a video player if the program has a dedicated Brightcove player
	Given a kpcc program with the following attributes:
	 | title     | video_player |
	 | Cool Show | 99999        |
	
	When I go to that program's page
	Then I should see a video

Scenario: See the program's missed it bucket if it has one
	Given a kpcc program with the following attributes:
	 | missed_it_bucket[contents_count] |
	 | 3                     |
	
	When I go to the program's page
	Then I should see a missed it bucket
	And the missed it bucket should have 3 items in it
	
Scenario: Do not show a missed it bucket if the program doesn't have one
	Given a kpcc program with the following attributes:
	 | missed_it_bucket_id |
	 |                     |
	
	When I go to that program's page
	Then I should not see a missed it bucket
