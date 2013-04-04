/*
AviaryGap - v.1.0.0
(c) 2013 Ryan Vanderpol, me@ryanvanderpol.com, MIT Licensed.
AviaryPlugin.js may be freely distributed under the MIT license.
*/
var cordova = window.cordova || window.Cordova;

function AviaryPlugin() {}

AviaryPlugin.prototype.edit = function(imageUri, successCallback, errorCallback) {
		cordova.exec(successCallback, errorCallback, 'Aviary', 'editImage', [imageUri]);
	}
};

cordova.addConstructor(function() {
	if(!window.plugins) window.plugins = {};
	window.plugins.aviaryPlugin = new AviaryPlugin();
});
