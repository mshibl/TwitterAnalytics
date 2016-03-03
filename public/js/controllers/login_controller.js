shiftSampleApp
	.controller('LoginCtrl', function(AuthService, $rootScope, $scope, $localStorage, $location, $http,$timeout){
		$scope.login = function(formValid,credentials){
			if(formValid){
				AuthService.login(credentials)
				 	.then(
				 		function(userId){
							$location.path('/users/'+userId);
				 		}, function(response){
				 			$scope.errorMessage = response
				 		})
			} else {
				console.log('form invalid')
			}
		}

		$scope.createAccount = function(formValid,credentials){
			if(formValid){
				AuthService.createAccount(credentials)
				 	.then(
				 		function(userId){
							$location.path('/users/'+userId);
				 		}, function(response){
				 			$scope.errorMessage = response
				 		})
			} else {
				console.log('form invalid')
			}
		}

		$scope.loginView = true;
	})