___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "RegEx Transformer",
  "description": "A utility to use regex operations to transform any value in a variable over multiple steps. Perfect for PII removal based on RegEx conditions.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "CHECKBOX",
    "name": "static_mode",
    "checkboxText": "Use a constant value for testing",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "When ticked, you\u0027re able to enter a static string value to use for testing purpose. It\u0027s helpful during configuration and validating of the complex regex patterns.",
    "displayName": "Enable variable debug mode"
  },
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
    "alwaysInSummary": false,
    "enablingConditions": [
      {
        "paramName": "static_mode",
        "paramValue": false,
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "input_static",
    "displayName": "Enter a static value",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "static_mode",
        "paramValue": true,
        "type": "EQUALS"
      }
    ],
    "defaultValue": "loream ipsum dolor..."
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
      },
      {
        "defaultValue": "",
        "displayName": "Comment",
        "name": "row_comment",
        "type": "TEXT"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const log = require('logToConsole');
const createRegex = require('createRegex');
const decodeUri = require('decodeUri');
const getEventData = require('getEventData');
const parseUrl = require('parseUrl');
const template_name = 'RegEx Transformer';

const transformer = {};

let input;
let input_string;
let url_parts;

if(data.static_mode)
{
  input_string = data.input_static.length ? data.input_static.toString() : "";
}
else if(!data.static_mode)
{
  
    if(data.input === 'input_default')
    {
      input = parseUrl(getEventData('page_location'));
      
      if(input && input.hasOwnProperty('href'))
      {
        input_string = decodeUri(input.href);
      }
      else
      {
        return input;
      }
    }
    else
    {
      if(data.input === undefined || data.input === null)
      {
        return input;
      }
      else
      {
        input_string = data.input.toString();
      }
    }
}


let pattern_encode_at_sign = createRegex('%40', 'gi');
transformer.org_input = input_string.replace(pattern_encode_at_sign, '@');
transformer.operating_input = transformer.org_input;
transformer.operating_output = transformer.org_input;
transformer.op_table = data.operations;


log("### " + template_name + " ####");
log("Original input value: ", transformer.org_input);


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

        log("ROW " + i + " input value:", transformer.operating_input);
        log("ROW " + i + " output value:", transformer.operating_output);
      
        transformer.operating_input = transformer.operating_output;

    }

    log("Final output value: ", transformer.operating_output);
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
    //logToConsole("transformer.op_equals_to(), new value:", transformer.operating_output);
};

transformer.op_regex_replace = (check, flags) =>
{
    let pattern = createRegex(check.op_criteria, flags);
    //log("criteria:", check.op_criteria);
    //log("replacement:", check.op_out);
    transformer.operating_output = transformer.operating_output.replace(pattern, check.op_out);
    //log("transformer.op_regex_replace(), new value:", transformer.operating_output);

};

transformer.op_default = () =>
{
    transformer.operating_output = transformer.operating_output;
    //logToConsole("transformer.op_default(), new value:", transformer.operating_output);
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
      input: 'https://www.nelsongarden.pl/?demo=aaa@bbb.com&ccc=22222&tel=031000000',
      operations: [
        {'op_type': 'regex_replace_gci', 'op_criteria': '(=)(([^@&#]+|)@[^&#]+)', 'op_out': '$1[EMAIL REDACTED]'},
        {'op_type': 'regex_replace_gci', 'op_criteria': '(?:(tel|phone|call|callto|im|sip|sips|conf)(:|=))([0-9]+)', 'op_out': '$1$2[DDD]'}
      ]
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);


___NOTES___

Created on 06/12/2023, 11:10:09


