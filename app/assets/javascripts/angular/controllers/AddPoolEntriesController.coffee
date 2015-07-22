angular.module('AddPoolEntries', ['ngResource', 'RailsApiResource', 'user'])

  .controller 'AddPoolEntriesCtrl', ['$scope', '$location', 'currentUser', 'AuthService', 'PoolEntry', 'PoolEntries', 'WebState', 'KOPOOL_CONFIG', ($scope, $location, currentUser, AuthService, PoolEntry, PoolEntries, WebState, KOPOOL_CONFIG) ->
    $scope.pool_entries = []
    $scope.pool_entries_persisted = 0

    $scope.register_error = {message: null, errors: {}}
    $scope.editing_team = 1
    $scope.persisting_pool_entries_failed = false

    $scope.template_pool_entry =
      id: -1
      team_name: ""
      paid: false
      persisted: false
      season: -1

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

    $scope.create_local_pool_entries = () ->
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

    $scope.$watch 'registering_user.num_pool_entries', (newVal, oldVal) ->
      console.log("(num_pool_entries.watch) old="+oldVal + " new=" + newVal)
      if !$scope.user_needs_registration()
        console.log("(num_pool_entries.watch) Changing pool entries AFTER registration")
        num_existing_teams = $scope.pool_entries.length
        console.log("(num_pool_entries.watch) existing team count="+ num_existing_teams)

        if newVal > num_existing_teams
          if num_existing_teams == 10
            console.log("CANNOT ADD ANY MORE TEAMS")
            newVal = oldVal
            $scope.editing_team = oldVal
          else
            console.log("Pushing a new team")
            $scope.pool_entries.push(id: newVal, team_name: "", paid: false, persisted: false)
        if newVal < num_existing_teams and num_existing_teams > 0
          console.log("(num_pool_entries.watch) Wants to remove a team")
          team_to_axe = $scope.pool_entries[num_existing_teams-1]
          if team_to_axe.persisted
            console.log("(num_pool_entries.watch) This team was persisted!")
            $scope.registering_user.num_pool_entries = oldVal
            newVal = oldVal
          else
            console.log("(num_pool_entries.watch) Can remove non-persisted team")
            team_to_axe = $scope.pool_entries.pop()
        if newVal == num_existing_teams
          console.log("(num_pool_entries.watch) Already have this many teams")
      else
        console.log("(num_pool_entries.watch) Changing pool entries BEFORE registration")


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
      $scope.user_needs_registration() and $scope.password_is_valid($scope.registering_user.password) and $scope.password_is_valid($scope.registering_user.password_confirmation) and $scope.passwords_long_enough($scope.registering_user.password, $scope.registering_user.password_confirmation) and $scope.email_valid($scope.registering_user.email) and $scope.passwords_match($scope.registering_user.password, $scope.registering_user.password_confirmation)

    $scope.persist_button_class = (index) ->
      if $scope.user_needs_registration() == false
        "btn-success"
      else
        "btn-warning"

    $scope.disable_pool_entry_change = () ->
      !$scope.open_for_registration() or $scope.web_state.current_week.week_number != 1

    $scope.persist_button_disabled = () ->
      $scope.pool_entries_persisted == $scope.pool_entries.length

    $scope.persist_button_show = () ->
      if $scope.user_needs_registration() == false
        all_named = true
        for pool_entry in $scope.pool_entries
          if pool_entry.team_name == "" then all_named = false
        return all_named
      else
        return false

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

    $scope.passwords_match = (p1, p2) ->
      if $scope.user_needs_registration() == true
        if p1 == p2
          true
        else
          false
      else
        true

    $scope.passwords_long_enough = (p1, p2) ->
      if $scope.user_needs_registration() == true
        if p1.length >= 8 and p2.length >= 8
          true
        else
          false
      else
        true

    $scope.email_valid = (email) ->
      if $scope.user_needs_registration() == true
        # TODO: Use a regexp
        if email.length >= 6
          true
        else
          false
      else
        true

  ]