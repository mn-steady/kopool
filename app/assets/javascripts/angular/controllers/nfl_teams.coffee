angular.module('NflTeams', ['ngResource', 'RailsApiResource', 'angularFileUpload'])

    .factory 'NflTeam', (RailsApiResource) ->
        RailsApiResource('nfl_teams', 'nfl_teams')

    .controller 'NflTeamsCtrl', ['$scope', '$location', '$http', '$routeParams', 'NflTeam', '$upload', ($scope, $location, $http, $routeParams, NflTeam, $upload) ->


      # create a uploader with options
      $scope.onFileSelect = (team, $files) ->
        #$files: an array of files selected, each file has name, size, and type.
        i = 0
        while i < $files.length
          file = $files[i]
          #upload.php script, node.js route, or servlet url
          # method: 'POST' or 'PUT',
          # headers: {'header-key': 'header-value'},
          # withCredentials: true,
          # or list of files: $files for html5 only
          # set the file formData name ('Content-Desposition'). Default is 'file'

          #fileFormDataName: myFile, //or a list of names for multiple files (html5).
          # customize how data is added to formData. See #40#issuecomment-28612000 for sample code

          #formDataAppender: function(formData, key, val){}
          $scope.upload = $upload.upload(
            url: "nfl_teams/" + team.id + ".json"
            method: "PUT"
            file: file
            fileFormDataName: 'nfl_team[logo]'
          ).progress((evt) ->
            console.log "percent: " + parseInt(100.0 * evt.loaded / evt.total)
            return
          ).success((data, status, headers, config) ->

            # file is uploaded successfully
            console.log data
            return
          )
          i++
        return


      $scope.controller = 'NflTeamsCtrl'
      console.log("NflTeamsCtrl")
      console.log("$location:" + $location)

      action = $routeParams.action
      team_id = $routeParams.id

      console.log("Passed id:" + team_id)
      console.log("Passed action:" + action)


      if team_id? and team_id == "new"
        console.log("...Creating a new team")
        $scope.nfl_team = new NflTeam({})
      else if team_id?
        console.log("...Looking up a single team")
        $scope.nfl_team = NflTeam.get(team_id).then((nfl_team) ->
            $scope.nfl_team = nfl_team
        )
      else
        console.log("...All Teams")
        NflTeam.query().then((nfl_teams) ->
            $scope.nfl_teams = nfl_teams
            console.log("*** Have nfl_teams***")
        )


      $scope.selectTeam = (team) ->
        console.log("---> Selecting " + team.name)
        $scope.selectedTeam = team

      $scope.isSelected = (team) ->
        $scope.selectedTeam == team

      $scope.save = (team) ->
        console.log("NflTeamsCtrl.save...")
        if team.id?
          console.log("Saving Team id " + team.id)
          NflTeam.save(team).then((nfl_team) ->
            $scope.nfl_team = nfl_team
          )
        else
          console.log("First-time save need POST new id")
          NflTeam.create(team).then((nfl_team) ->
            $scope.nfl_team = nfl_team
          )
        $location.path ('/nfl_teams')

      $scope.deleteTeam = (team) ->
        console.log("NflTeamsCtrl.delete...")
        if team.id?
          console.log("Deleting Team id " + team.id)
          NflTeam.remove(team).then((nfl_team) ->
            # Forcibly reloading the collection refreshes the screen nicely!
            NflTeam.query().then((nfl_teams) ->
              $scope.nfl_teams = nfl_teams
              $location.path ('/nfl_teams')
            )
          )
        else
          console.log("Cannot Delete)")

    ]