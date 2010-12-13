Feature: Deliver promised features
  In order to make admins and users happy
  Cligu should deliver on its promised features

Scenario: Help
  When I run "./cligu --help"
  Then I should see "Usage:" in the output

Scenario: Extend Group
  Given user "zweihamm" is not in the group "testgroup"
  When I run "./cligu group:testgroup+zweihamm"
  Then user "zweihamm" is in the group "testgroup"



