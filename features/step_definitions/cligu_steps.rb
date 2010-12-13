require 'rspec/matchers'


When /^I run "(.+)"$/ do |command|
  @output = `#{command}`
end

Then /^I should see "(.+)" in the output$/ do |output|
  @output.should =~ /#{output}/
end

Given /^user "(.+)" is not in the group "(.+)"$/ do |user, group|
  When %Q(I run "./cligu group:#{group}%#{user}")
  `getent group #{group}`.should_not =~ /#{user}/
end

Then /^user "(.+)" is in the group "(.+)"$/ do |user, group|
  `getent group #{group}`.should =~ /#{user}/
end
