angular.module('RailsApiResource', ['ngResource'])

  .constant('KOPOOL_CONFIG',
    {
      PROTOCOL: 'http',
      # You have to manually change these for deployment
      # TODO: Make it pull this from an environment variable
      HOSTNAME: 'localhost:3000'
      #HOSTNAME: 'kopool.herokuapp.com'
      #HOSTNAME: 'www.kopool.org'
    })

  .factory 'RailsApiResource', ($http, KOPOOL_CONFIG, $cookieStore) ->

    (resourceName, rootNode) ->
      console.log("(RailsApiResource) resourceName:" + resourceName)

      collectionUrl = KOPOOL_CONFIG.PROTOCOL + '://' + KOPOOL_CONFIG.HOSTNAME + '/' + resourceName + '.json'

      defaultParams = { }
      headers = { }

      # Utility methods
      getId = (data) ->
        data._id.$oid

      # A constructor for new resources
      Resource = (data) ->
        angular.extend(this, data)

      # TODO: This could be DRYed up a _LOT_!! Notice that each .then is identical..  Use a response factory?
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

      Resource.nested_query = (parent_id, queryJson) ->
        console.log("(RailsApiResource.Resource.nested_query) queryJson="+queryJson)
        collectionUrl = KOPOOL_CONFIG.PROTOCOL + '://' + KOPOOL_CONFIG.HOSTNAME + '/' + resourceName + '.json'
        if collectionUrl.indexOf(":parent_id") > -1
          collectionUrl = collectionUrl.replace(/:parent_id/, parent_id)
          console.log("Resource will be: " + collectionUrl)

        params = if angular.isObject(queryJson) then queryJson else {}
        console.log("(RailsApiResource.Resource.nested_query) params="+params)

        #, headers: headers
        $http.get(collectionUrl, {params:angular.extend({}, defaultParams, params)} ).then( (response) ->
          result = []
          console.log("(RailsApiResource.nested_query) response="+response.data)

          if response.data instanceof Array
            console.log("is an Array")
            angular.forEach(response.data, (value, key) ->
              result[key] = new Resource(value)
            )
          else
            console.log("is an Object")
            data_of_interest = eval("response.data."+rootNode)
            angular.forEach(data_of_interest, (value, key) ->
              result[key] = new Resource(value)
            )
          )

      Resource.get = (id, parent_id) ->
        console.log("Resource.get id="+id)
        singleItemUrl = KOPOOL_CONFIG.PROTOCOL + '://' + KOPOOL_CONFIG.HOSTNAME + '/' + resourceName + '/' + id + '.json'
        if singleItemUrl.indexOf(":parent_id") > -1?
          singleItemUrl = singleItemUrl.replace(/:parent_id/, parent_id)

        console.log("url will be "+singleItemUrl)
        $http.get(singleItemUrl, {params:defaultParams}).then( (response) ->
          result = []
          console.log("(RailsApiResource.get) response="+response.data)

          if response.data instanceof Array
            console.log("(get) is an Array")
            angular.forEach(response.data, (value, key) ->
              console.log("key:" + key + " value:" + value)
              result[key] = new Resource(value)
            )
          else
            console.log("(get) is an Object")
            angular.forEach(response.data, (value, key) ->
              result[key] = new Resource(value)
            )
          )

      Resource.save = (data, parent_id) ->
        console.log("Resource.save")
        singleItemUrl = KOPOOL_CONFIG.PROTOCOL + '://' + KOPOOL_CONFIG.HOSTNAME + '/' + resourceName + '/' + data.id + '.json'
        if singleItemUrl.indexOf(":parent_id") > -1?
          singleItemUrl = singleItemUrl.replace(/:parent_id/, parent_id)

        console.log("url will be "+singleItemUrl)
        $http.put(singleItemUrl, data, { params:defaultParams }).then( (response) ->
          new Resource(data)
        )

      Resource.post = (action, data, parent_id) ->
        console.log("Resource.post action="+action)
        console.log("data: "+data)
        actionUrl = KOPOOL_CONFIG.PROTOCOL + '://' + KOPOOL_CONFIG.HOSTNAME + '/' + resourceName + '/' + action + '.json'
        if actionUrl.indexOf(":parent_id") > -1?
          actionUrl = actionUrl.replace(/:parent_id/, parent_id)

        console.log("actionUrl will be: "+actionUrl)
        $http.post(actionUrl, data, {params:defaultParams}).then( (response) ->
          result = []
          console.log("(RailsApiResource.post) response="+response.data)
        )

      Resource.put = (action, data, parent_id) ->
        console.log("Resource.put action="+action)
        console.log("data: "+data)
        actionUrl = KOPOOL_CONFIG.PROTOCOL + '://' + KOPOOL_CONFIG.HOSTNAME + '/' + resourceName + '/' + action + '.json'
        if actionUrl.indexOf(":parent_id") > -1?
          actionUrl = actionUrl.replace(/:parent_id/, parent_id)

        console.log("actionUrl will be: "+actionUrl)
        $http.put(actionUrl, data, {params:defaultParams}).then( (response) ->
          result = []
          console.log("(RailsApiResource.put) response="+response.data)
        )

      Resource.remove = (data, parent_id) ->
        console.log("Resource.remove")
        nested_url = KOPOOL_CONFIG.PROTOCOL + '://' + KOPOOL_CONFIG.HOSTNAME + '/' + resourceName + '/' + data.id + '.json'
        if nested_url.indexOf(":parent_id") > -1?
          nested_url = nested_url.replace(/:parent_id/, parent_id)

        console.log("url will be "+nested_url)
        $http.delete(nested_url, data, { params:defaultParams }).then( (response) ->
          new Resource(data)
        )

      Resource.create = (data, parent_id) ->
        console.log("Resource.create")
        nested_url = KOPOOL_CONFIG.PROTOCOL + '://' + KOPOOL_CONFIG.HOSTNAME + '/' + resourceName + '.json'
        if nested_url.indexOf(":parent_id") > -1?
          nested_url = nested_url.replace(/:parent_id/, parent_id)

        console.log("url will be "+nested_url)
        $http.post(nested_url, data, { params:defaultParams }).then( (response) ->
          result = []
          console.log("(RailsApiResource.create) response="+response.data)

          if response.data instanceof Array
            console.log("(get) is an Array")
            angular.forEach(response.data, (value, key) ->
              console.log("key:" + key + " value:" + value)
              result[key] = new Resource(value)
            )
          else
            console.log("(get) is an Object")
            angular.forEach(response.data, (value, key) ->
              result[key] = new Resource(value)
            )
          )

      # Instance Methods (not yet tested!)

      Resource.prototype.$save = (data) ->
        Resource.save(this)

      Resource

