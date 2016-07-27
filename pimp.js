pmpsdk    = require('pmpsdk')
yaml      = require('js-yaml')
fs        = require('fs')
config    = yaml.safeLoad(fs.readFileSync('config/secrets.yml', 'utf8'), {json: true}).development

pmp = new pmpsdk({
  host: config.api.pmp.endpoint,
  clientid: config.api.pmp.write.client_id,
  clientsecret: config.api.pmp.write.client_secret
})

doc = {
  version: "1.0", 
  attributes:  {
    title: "Broadcast Schema", 
    guid: "d63366aa-0bfa-430e-ad77-68996e243269",
    schema: {
      $schema: "http://json-schema.org/draft-04/schema#", 
      id: "https://api-sandbox.pmp.io/schemas/broadcast", 
      description: "PMP Validation Schema for Broadcast Profile", 
      type: "object", 
      allOf: [
        {"$ref": "https://api-sandbox.pmp.io/schemas/audio"}, 
        {"$ref": "#broadcastSchema"}
      ]
    }, 
    definitions: {
      broadcastSchema: {
        id: "#broadcastSchema", 
        description: "Broadcast profile definition", 
        properties: {
          attributes: {
            description: "Broadcast metadata", 
            $ref: "#attributes"
          }
        }
      }, 
      attributes: {
        id: "#attributes", 
        description: "Broadcast metadata object", 
        type: "object", 
        properties: {
          script: {
            description: "Content, without HTML, which can be read live over the air or used as a reference when playing back audio.", 
            type: "string"
          }
        }
      }
    }
  }, 
  links: {
    profile: [
      {href: "https://api-sandbox.pmp.io/profiles/broadcast"}
    ]
  },
  endpoint: "https://api-sandbox.pmp.io"
}

pmp.createDoc('schema', doc, function(doc, resp){
  debugger
})