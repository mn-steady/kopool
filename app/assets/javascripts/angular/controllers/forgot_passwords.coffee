angular.module('ForgotPasswords', ['ngResource', 'RailsApiResource', 'ui.bootstrap'])

	.factory 'ForgotPassword', (RailsApiResource) ->
		RailsApiResource('users/forgot_password', 'forgot_password')

	.controller 'ForgotPasswordsCtrl', ['$scope', '$location', '$http', '$routeParams', 'WebState', 'PoolEntry', 'ForgotPassword', ($scope, $location, $http, $routeParams, WebState, PoolEntry, ForgotPassword) ->
		$scope.user_email = ""

		$scope.sendResetPasswordEmail = () ->
			ForgotPassword.post(send, user_email).then(() ->
				
			)
	]