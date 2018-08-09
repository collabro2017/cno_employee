Feature: Find Selects
  In order to quickly add selects to my count
  As a user
  I want to be able to easily find a specific field that I want to use as select

Scenario: Display select
  Given I am the owner of a count
    And The count's datasource has fields with categories
  When I go to the edit count page
  Then I can see the "available selects" pane
    And I can see all the datasource's selectable fields in there
    And the most commonly used fields float up
    And the fields are grouped into the right category

@javascript
Scenario: Quick find a specific field
  Given I am in the count edit page
    And The count's datasource has fields with categories
  When I start typing in the fields search box
  Then I can only see the fields that are the closest match to the text that I entered

@javascript
Scenario: Show field descriptions
  Given I am in the count edit page
    And The count's datasource has fields with categories
  When I hover over a field from the list
  Then I can see the field description
