___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Decode Unicode",
  "description": "Convert unicode entities.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "input",
    "displayName": "Select variable",
    "macrosInSelect": true,
    "selectItems": [],
    "simpleValueType": true,
    "defaultValue": "clip-in ponytail gjord av \\u00e4kta h\\u00e5r \\u00bb 7.3 cendre ash 40 cm"
  }
]


___SANDBOXED_JS_FOR_SERVER___

const logToConsole = require('logToConsole');
const createRegex = require('createRegex');
const getEventData = require('getEventData');
const JSON = require('JSON');

let input = data.input;
let output;

let pattern_encode = createRegex('\\\\u([\\dA-F]{4})', 'gi');

output = input.replace(pattern_encode, function (match) {
  
  return JSON.parse('["' + match + '"]')[0];
});

logToConsole(output);

return output;


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 27/07/2023, 15:21:05


