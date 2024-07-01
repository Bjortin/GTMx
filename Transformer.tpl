___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Transformer",
  "description": "A utility to use regex operations to transform any value in a variable over multiple steps. Perfect for PII removal based on RegEx conditions.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "input",
    "displayName": "Select the input variable to operate upon",
    "macrosInSelect": true,
    "selectItems": [
      {
        "value": "input_default",
        "displayValue": "page_location"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "input_default",
    "alwaysInSummary": false
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "operations",
    "displayName": "All operations will be run in the order given. Capturing Groups are allowed in the Operation output filed. The output of a previous step will be the input value of the next until all operations are completed.",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Select type of operation",
        "name": "op_type",
        "type": "SELECT",
        "selectItems": [
          {
            "value": "equals_to",
            "displayValue": "equals to"
          },
          {
            "value": "regex_replace_g",
            "displayValue": "regex replace global"
          },
          {
            "value": "regex_replace_gci",
            "displayValue": "regex replace global (case insensitive)"
          },
          {
            "value": "regex_replace",
            "displayValue": "regex replace"
          },
          {
            "value": "not_equals_to",
            "displayValue": "not equals to"
          }
        ]
      },
      {
        "defaultValue": "",
        "displayName": "Operation ciriteria",
        "name": "op_criteria",
        "type": "TEXT"
      },
      {
        "defaultValue": "",
        "displayName": "Operation output",
        "name": "op_out",
        "type": "TEXT"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const logToConsole = require('logToConsole');
const createRegex = require('createRegex');
const decodeUri = require('decodeUri');
const getEventData = require('getEventData');
const parseUrl = require('parseUrl');

const transformer = {};

let url_parts = parseUrl(data.input === 'input_default' ? getEventData('page_location') : data.input);

logToConsole('### TEST ###');
logToConsole(decodeUri('https://se.fazer.com/search?q=test2%40fazer.com&options%5Bprefix%5D=last&sort_by=relevance'));


//logToConsole('############');
//logToConsole(url_parts.href);
//logToConsole('############');
//logToConsole(decodeUri(url_parts.href));
//logToConsole('############');

if(url_parts === undefined ||!url_parts.hasOwnProperty('href'))
{
  return data.input;
}

let raw_href = decodeUri(url_parts.href);

let pattern_encode_at_sign = createRegex('%40', 'gi');
transformer.org_input = raw_href.replace(pattern_encode_at_sign, '@');
transformer.operating_output = transformer.org_input;
transformer.op_table = data.operations;


logToConsole("### BASE DATA ####");
logToConsole("transformer.op_table:", transformer.op_table);
logToConsole("transformer.org_input:", transformer.org_input);
logToConsole("transformer.operating_output:", transformer.operating_output);


if(transformer.op_table && !transformer.op_table.length)
{
    return transformer.operating_output;
}


transformer.base = () =>
{

    for (let i = 0; i < transformer.op_table.length; i++)
    {
        let row = transformer.op_table[i];
        switch (row.op_type)
        {

            /** Equal to operators **/
            case 'equals_to' :
                transformer.op_equals_to(row, '===');
                break;

            case 'not_equals_to' :
                transformer.op_equals_to(row, '!==');
                break;




            /** RegEx to operators **/
            case 'regex_replace' :
                transformer.op_regex_replace(row, '');
                break;

            case 'regex_replace_ci' :
                transformer.op_regex_replace(row, 'i');
                break;

            case 'regex_replace_g' :
                transformer.op_regex_replace(row, 'g');
                break;

            case 'regex_replace_gci' :
                transformer.op_regex_replace(row, 'gi');
                break;


            default:
                transformer.op_default();
                break;
        }

        logToConsole("ROW " + i, transformer.operating_output);
    }

    return transformer.operating_output;

};

transformer.op_equals_to = (check, flags) =>
{

    if(flags === "===")
    {
        transformer.operating_output = (transformer.operating_output === check.op_criteria) ? check.op_out : transformer.operating_output;
    }
    else if (flags === "!==")
    {
        transformer.operating_output = (transformer.operating_output !== check.op_criteria) ? check.op_out : transformer.operating_output;
    }
    logToConsole("transformer.op_equals_to(), new value:", transformer.operating_output);
};

transformer.op_regex_replace = (check, flags) =>
{
    let pattern = createRegex(check.op_criteria, flags);
    transformer.operating_output = transformer.operating_output.replace(pattern, check.op_out);
    logToConsole("transformer.op_regex_replace(), new value:", transformer.operating_output);

};

transformer.op_default = () =>
{
    transformer.operating_output = transformer.operating_output;
    logToConsole("transformer.op_default(), new value:", transformer.operating_output);
};

return transformer.base();


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
            "string": "all"
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
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "page_location"
              }
            ]
          }
        },
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "specific"
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

scenarios:
- name: Remove potential email address from any parameter
  code: |-
    const mockData = {
      input: 'https://se.fazer.com/search?q=test2%40fazer.com&options%5Bprefix%5D=last&sort_by=relevance',
      operations: [
        {'op_type': 'regex_replace_gci', 'op_criteria': '(=)(([^@&#]+|)@[^&#]+)', 'op_out': '$1[EMAIL REDACTED]'}
      ]
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);


___NOTES___

Created on 06/12/2023, 11:10:09


