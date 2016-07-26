{
  "version" => "1.0",
  "href" =>    "https://api-sandbox.pmp.io/schemas/broadcast",
  "attributes" => {
    "title" => "Broadcast Schema",
    "schema" => { 
      "$schema"  => "http://json-schema.org/draft-04/schema#",
      "id" => "https://api-sandbox.pmp.io/schemas/broadcast",
      "description" => "PMP Validation Schema for Broadcast Profile",
      "type" => "object",
      "allOf" => [
        {"$ref" => "https://api-sandbox.pmp.io/schemas/audio"},
        {"$ref" => "#broadcastSchema"}
      ]
    },
    "definitions" => {
      "broadcastSchema" => {
        "id" => "#broadcastSchema",
        "description" => "Broadcast profile definition",
        "properties" => {
          "attributes" => {
            "description" => "Broadcast metadata",
            "$ref" => "#attributes"
          }
        }
      },
      "attributes" => {
        "id" => "#attributes",
        "description" => "Broadcast metadata object",
        "type" => "object",
        "properties" =>{
          "script" => {
            "description" => "Content, without HTML, which can be read live over the air or used as a reference when playing back audio.",
            "type" => "string"
          }
        }
      }
    },
    "published" => "2016-07-26T13:21:31+00:00"
  },
  "links" => {
    "profile" => [{
      "href" => "https://api-sandbox.pmp.io/profiles/schema"
    }]
  }
}