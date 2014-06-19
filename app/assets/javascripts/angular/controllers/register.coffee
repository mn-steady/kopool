angular.module('Register', ['ngResource', 'RailsApiResource', 'user'])

  .factory 'PoolEntry', (RailsApiResource) ->
      RailsApiResource('pool_entries', 'pool_entries')

    .controller 'RegisterCtrl', ['$scope', '$location', '$http', '$routeParams', 'currentUser', 'AuthService', 'PoolEntry', 'KOPOOL_CONFIG', ($scope, $location, $http, $routeParams, currentUser, AuthService, PoolEntry, KOPOOL_CONFIG) ->
      console.log("(RegisterCtrl)")
      $scope.controller = 'RegisterCtrl'

      # user_registration POST   /users(.:format)                             devise/registrations#create
      # new_user_registration GET    /users/sign_up(.:format)                     devise/registrations#new

      console.log("$location:" + $location)
      action = $routeParams.action
      team_id = $routeParams.id

      console.log("Passed id:" + team_id)
      console.log("Passed action:" + action)

      # $scope.pool_entries = [{team_temp_id: 0, team_name: "???", paid: false}]
      $scope.pool_entries = []
      $scope.pool_entries_persisted = 0
      $scope.registering_user = {email: "", password: "", password_confirmation: "", num_pool_entries: 1, teams: $scope.pool_entries, is_registered: false}
      $scope.register_error = {message: null, errors: {}}
      $scope.editing_team = 1

      $scope.register = ->
        console.log("(registerCtrl.register)")
        $scope.submit
          method: "POST"
          url: KOPOOL_CONFIG.PROTOCOL + '://' + KOPOOL_CONFIG.HOSTNAME + "/users.json"
          data:
            user:
              email: $scope.registering_user.email
              password: $scope.registering_user.password
              password_confirmation: $scope.registering_user.password_confirmation
          success_message: "You have been registered! Good luck!"
          error_entity: $scope.register_error

      $scope.submit = (parameters) ->
        $http(
          method: parameters.method
          url: parameters.url
          data: parameters.data
        ).success((data, status) ->
          if status is 201 or status is 204 or status is 200
            parameters.error_entity.message = null
            console.log("(registerCtrl.submit.success)")
            $scope.save_user_data(data)
          else
            if data.error
              parameters.error_entity.message = data.error
            else
              parameters.error_entity.message = "Success, but with an unexpected success code, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data)
          return
        ).error (data, status) ->
          if status is 422
            parameters.error_entity.message = "Unable to Register.  Check username, password, and confirmation"
            parameters.error_entity.errors = data.errors
          else
            if data.error
              parameters.error_entity.message = "Unable to Register.  Check username, password, and confirmation"
              parameters.error_entity.message = data.error
            else
              parameters.error_entity.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data)
          return
        return

      $scope.save_user_data = (user_data) ->
        console.log("(registerCtrl.save_user_data)")
        currentUser.authorized = true
        currentUser.username = user_data.email
        AuthService.updateCookies()
        console.log("(registerCtrl.save_user_data) saved username:" + currentUser.username)
        $scope.registering_user.is_registered = true
        for x in [1..$scope.registering_user.num_pool_entries] by 1
          if $scope.pool_entries.length < $scope.registering_user.num_pool_entries
            $scope.pool_entries.push({team_temp_id: x, team_name: "", paid: false})
        return

      $scope.persist_pool_entries = (user_data) ->
        console.log("(registerCtrl.create_pool_entries)")
        for pool_entry in $scope.pool_entries
          console.log("Persisting Pool Entry: " + pool_entry.team_name)
          PoolEntry.create(pool_entry).then((persisted_pool_entry) ->
              $scope.pool_entries_persisted++
            )

      $scope.set_editing_team = (index) ->
        $scope.editing_team = index + 1

      $scope.total_charges = () ->
        "$" + $scope.registering_user.num_pool_entries * 50.00 + ".00"

      $scope.pool_entry_text = () ->
        if $scope.registering_user.num_pool_entries > 1
          "your " + $scope.registering_user.num_pool_entries + " pool entries"
        else
          "your pool entry"

      $scope.team_badge_text = (team_index) ->
        "Team " + (team_index+1) + " of " + $scope.registering_user.num_pool_entries

      $scope.team_button_class = (index) ->
        if index + 1 == $scope.editing_team
          "btn-primary"
        else
          "btn-default"

      $scope.register_button_class = (index) ->
        "btn-primary"

      $scope.persist_button_class = (index) ->
        if $scope.registering_user.is_registered == true
          "btn-success"
        else
          "btn-warning"

      $scope.persist_button_disabled = () ->
        $scope.pool_entries_persisted == $scope.pool_entries.length

      $scope.persist_button_show = () ->
        if $scope.registering_user.is_registered == true
          all_named = true
          for pool_entry in $scope.pool_entries
            if pool_entry.team_name == "" then all_named = false
          return all_named
        else
          return false

      $scope.persist_button_text = () ->
        if $scope.pool_entries_persisted == $scope.pool_entries.length
          "Teams have been Setup"
        else
          "Setup the Teams Below"

    ]