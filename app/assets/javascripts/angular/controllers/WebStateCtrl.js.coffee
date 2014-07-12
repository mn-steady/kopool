angular.module('WebStates', ['ngResource', 'RailsApiResource'])

  .factory 'WebState', (RailsApiResource) ->
      RailsApiResource('admin/web_states', 'webstate')

  .controller 'WebStatesCtrl', ['$scope', '$location', '$http', '$routeParams', 'WebState', ($scope, $location, $http, $routeParams, WebState) ->
    $scope.controller = 'WebStatesCtrl'

    console.log("WebStatesCtrl")
    console.log($routeParams)

    console.log("$location:" + $location)

    action = $routeParams.action

    # There is always only 1 webstate record
    console.log("Passed action:" + action)

    console.log("...Looking up the WebState")
    $scope.web_state = WebState.get(1).then((web_state) ->
      $scope.web_state = web_state
      $scope.season = "TBD"
    )

    $scope.save = (web_state) ->
      console.log("WebStatesCtrl.save...")
      if web_state.id?
        console.log("Saving web_state id " + web_state.id)
        web_state.save(web_state, $scope.season_id).then((web_state) ->
          $scope.web_state = web_state
        )
      else
        console.log("First-time save need POST new id")
        web_state.create(web_state, $scope.season_id).then((web_state) ->
          $scope.web_state = web_state
        )
      $location.path ('/seasons/' + $scope.season_id + '/web_states')

  ]