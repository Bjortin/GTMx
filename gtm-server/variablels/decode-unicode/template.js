const logToConsole = require('logToConsole');
const createRegex  = require('createRegex');
const getEventData = require('getEventData');
const JSON         = require('JSON');

let input          = data.input;
let pattern_encode = createRegex('\\\\u([\\dA-F]{4})', 'gi');
let output;


output = input.replace(pattern_encode, function (match) 
{  
  return JSON.parse('["' + match + '"]')[0];
});

logToConsole(output);

return output;
