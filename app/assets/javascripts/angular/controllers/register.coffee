angular.module('Register', ['ngResource', 'RailsApiResource', 'user'])

  .factory 'PoolEntry', (RailsApiResource) ->
      RailsApiResource('pool_entries', 'pool_entries')

  .factory 'WebState', (RailsApiResource) ->
      RailsApiResource('admin/web_states', 'webstate')

  .factory 'PoolEntries', (RailsApiResource) ->
      RailsApiResource('pool_entries_index_all', 'pool_entries')

    .controller 'RegisterCtrl', ['$scope', '$location', '$http', '$routeParams', 'currentUser', 'AuthService', 'PoolEntry', 'PoolEntries', 'WebState', 'KOPOOL_CONFIG', '$rootScope', ($scope, $location, $http, $routeParams, currentUser, AuthService, PoolEntry, PoolEntries, WebState, KOPOOL_CONFIG, $rootScope) ->
      console.log("(RegisterCtrl)")
      $scope.controller = 'RegisterCtrl'

      console.log("$location:" + $location)
      action = $routeParams.action
      team_id = $routeParams.id

      $scope.pool_entries = []
      $scope.pool_entries_persisted = 0

      $scope.registering_user =
        name: ""
        phone: ""
        email: ""
        password: ""
        password_confirmation: ""
        num_pool_entries: 1
        teams: $scope.pool_entries
        is_registered: false

      $scope.register_error = {message: null, errors: {}}
      $scope.editing_team = 1
      $scope.persisting_pool_entries_failed = false

      $scope.template_pool_entry =
        id: -1
        team_name: ""
        paid: false
        persisted: false
        season: -1

      $scope.web_state =
        id: 0
        week_id: 0
        broadcast_message: "...Refreshing..."
        current_week:
          week_number: 0
          open_for_picks: false
          season:
            id: 0
            year: 0
            name: "...Refreshing..."
            open_for_registration: false

      console.log("...Looking up the WebState")
      WebState.get(1).then((web_state) ->
        $scope.web_state = web_state
      )

      $scope.load_persisted_pool_entries = () ->
        console.log("(registerCtrl.load_persisted_pool_entries)")
        $scope.pool_entries_persisted = 0
        PoolEntries.query().then((persisted_pool_entries) ->
          for pool_entry in persisted_pool_entries
            local_pool_entry = {id: pool_entry.id, team_name: pool_entry.team_name, paid: pool_entry.paid, persisted: true, season_id: pool_entry.season_id}
            $scope.pool_entries.push(local_pool_entry)
            $scope.pool_entries_persisted++
          $scope.registering_user.num_pool_entries = $scope.pool_entries_persisted
        )


      $scope.register = ->
        console.log("(registerCtrl.register)")
        $scope.submit
          method: "POST"
          url: KOPOOL_CONFIG.PROTOCOL + '://' + KOPOOL_CONFIG.HOSTNAME + "/users.json"
          data:
            user:
              name: $scope.registering_user.name
              phone: $scope.registering_user.phone
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
            $rootScope.flash_message = "Thanks for registering! Please sign in."
            $location.path('/')
          else
            if data.error
              parameters.error_entity.message = data.error
            else
              parameters.error_entity.message = "Success, but with an unexpected success code, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data)
          return
        ).error (data, status) ->
          if status is 422
            parameters.error_entity.message = "Unable to Register. If you've already registered, please sign-in above."
            parameters.error_entity.errors = data.errors
          else
            if data.error
              parameters.error_entity.message = "Unable to Register. Check username, password, and confirmation."
              parameters.error_entity.message = data.error
            else
              parameters.error_entity.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data)
          return
        return

      $scope.save_user_data = (data) ->
        currentUser.authorized = true
        currentUser.admin = false
        currentUser.username = data.email
        # AuthService.login(currentUser)
        # AuthService.updateCookies()
        # $rootScope.$broadcast('auth-login-success')

      $scope.create_local_pool_entries = () ->
        console.log("(registerCtrl.create_local_pool_entries)")
        for x in [1..$scope.registering_user.num_pool_entries] by 1
          if $scope.pool_entries.length < $scope.registering_user.num_pool_entries
            $scope.pool_entries.push(id: x, team_name: "", paid: false, persisted: false, season_id: $scope.season_id())
        return

      $scope.persist_pool_entries = (user_data) ->
        console.log("(registerCtrl.create_pool_entries)")
        for pool_entry in $scope.pool_entries
          if !pool_entry.persisted
            console.log("Persisting Pool Entry: " + pool_entry.team_name)
            PoolEntry.create(pool_entry).then((persisted_pool_entry) ->
                console.log("..Back from creating Pool Entry")
                $scope.persisting_pool_entries_failed = false
                $scope.pool_entries_persisted++
                for local_pool_entry in $scope.pool_entries
                  if local_pool_entry.team_name == persisted_pool_entry.team_name
                    local_pool_entry.persisted = true

              (failure) ->
                $scope.persisting_pool_entries_failed = true
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

      $scope.team_button_text = (team_index) ->
        team_number = team_index + 1
        if $scope.registering_user.teams[team_index].persisted
          "Team # " + team_number + " SAVED"
        else
          "Edit Team # " + team_number

      $scope.team_button_disabled = (team_index) ->
        team_number = team_index + 1
        if $scope.registering_user.teams[team_index]? && $scope.registering_user.teams[team_index].persisted
          true
        else
          false

      $scope.open_for_registration = () ->
        $scope.web_state.current_week.open_for_picks

      $scope.season_id = () ->
        $scope.web_state.current_week.season.id

      $scope.register_button_class = (index) ->
        "btn-primary"

      $scope.user_can_register = () ->
        $scope.password_is_valid($scope.registering_user.password) and $scope.password_is_valid($scope.registering_user.password_confirmation) and $scope.passwords_long_enough($scope.registering_user.password, $scope.registering_user.password_confirmation) and $scope.email_valid($scope.registering_user.email) and ($scope.registering_user.password == $scope.registering_user.password_confirmation)

      $scope.disable_pool_entry_change = () ->
        !$scope.open_for_registration() or $scope.web_state.current_week.week_number != 1

      $scope.persist_button_disabled = () ->
        $scope.pool_entries_persisted == $scope.pool_entries.length

      $scope.show_week_1_picks_button = () ->
        $scope.persist_button_show() and $scope.persist_button_disabled()

      $scope.persist_button_text = () ->
        if $scope.pool_entries_persisted == $scope.pool_entries.length
          "Teams have been Setup"
        else
          "PERMANENTLY SAVE the Teams Below"

      $scope.password_is_valid = (entry) ->
        if entry.length >= 8
          "has-success"
        else
          "has-error"

      $scope.passwords_long_enough = (p1, p2) ->
        if p1.length >= 8 and p2.length >= 8
          true
        else
          false

      $scope.email_valid = (email) ->
        # TODO: Use a regexp
        if email.length >= 6
          true
        else
          false

    ]