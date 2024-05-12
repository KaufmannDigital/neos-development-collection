@contentrepository @adapters=DoctrineDBAL
Feature: Rename Property

  Background:
    Given using no content dimensions
    And using the following node types:
    """yaml
    'Neos.ContentRepository:Root':
      constraints:
        nodeTypes:
          'Neos.ContentRepository.Testing:Document': true
    'Neos.ContentRepository.Testing:Document':
      properties:
        text:
          type: string
    """
    And using identifier "default", I define a content repository
    And I am in content repository "default"

    And the command CreateRootWorkspace is executed with payload:
      | Key                        | Value                |
      | workspaceName              | "live"               |
      | workspaceTitle             | "Live"               |
      | workspaceDescription       | "The live workspace" |
      | newContentStreamId | "cs-identifier"      |
    And the graph projection is fully up to date
    And I am in the active content stream of workspace "live"
    And the command CreateRootNodeAggregateWithNode is executed with payload:
      | Key                         | Value                         |
      | nodeAggregateId     | "lady-eleonode-rootford"      |
      | nodeTypeName                | "Neos.ContentRepository:Root" |
    And the graph projection is fully up to date
    # Node /document
    When the command CreateNodeAggregateWithNode is executed with payload:
      | Key                           | Value                                     |
      | nodeAggregateId       | "sir-david-nodenborough"                  |
      | nodeTypeName                  | "Neos.ContentRepository.Testing:Document" |
      | originDimensionSpacePoint     | {}                                        |
      | parentNodeAggregateId | "lady-eleonode-rootford"                  |
      | initialPropertyValues         | {"text": "Original text"}                 |
    And the graph projection is fully up to date


  Scenario: Fixed newValue
    Given I change the node types in content repository "default" to:
    """yaml
    'Neos.ContentRepository:Root':
      constraints:
        nodeTypes:
          'Neos.ContentRepository.Testing:Document': true
    'Neos.ContentRepository.Testing:Document':
      properties:
        text:
          type: string
        newText:
          type: string
    """
    When I run the following node migration for workspace "live", creating target workspace "migration-workspace", without publishing on success:
    """yaml
    migration:
      -
        filters:
          -
            type: 'NodeType'
            settings:
              nodeType: 'Neos.ContentRepository.Testing:Document'
        transformations:
          -
            type: 'RenameProperty'
            settings:
              from: 'text'
              to: 'newText'
    """
    # the original content stream has not been touched
    When I am in the active content stream of workspace "live" and dimension space point {}
    Then I get the node with id "sir-david-nodenborough"
    And I expect this node to have the following properties:
      | Key  | Value           |
      | text | "Original text" |

    # the node type was changed inside the new content stream
    When I am in the active content stream of workspace "migration-workspace" and dimension space point {}
    Then I get the node with id "sir-david-nodenborough"
    And I expect this node to have the following properties:
      | Key     | Value           |
      | newText | "Original text" |
    And I expect this node to not have the property "text"



