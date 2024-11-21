extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:0.1.8-preview'
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/beta:0.1.8-preview'

param connections_bluesky_name string = 'S4MSC-Bluesky'
param region string = 'uksouth'
param tenantId string = region
param clientId string = ''
param clientSecret string = ''

var workflows_SearchConnectorSetup_name_var = 'la-${connections_bluesky_name}-setup'
var workflows_SearchConnectorSearch_name_var = 'la-${connections_bluesky_name}-search'
var workflows_SearchConnectorTrigger_name_var = 'la-${connections_bluesky_name}-trigger'
var graphConnectorUrl = 'https://graph.microsoft.com/beta/external/connections/${connections_bluesky_name}SearchConnector'

/*
resource clientApp 'Microsoft.Graph/applications@beta' = {
  uniqueName: 'S4MSC-Bluesky'
  displayName: 'S4MSC-Bluesky'
  signInAudience: 'AzureADMyOrg'
  requiredResourceAccess: [
    {
     resourceAppId: '00000003-0000-0000-c000-000000000000'
     resourceAccess: [
       {id: 'b8aafc4d-6a4e-4d3b-8f7b-7b4b1b8e1b8e', type: 'Role'}
     ]
    }
  ]
}
*/

// var clientId = clientApp.appId
// var clientSecret = clientApp.passwordCredentials[0].secretText

resource workflows_SearchConnectorSetup_name 'Microsoft.Logic/workflows@2017-07-01' = {
  name: workflows_SearchConnectorSetup_name_var
  location: region
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {}
          }
        }
      }
      actions: {
        Check_BlueskySearchConnector_exists: {
          type: 'Http'
          inputs: {
            uri: 'https://graph.microsoft.com/beta/external/connections/S4MSCBlueskySearchConnector'
            method: 'GET'
            authentication: {
              audience: 'https://graph.microsoft.com'
              clientId: ''
              secret: ''
              tenant: ''
              type: 'ActiveDirectoryOAuth'
            }
          }
          runAfter: {}
        }
        Check_schema_exists: {
          type: 'Http'
          inputs: {
            uri: 'https://graph.microsoft.com/beta/external/connections/S4MSCBlueskySearchConnector/schema'
            method: 'GET'
            authentication: {
              audience: 'https://graph.microsoft.com'
              clientId: ''
              secret: ''
              tenant: ''
              type: 'ActiveDirectoryOAuth'
            }
          }
          runAfter: {
            'Create_S4MSC-BlueskySearchConnector_if_doesn\'t_exist': [
              'Succeeded'
              'Skipped'
            ]
          }
        }
        'Create_S4MSC-BlueskySearchConnector_if_doesn\'t_exist': {
          type: 'Http'
          inputs: {
            uri: 'https://graph.microsoft.com/beta/external/connections'
            method: 'POST'
            body: {
              description: 'Connector for showing key tweets'
              id: 'S4MSCBlueskySearchConnector'
              name: 'Bluesky Connector'
            }
            authentication: {
              audience: 'https://graph.microsoft.com'
              clientId: ''
              secret: ''
              tenant: ''
              type: 'ActiveDirectoryOAuth'
            }
          }
          runAfter: {
            Check_BlueskySearchConnector_exists: [
              'Failed'
            ]
          }
        }
        'Create_schema_if_it_doesn\'t_exists': {
          type: 'Http'
          inputs: {
            uri: 'https://graph.microsoft.com/beta/external/connections/S4MSCBlueskySearchConnector/schema'
            method: 'POST'
            body: {
              baseType: 'microsoft.graph.externalItem'
              properties: [
                {
                  isQueryable: true
                  isRefinable: false
                  isRetrievable: true
                  isSearchable: true
                  name: 'uri'
                  type: 'String'
                }
                {
                  isQueryable: true
                  isRefinable: false
                  isRetrievable: true
                  isSearchable: true
                  name: 'aturi'
                  type: 'String'
                }
                {
                  isQueryable: true
                  isRefinable: false
                  isRetrievable: true
                  isSearchable: true
                  name: 'authorName'
                  type: 'String'
                }
                {
                  isQueryable: true
                  isRefinable: false
                  isRetrievable: true
                  isSearchable: true
                  name: 'authorHandle'
                  type: 'String'
                }
                {
                  isQueryable: true
                  isRefinable: false
                  isRetrievable: true
                  isSearchable: true
                  name: 'authorAvatarUri'
                  type: 'String'
                }
                {
                  isQueryable: true
                  isRefinable: false
                  isRetrievable: true
                  isSearchable: true
                  name: 'mediaUri'
                  type: 'String'
                }
                {
                  isQueryable: true
                  isRefinable: false
                  isRetrievable: true
                  isSearchable: false
                  name: 'indexedAt'
                  type: 'DateTime'
                }
                {
                  isQueryable: false
                  isRefinable: false
                  isRetrievable: true
                  isSearchable: false
                  name: 'replyCount'
                  type: 'Int64'
                }
                {
                  isQueryable: false
                  isRefinable: false
                  isRetrievable: true
                  isSearchable: false
                  name: 'repostCount'
                  type: 'Int64'
                }
                {
                  isQueryable: false
                  isRefinable: false
                  isRetrievable: true
                  isSearchable: false
                  name: 'likeCount'
                  type: 'Int64'
                }
                {
                  isQueryable: false
                  isRefinable: false
                  isRetrievable: true
                  isSearchable: false
                  name: 'quoteCount'
                  type: 'Int64'
                }
              ]
            }
            authentication: {
              audience: 'https://graph.microsoft.com'
              clientId: ''
              secret: ''
              tenant: ''
              type: 'ActiveDirectoryOAuth'
            }
          }
          runAfter: {
            Check_schema_exists: [
              'Failed'
            ]
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        type: 'Object'
        defaultValue: {}
      }
    }  
  }
}

