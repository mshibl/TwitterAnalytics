shiftSampleApp
	.factory('AuthService', function(UserService,$http,$sessionStorage,$localStorage,$q){
		var authService = {};

		authService.login = function(credentials){
			var deferred = $q.defer();
			$http.post('/login', credentials)
		      .then(
		      	function (response) {
		      		$localStorage.currentUser = response.data;
		      		deferred.resolve(response.data.id)
		   		},function (response){
		   			console.log('login failed in auth factory')
		    		deferred.reject(response.data)
		    	})
		      return deferred.promise
		}

		authService.createAccount = function(credentials){
			var deferred = $q.defer();
			$http.post('/users',credentials)
				.then(
			      function (response) {
			      		$localStorage.currentUser = response.data;
			      		deferred.resolve(response.data.id)
			   		},function (response){
			   			console.log('create account failed in auth factory')
			    		deferred.reject(response.data)
			    	})
			      return deferred.promise
		}

		authService.logout = function(){
			var deferred = $q.defer()
			$http.delete('/users/'+$localStorage.currentUser.id+'/logout')
				.then(function(res){
					$localStorage.$reset()
					$sessionStorage.$reset()
					deferred.resolve(res)
				})
			return deferred.promise;
		};

		return authService;
	})