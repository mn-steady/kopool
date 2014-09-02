angular.module('ForgotPasswords', ['ngResource', 'RailsApiResource', 'ui.bootstrap'])

	.factory 'ForgotPassword', (RailsApiResource) ->
		RailsApiResource('users', 'forgot_password')

	.controller 'ForgotPasswordsCtrl', ['$scope', '$location', '$http', '$routeParams', 'WebState', 'PoolEntry', 'ForgotPassword', ($scope, $location, $http, $routeParams, WebState, PoolEntry, ForgotPassword) ->
		$scope.user_email = ""
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
	]