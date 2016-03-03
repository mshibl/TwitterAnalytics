shiftSampleApp
	.factory('HttpInterceptor', function($q,$localStorage,$injector,$location){
		return {
			request: function(config){
				// console.log('http request intercepted')
				// console.log(config)
				config.params =  $localStorage.currentUser ? {id: $localStorage.currentUser.id, token: $localStorage.currentUser.token} : {id: "", token: ""}
				return config
			},

			response: function(result){
				// console.log('http response intercepted')
				// console.log(result.status)
				return result
			},

			responseError: function(rejection){
				// console.log('http response error intercepted')
				// console.log(rejection)
				return $q.reject(rejection);
			}
		}
	})