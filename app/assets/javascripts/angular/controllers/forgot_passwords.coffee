angular.module('ForgotPasswords', ['ngResource', 'RailsApiResource', 'ui.bootstrap'])

	.factory 'ForgotPassword', (RailsApiResource) ->
		RailsApiResource('users', 'forgot_password')

	.factory 'UpdatePassword', (RailsApiResource) ->
		RailsApiResource('users', 'forgot_password')

	.controller 'ForgotPasswordsCtrl', ['$scope', '$location', '$http', '$routeParams', 'WebState', 'PoolEntry', 'ForgotPassword', 'UpdatePassword', ($scope, $location, $http, $routeParams, WebState, PoolEntry, ForgotPassword, UpdatePassword) ->
		$scope.user_email = ""
		$scope.updating_user = 
			password: ""
			password_confirmation: ""
			reset_password_token: $routeParams.reset_password_token
		
		$scope.alert = {
			type: null
			message: null
		}

		$scope.sendResetPasswordEmail = () ->
			$scope.user_params = {user_email: $scope.user_email}

			ForgotPassword.post("password", $scope.user_params).then(
				(success_response) ->
					$scope.alert.message = "An email has been sent. Please follow the instructions in the email to reset your password."
					$scope.alert.type = "success"
				(json_error_data) ->
					console.log("No user found for the given email")
					$scope.alert.message = json_error_data.data[0].error
					$scope.alert.type = "danger"
			)

		$scope.updatePassword = () ->

			UpdatePassword.put("password", $scope.updating_user).then(
				(success_response) ->
					$scope.alert.message = "Your password has been reset. Please sign in."
					$scope.alert.type = "success"
					$location.path ('/')
				(json_error_data) ->
					console.log("Password update failed. Please try again or contact the commish.")
					$scope.alert.message = json_error_data.data[0].error
					$scope.alert.type = "danger"
			)

	]