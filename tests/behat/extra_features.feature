@mod @mod_attendance @javascript
Feature: Test the various new features in the attendance module

  Background:
    Given the following "courses" exist:
      | fullname | shortname |
      | Course 1 | C1        |
    And the following "users" exist:
      | username | firstname | lastname | email                |
      | teacher1 | Teacher   | 1        | teacher1@example.com |
      | student1 | Student   | 1        | student1@example.com |
      | student2 | Student   | 2        | student2@example.com |
      | student3 | Student   | 3        | student3@example.com |
      | student4 | Student   | 4        | student4@example.com |
      | student5 | Student   | 5        | student5@example.com |
    And the following "course enrolments" exist:
      | course | user     | role           |
      | C1     | teacher1 | editingteacher |
      | C1     | student1 | student        |
      | C1     | student2 | student        |
      | C1     | student3 | student        |
    And I log in as "teacher1"
    And I follow "Course 1"
    And I turn editing mode on
    And I add a "Attendance" to section "1" and I fill the form with:
      | Name | Test attendance |
    And I log out

  Scenario: A teacher can create and update temporary users
    Given I log in as "teacher1"
    And I follow "Course 1"
    And I follow "Test attendance"
    And I follow "Temporary users"

    When I set the following fields to these values:
      | Full name | Temporary user 1 |
      | Email     |                  |
    And I press "Add user"
    And I set the following fields to these values:
      | Full name | Temporary user test 2     |
      | Email     | tempuser2test@example.com |
    And I press "Add user"
    Then I should see "Temporary user 1"
    And "tempuser2test@example.com" "text" should exist in the "Temporary user test 2" "table_row"

    When I click on "Edit user" "link" in the "Temporary user test 2" "table_row"
    And the following fields match these values:
      | Full name | Temporary user test 2     |
      | Email     | tempuser2test@example.com |
    And I set the following fields to these values:
      | Full name | Temporary user 2      |
      | Email     | tempuser2@example.com |
    And I press "Edit user"
    Then "tempuser2@example.com" "text" should exist in the "Temporary user 2" "table_row"

    When I click on "Delete user" "link" in the "Temporary user 1" "table_row"
    And I press "Continue"
    Then I should not see "Temporary user 1"
    And I should see "Temporary user 2"

  Scenario: A teacher can take attendance for temporary users
    Given I log in as "teacher1"
    And I follow "Course 1"
    And I follow "Test attendance"
    And I follow "Temporary users"
    And I set the following fields to these values:
      | Full name | Temporary user 1 |
      | Email     |                  |
    And I press "Add user"
    And I set the following fields to these values:
      | Full name | Temporary user 2      |
      | Email     | tempuser2@example.com |
    And I press "Add user"

    And I follow "Add"
    And I set the following fields to these values:
      | Create multiple sessions | 0 |
    And I click on "submitbutton" "button"

    When I follow "Take attendance"
    # Present
    And I click on "td.c2 input" "css_element" in the "Student 1" "table_row"
    # Late
    And I click on "td.c3 input" "css_element" in the "Student 2" "table_row"
    # Excused
    And I click on "td.c4 input" "css_element" in the "Temporary user 1" "table_row"
    # Absent
    And I click on "td.c5 input" "css_element" in the "Temporary user 2" "table_row"
    And I press "Save attendance"
    And I follow "Report"
    Then "P" "text" should exist in the "Student 1" "table_row"
    And "L" "text" should exist in the "Student 2" "table_row"
    And "E" "text" should exist in the "Temporary user 1" "table_row"
    And "A" "text" should exist in the "Temporary user 2" "table_row"

    When I follow "Temporary user 2"
    Then I should see "Absent"

    # Merge user.
    When I follow "Test attendance"
    And I follow "Temporary users"
    And I click on "Merge user" "link" in the "Temporary user 2" "table_row"
    And I set the field "Participant" to "Student 3"
    And I press "Merge user"
    And I follow "Report"

    Then "P" "text" should exist in the "Student 1" "table_row"
    And "L" "text" should exist in the "Student 2" "table_row"
    And "E" "text" should exist in the "Temporary user 1" "table_row"
    And "A" "text" should exist in the "Student 3" "table_row"
    And I should not see "Temporary user 2"

  Scenario: A teacher can select a subset of users for export
    Given the following "groups" exist:
      | course | name   | idnumber |
      | C1     | Group1 | Group1   |
      | C1     | Group2 | Group2   |
    And the following "group members" exist:
      | group  | user     |
      | Group1 | student1 |
      | Group1 | student2 |
      | Group2 | student2 |
      | Group2 | student3 |

    And I log in as "teacher1"
    And I follow "Course 1"
    And I follow "Test attendance"
    And I follow "Add"
    And I set the following fields to these values:
      | Create multiple sessions | 0 |
    And I click on "submitbutton" "button"

    And I follow "Export"

    When I set the field "Export specific users" to "Yes"
    And I set the field "Group" to "Group1"
    Then the "Users to export" select box should contain "Student 1"
    And the "Users to export" select box should contain "Student 2"
    And the "Users to export" select box should not contain "Student 3"

    When I set the field "Group" to "Group2"
    Then the "Users to export" select box should contain "Student 2"
    And the "Users to export" select box should contain "Student 3"
    And the "Users to export" select box should not contain "Student 1"
    # Ideally the download would be tested here, but that is difficult to configure.

  Scenario: A teacher can create and use multiple status lists
    Given I log in as "teacher1"
    And I follow "Course 1"
    And I follow "Test attendance"
    And I follow "Settings"
    And I set the field "jump" to "New set of statuses"
    And I set the field with xpath "//*[@id='preferencesform']/table/tbody/tr[1]/td[2]/input" to "G"
    And I set the field with xpath "//*[@id='preferencesform']/table/tbody/tr[1]/td[3]/input" to "Great"
    And I set the field with xpath "//*[@id='preferencesform']/table/tbody/tr[1]/td[4]/input" to "3"
    And I click on "Add" "button" in the ".lastrow" "css_element"
    And I set the field with xpath "//*[@id='preferencesform']/table/tbody/tr[2]/td[2]/input" to "O"
    And I set the field with xpath "//*[@id='preferencesform']/table/tbody/tr[2]/td[3]/input" to "OK"
    And I set the field with xpath "//*[@id='preferencesform']/table/tbody/tr[2]/td[4]/input" to "2"
    And I click on "Add" "button" in the ".lastrow" "css_element"
    And I set the field with xpath "//*[@id='preferencesform']/table/tbody/tr[3]/td[2]/input" to "B"
    And I set the field with xpath "//*[@id='preferencesform']/table/tbody/tr[3]/td[3]/input" to "Bad"
    And I set the field with xpath "//*[@id='preferencesform']/table/tbody/tr[3]/td[4]/input" to "0"
    And I click on "Add" "button" in the ".lastrow" "css_element"
    And I click on "Update" "button" in the "#preferencesform" "css_element"

    And I follow "Add"
    And I set the following fields to these values:
      | Create multiple sessions | 0                      |
      | Use status set           | Status set 1 (P L E A) |
      | id_sessiondate_hour      | 10                     |
      | id_sessiondate_minute    | 0                      |
    And I click on "submitbutton" "button"
    And I follow "Add"
    And I set the following fields to these values:
      | Create multiple sessions | 0                    |
      | Use status set           | Status set 2 (G O B) |
      | id_sessiondate_hour      | 11                   |
      | id_sessiondate_minute    | 0                    |
    And I click on "submitbutton" "button"

    When I click on "Take attendance" "link" in the "10:00" "table_row"
    Then "Set status for all users to «Present»" "link" should exist
    And "Set status for all users to «Late»" "link" should exist
    And "Set status for all users to «Excused»" "link" should exist
    And "Set status for all users to «Absent»" "link" should exist

    When I follow "Sessions"
    And I click on "Take attendance" "link" in the "11:00" "table_row"
    Then "Set status for all users to «Great»" "link" should exist
    And "Set status for all users to «OK»" "link" should exist
    And "Set status for all users to «Bad»" "link" should exist

  Scenario: A teacher can use the radio buttons to set attendance values for all users
    Given I log in as "teacher1"
    And I follow "Course 1"
    And I follow "Test attendance"
    And I follow "Add"
    And I set the following fields to these values:
      | Create multiple sessions | 0 |
    And I click on "submitbutton" "button"
    And I click on "Take attendance" "link"

    When I click on "setallstatuses" "field" in the ".takelist tbody td.c3" "css_element"
    And I press "Save attendance"
    And I follow "Report"
    Then "L" "text" should exist in the "Student 1" "table_row"
    And "L" "text" should exist in the "Student 2" "table_row"
    And "L" "text" should exist in the "Student 3" "table_row"
