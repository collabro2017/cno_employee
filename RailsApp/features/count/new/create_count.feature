Feature: Create count
	In order to have a new count created so that I can later on configure and run it
	As a user
	I want to create a new count

Scenario: Show the new count pane
	Given I am on the counts homepage
	When I click the "Create new" button
	#Then I can see the "New count" pane
		And it asks me for the name I want to give to the count
		And it has a suggested name for a count entered by default
		And it asks me to select the Data Source that I would like to use for that count

Scenario Outline: Successfully create the new count
	Given there exists a Datasource named "<Datasource Name>"
		And I was shown the new count pane
		And a count named "<Count Name>" does not exist for my user
	When I enter "<Count Name>" in the "Name" field
		And I select the "<Datasource Name>" from  "Datasource"
		And I click the "Create" button
	Then I am redirected to the count edit page for the newly created count
		And I can see a message saying "A new count has been created!"
		And the count's name is "<Count Name>" 
		And the count's datasource name is "<Datasource Name>"
	Scenarios:
  	  |  Count Name  |  Datasource Name  |
    	|  My Count    |  test_datasource  |

Scenario Outline: Entering a count name that already exists
	Given there exists a Datasource named "<Datasource Name>"
		And I was shown the new count pane
		And there is already a count named "<Count Name>"
	When I enter "<Count Name>" in the "Name" field
		And I select the "<Datasource Name>" from  "Datasource"
		And I click the "Create" button
	Then I can see a message saying "You already have a count named"
		And the message also presents one name suggestion in the form "<Count Name>"-[number]
		And the "Name" field is highlighted because of an error
	Scenarios:
  	  |  Count Name  |  Datasource Name  |
    	|  My Count    |  test_datasource  |


Scenario: Hitting the cancel button 
	Given I was shown the new count pane 
	When I click the "Cancel" link
	Then I am redirected to where I was
#	Then the pane disappears and nothing else happens
