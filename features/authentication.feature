Feature: Authentication

  Scenario: I should be able to sign into the application using my Fitbit credentials
    Given I am on the homepage
    When sign in with FitBit
    Then I should be on the "/heartrate"
