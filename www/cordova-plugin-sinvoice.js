var exec = require('cordova/exec');

var sinVoice = {
  getWifiName: function (success, error) {
    exec(success, error,  "SinVoice","getWifiName", []);
  },
  startSend: function (wifi, password, success, error) {
    exec(success, error,  "SinVoice","startSend", [wifi, password]);
  },
  stopSend: function (success, error) {
    exec(success, error,  "SinVoice","stopSend", []);
  }
};
module.exports = sinVoice;
