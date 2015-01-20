(function() {

    var RESTStoragePlugin = window.RESTStoragePlugin || {};

    RESTStoragePlugin.parseResponse = function(response_body) {
        return response_body;
    }
 
    window.RESTStoragePlugin = RESTStoragePlugin;

})(window);

1; // Mark the evaluation process successfull