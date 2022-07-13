var fs = require('fs');
const util = require('util');
const readFileAsync = util.promisify(fs.readFile);
let path = require("path");

exports.handler = async function(event) {
    
    console.log(path.resolve("./index.html"));
    var html = fs.readFileSync(__dirname +'/index.html', 'utf8');
    html = html.replace(/S3_BUCKET/g,  "https://replace-bucket-name.s3.us-east-1.amazonaws.com/build");
    return {
          'statusCode': 200,
          'headers': {'Content-Type': 'text/html'},
          'body': html
    }
              
}