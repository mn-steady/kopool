angular.module('AddPoolEntries', ['ngResource', 'RailsApiResource', 'user'])

  .controller 'AddPoolEntriesCtrl', ['$scope', '$location', 'currentUser', 'AuthService', 'PoolEntry', 'PoolEntries', 'WebState', 'KOPOOL_CONFIG', ($scope, $location, currentUser, AuthService, PoolEntry, PoolEntries, WebState, KOPOOL_CONFIG) ->
    $scope.pool_entries = []

    WebState.get(1).then((web_state) ->
      $scope.web_state = web_state
    )

    $scope.load_persisted_pool_entries = () ->
      console.log("(registerCtrl.load_persisted_pool_entries)")
      PoolEntries.query().then((persisted_pool_entries) ->
        console.log "GOT ENTRIES: ", persisted_pool_entries
        for entry in persisted_pool_entries
          entry.saved = true
          $scope.pool_entries.push entry
      )

    $scope.load_persisted_pool_entries()

    $scope.add_pool_entry = () ->
      pool_entry = {}
      pool_entry.team_name = ""
      pool_entry.editing = true
      pool_entry.saved = false
      $scope.pool_entries.push(pool_entry)

    $scope.persist_pool_entries = (user_data) ->
      console.log("(registerCtrl.create_pool_entries)")
      for pool_entry in $scope.new_pool_entries
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
      "$" + $scope.pool_entries.length * 50.00 + ".00"

    $scope.pool_entry_text = () ->
      if $scope.registering_user.num_pool_entries > 1
        "your " + $scope.registering_user.num_pool_entries + " pool entries"
      else
        "your pool entry"

    $scope.team_badge_text = (team_index) ->
      "Team " + (team_index+1) + " of " + $scope.pool_entries.length

    $scope.team_button_class = (index) ->
      if index + 1 == $scope.editing_team
        "btn-primary"
      else
        "btn-default"

    $scope.disable_save = () ->
      disable = false
      for entry in $scope.pool_entries
        if entry.saved == false
          disable = true
      return disable

    $scope.set_editing_entry = (pool_entry) ->
      pool_entry.editing = true

    $scope.done_editing_entry = (pool_entry) ->
      pool_entry.editing = false
      if pool_entry.id
        PoolEntry.update(pool_entry).then((saved_entry) ->
          console.log("EXISTING entry saved")
          pool_entry.error = null
          pool_entry.saved = true
        ,(failed_response) ->
          console.log("EXISTING entry failed", failed_response)
          pool_entry.error = failed_response.data[0].error
          pool_entry.saved = false
        )
      else
        PoolEntry.create(pool_entry).then((saved_entry) ->
          console.log "NEW entry saved"
          pool_entry.error = null
          pool_entry.saved = true
        ,(failed_response) ->
          console.log "NEW entry failed", failed_response
          pool_entry.error = failed_response.data[0].error
          pool_entry.saved = false
        )

    $scope.remove_pool_entry = (pool_entry) ->
      index = $scope.pool_entries.indexOf(pool_entry)
      if index > -1
        $scope.pool_entries.splice(index, 1)
      if pool_entry.id
        PoolEntry.remove(pool_entry).then((deleted_entry) ->
          console.log "Deleted pool entry: ", deleted_entry
        )

    $scope.save_and_return = () ->
      $location.path('/')

    $scope.team_button_text = (team_index) ->
      team_number = team_index + 1
      if $scope.registering_user.teams[team_index].persisted
        "Team # " + team_number + " SAVED"
      else
        "Edit Team # " + team_number

    # $scope.team_button_disabled = (team_index) ->
    #   team_number = team_index + 1
    #   if $scope.registering_user.teams[team_index]? && $scope.registering_user.teams[team_index].persisted
    #     true
    #   else
    #     false

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

    $scope.persist_button_text = () ->
      if $scope.pool_entries_persisted == $scope.pool_entries.length
        "Teams have been Setup"
      else
        "PERMANENTLY SAVE the Teams Below"

    $scope.$watch 'new_entry_count', (newVal, oldVal) ->
      console.log("(num_pool_entries.watch) old="+oldVal + " new=" + newVal)
      if newVal
        console.log "newVal + existing: ", (newVal + $scope.pool_entries.length)
        console.log "pool_entries: ", $scope.pool_entries.length
        if (newVal + $scope.pool_entries.length) < 10
          console.log("Pushing a new team")
          $scope.count_message = null
          
        else
          console.log("CANNOT ADD ANY MORE TEAMS")
          newVal = oldVal
          $scope.count_message = "Maximum of 10 Pool Entries per user."
          $scope.editing_team = oldVal
      # if newVal < num_existing_teams and num_existing_teams > 0
      #   console.log("(num_pool_entries.watch) Wants to remove a team")
      #   team_to_axe = $scope.pool_entries[num_existing_teams-1]
      #   if team_to_axe.persisted
      #     console.log("(num_pool_entries.watch) This team was persisted!")
      #     $scope.registering_user.num_pool_entries = oldVal
      #     newVal = oldVal
      #   else
      #     console.log("(num_pool_entries.watch) Can remove non-persisted team")
      #     team_to_axe = $scope.pool_entries.pop()
      # if newVal == num_existing_teams
      #   console.log("(num_pool_entries.watch) Already have this many teams")

  ]