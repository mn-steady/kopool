angular.module('RailsApiResource', ['ngResource'])

  .constant('KOPOOL_CONFIG',
    {
      PROTOCOL: 'http',
      HOSTNAME: 'localhost:3000',
    })

  .factory 'RailsApiResource', ($http, KOPOOL_CONFIG, $cookieStore) ->

    (resourceName, id, rootNode) ->
      console.log("(RailsApiResource) resourceName:" + resourceName)
      if resourceName.indexOf(":id") > -1?
        resourceName = resourceName.replace(/:id/, id)
        console.log("Resource will be: " + resourceName)

      collectionUrl = KOPOOL_CONFIG.PROTOCOL + '://' + KOPOOL_CONFIG.HOSTNAME + '/' + resourceName + '.json'

      defaultParams = { foo: "bar" }
      headers = {
      }

      # Utility methods
      getId = (data) ->
        data._id.$oid

      # A constructor for new resources
      Resource = (data) ->
        angular.extend(this, data)

      Resource.query = (queryJson) ->
        console.log("(RailsApiResource.Resource.query) queryJson="+queryJson)
        params = if angular.isObject(queryJson) then queryJson else {}
        console.log("(RailsApiResource.Resource.query) params="+params)

        #, headers: headers
        $http.get(collectionUrl, {params:angular.extend({}, defaultParams, params)} ).then( (response) ->
          result = []
          console.log("(RailsApiResource.query) response="+response.data)

          if response.data instanceof Array
            console.log("is an Array")
            angular.forEach(response.data, (value, key) ->
              console.log("key:" + key + " value:" + value)
              result[key] = new Resource(value)
            )
          else
            console.log("is an Object")
            data_of_interest = eval("response.data."+rootNode)
            angular.forEach(data_of_interest, (value, key) ->
              result[key] = new Resource(value)
            )
          )

      Resource.save = (data) ->
        console.log("Resource.save")
        $http.post(collectionUrl, data, { params:defaultParams }).then( (response) ->
          new Resource(data)
        )

      Resource.prototype.$save = (data) ->
        Resource.save(this)

      Resource

