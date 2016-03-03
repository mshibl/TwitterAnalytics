shiftSampleApp
	.factory('UserService', function($http,$sessionStorage,$localStorage,$q,$location){
		var userService = {};

		userService.getUserData = function(id){
			var deferred = $q.defer();
			$http.get('/users/'+id)
				.then(
					function(response){
						deferred.resolve(response.data)
					}, function(response){
						console.log('failed while getting user data')
					})
			return deferred.promise
		};

		userService.getUserTweets = function(id){
			var deferred = $q.defer();
		    $http.get('/users/'+id+'/tweets')
		    	.then(
					function(response){
						deferred.resolve(response.data)
					}, function(response){
						console.log('failed while getting tweets')
					})
			return deferred.promise
		};

		userService.postTweet = function(tweet){
			var params = {text: tweet}
			var deferred = $q.defer();
			$http.post('/users/'+$localStorage.currentUser.id+'/tweets',params)
				.then(
					function(response){
						deferred.resolve(response.data)
					})
			return deferred.promise
		};

		userService.getSuggestions = function(){
			var deferred = $q.defer();
			$http.get('/users/'+$localStorage.currentUser.id+'/search')
				.success(function(res){
					deferred.resolve(res)
				})
			return deferred.promise;
		};

		userService.followFriend = function(friendId){
			var deferred = $q.defer();
			var params = {id: friendId}
			$http.post('/users/'+$localStorage.currentUser.id+'/follow',params)
				.then(function(){
					deferred.resolve()
				}, function(){
					deferred.reject()
				})
			return deferred.promise;
		};

		userService.getRelationshipsList = function(id){
			var deferred = $q.defer();
			$http.get('/users/'+id+'/list')
				.then(function(response){
					deferred.resolve(response.data)
				})
			return deferred.promise;
		}

		return userService;
	})