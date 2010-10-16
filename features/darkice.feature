@darkice
Feature: Monitor darkice source
  In order to configure its stream
  An user
  wants to have a concrete feedback on darkice activity

  Scenario: Normal startup
  When darkice starts
  Then I should see an event "Source démarrée"

  Scenario: Partial or invalid configuration
  Given no stream is configured in darkice
  When darkice starts
  Then I should see events:
  | Configuration partielle |
  | Source démarrée         |
  | Source stoppée          |

  Scenario: Invalid password in vorbis
  Given the stream server refuses authentication
  When darkice starts
  Then I should see an event "Flux Vorbis mal paramétré"

  Scenario: Invalid hostname
  Given the stream server is "dummy"
  When darkice starts
  Then I should see an event "Nom du serveur non trouvé"

  Scenario: Invalid port
  Given the stream port is "8001"
  When darkice starts
  Then I should see an event "Connection au serveur impossible"

  Scenario: Darkice killed
  Given darkice is running
  When darkice is killed
  Then I should see an event "Source stoppée"
