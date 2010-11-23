http = require("http");
exports.Juice = function(){
  
  return function(imageUrl, exports, callback){
    juicer = http.createClient('80', 'http://app.imagejuicer.com');
    request = juicer.request('POST', '/jobs?token=' + options.apiKey);
    request.end();
    request.on('response',function(response){
      request.on('data', function(data){
        callback(JSON.parse(data));
      });
    });
  };
  
};