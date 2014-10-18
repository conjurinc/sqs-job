Feature: Successfully send a message

  Scenario: A sent message can be received and processed
    When I send a message
    Then the message is processed