resource bluesky 'Microsoft.Web/connections@2016-06-01' = {
  name: 'bluesky'
  location: region
  kind: 'V1'
  properties: {
    displayName: 'Bluesky'
    statuses: [
      {
        status: 'Connected'
      }
    ]
    customParameterValues: {}
    api: {
      name: 'bluesky'
      displayName: 'Bluesky'
      description: 'Bluesky is an online social networking service that enables users to send and receive short messages called \'tweets\'. Connect to Bluesky to manage your tweets. You can perform various actions such as send tweet, search, view followers, etc.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1473/1.0.1473.2431/bluesky/icon.png'
      brandColor: '#5fa9dd'
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${region}/managedApis/twitter'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: []
  }
}

resource workflows_SearchConnectorSearch_name 'Microsoft.Logic/workflows@2017-07-01' = {
  name: workflows_SearchConnectorSearch_name_var
  location: region
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {}
          }
        }
      }
      actions: {
        Get_token: {
          type: 'Http'
          inputs: {
            uri: 'https://bsky.social/xrpc/com.atproto.server.createSession'
            method: 'POST'
            body: {
              identifier: 'kevin@mcd79.com'
              password: '$I2$biUGhh9$'
            }
          }
          runAfter: {}
          runtimeConfiguration: {
            contentTransfer: {
              transferMode: 'Chunked'
            }
          }
        }
        Search_posts: {
          type: 'Http'
          inputs: {
            uri: 'https://bsky.social/xrpc/app.bsky.feed.searchPosts?q=copilot&limit=50'
            method: 'GET'
            headers: {
              Authorization: 'Bearer @{body(\'Parse_JSON\')?[\'accessJwt\']}'
            }
          }
          runAfter: {
            Parse_JSON: [
              'Succeeded'
            ]
          }
          runtimeConfiguration: {
            contentTransfer: {
              transferMode: 'Chunked'
            }
          }
        }
        Parse_JSON: {
          type: 'ParseJson'
          inputs: {
            content: '@body(\'Get_token\')'
            schema: {
              type: 'object'
              properties: {
                did: {
                  type: 'string'
                }
                didDoc: {
                  type: 'object'
                  properties: {
                    '@@context': {
                      type: 'array'
                      items: {
                        type: 'string'
                      }
                    }
                    id: {
                      type: 'string'
                    }
                    alsoKnownAs: {
                      type: 'array'
                      items: {
                        type: 'string'
                      }
                    }
                    verificationMethod: {
                      type: 'array'
                      items: {
                        type: 'object'
                        properties: {
                          id: {
                            type: 'string'
                          }
                          type: {
                            type: 'string'
                          }
                          controller: {
                            type: 'string'
                          }
                          publicKeyMultibase: {
                            type: 'string'
                          }
                        }
                        required: [
                          'id'
                          'type'
                          'controller'
                          'publicKeyMultibase'
                        ]
                      }
                    }
                    service: {
                      type: 'array'
                      items: {
                        type: 'object'
                        properties: {
                          id: {
                            type: 'string'
                          }
                          type: {
                            type: 'string'
                          }
                          serviceEndpoint: {
                            type: 'string'
                          }
                        }
                        required: [
                          'id'
                          'type'
                          'serviceEndpoint'
                        ]
                      }
                    }
                  }
                }
                handle: {
                  type: 'string'
                }
                email: {
                  type: 'string'
                }
                emailConfirmed: {
                  type: 'boolean'
                }
                emailAuthFactor: {
                  type: 'boolean'
                }
                accessJwt: {
                  type: 'string'
                }
                refreshJwt: {
                  type: 'string'
                }
                active: {
                  type: 'boolean'
                }
              }
            }
          }
          runAfter: {
            Get_token: [
              'Succeeded'
            ]
          }
        }
        Parse_Search: {
          type: 'ParseJson'
          inputs: {
            content: '@body(\'Search_posts\')'
            schema: {
              type: 'object'
              properties: {
                posts: {
                  type: 'array'
                  items: {
                    type: 'object'
                    properties: {
                      uri: {
                        type: 'string'
                      }
                      cid: {
                        type: 'string'
                      }
                      author: {
                        type: 'object'
                        properties: {
                          did: {
                            type: 'string'
                          }
                          handle: {
                            type: 'string'
                          }
                          displayName: {
                            type: 'string'
                          }
                          avatar: {
                            type: 'string'
                          }
                          createdAt: {
                            type: 'string'
                          }
                        }
                      }
                      record: {
                        type: 'object'
                        properties: {
                          '$type': {
                            type: 'string'
                          }
                          createdAt: {
                            type: 'string'
                          }
                          text: {
                            type: 'string'
                          }
                        }
                      }
                      replyCount: {
                        type: 'integer'
                      }
                      repostCount: {
                        type: 'integer'
                      }
                      likeCount: {
                        type: 'integer'
                      }
                      quoteCount: {
                        type: 'integer'
                      }
                      indexedAt: {
                        type: 'string'
                      }
                      embed: {
                        type: 'object'
                        properties: {
                          '$type': {
                            type: 'string'
                          }
                          external: {
                            type: 'object'
                            properties: {
                              uri: {
                                type: 'string'
                              }
                              title: {
                                type: 'string'
                              }
                              description: {
                                type: 'string'
                              }
                              thumb: {
                                type: 'string'
                              }
                            }
                          }
                        }
                      }
                    }
                    required: [
                      'uri'
                      'cid'
                      'author'
                      'record'
                      'replyCount'
                      'repostCount'
                      'likeCount'
                      'quoteCount'
                      'indexedAt'
                      'viewer'
                    ]
                  }
                }
                cursor: {
                  type: 'string'
                }
              }
            }
          }
          runAfter: {
            Search_posts: [
              'Succeeded'
            ]
          }
        }
        For_each_2: {
          type: 'Foreach'
          foreach: '@outputs(\'Parse_Search\')?[\'body\']?[\'posts\']'
          actions: {
            HTTP: {
              type: 'Http'
              inputs: {
                uri: 'https://graph.microsoft.com/beta/external/connections/S4MSCBlueskySearchConnector/items/@{item()?[\'cid\']}'
                method: 'PUT'
                body: {
                  acl: [
                    {
                      accessType: 'grant'
                      identitySource: 'azureActiveDirectory'
                      type: 'everyone'
                      value: '43c5e796-f484-4157-8c93-73ac8b1cf7bf'
                    }
                  ]
                  content: {
                    type: 'text'
                    value: '@{item()?[\'record\']?[\'text\']}'
                  }
                  properties: {
                    uri: '@{item()?[\'uri\']}'
                    aturi: ''
                    authorName: ''
                    authorHandle: ''
                    authorAvatarUri: ''
                    mediaUri: ''
                    indexedAt: '@{item()?[\'record\']?[\'createdAt\']}'
                    replyCount: '@item()?[\'replyCount\']'
                    repostCount: '@item()?[\'repostCount\']'
                    likeCount: '@item()?[\'likeCount\']'
                    quoteCount: '@item()?[\'quoteCount\']'
                  }
                  type: 'microsoft.graph.externalItem'
                }
                authentication: {
                  audience: 'https://graph.microsoft.com'
                  clientId: ''
                  secret: ''
                  tenant: ''
                  type: 'ActiveDirectoryOAuth'
                }
              }
            }
          }
          runAfter: {
            Parse_Search: [
              'Succeeded'
            ]
          }
        }
      }
      outputs: {}
      parameters: {
        '$connections': {
          type: 'Object'
          defaultValue: {}
        }
      }
    }
    parameters: {
      '$connections': {
        value: {}
      }
    }
  }
}
