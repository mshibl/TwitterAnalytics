shiftSampleApp
  .controller('UsersCtrl', function (UserService, AuthService, $routeParams, $scope, $http,$localStorage,$sessionStorage,$q,$location) {

    if(!$scope.currentUser){$scope.currentUser = $localStorage.currentUser;}

    $scope.getUserData = function(id){
      UserService.getUserData(id)
        .then(function(userData){
                $scope.targetUser = userData
            })  
        } 

    $scope.getUserTweets = function(id){
      UserService.getUserTweets(id)
        .then(function(response){
                $scope.tweets = response
            })  
        } 

    $scope.showTweetsTimeline = function(){
        $scope.tweetsView = true
        $scope.tweetPermission = true
        UserService.getRelationshipsList($scope.currentUser.id)
            .then(function(list){
                $scope.tweets = []
                friends = list['friends_list']
                friends.push($scope.currentUser)
                angular.forEach(friends, function(friend){
                    UserService.getUserTweets(friend.id)
                        .then(function(response){
                            $scope.tweets = $.map( [$scope.tweets,response], function(n){
                               return n;
                            });
                        })
                    })
                })
            }

    $scope.getSuggestions = function(){
        UserService.getSuggestions()
            .then(function(response){
                $scope.suggestedUsers = response
            })
        }

    $scope.showUserProfile = function(id){
        $scope.tweetPermission = (id == $scope.currentUser.id)
        $scope.getUserData(id)
        $scope.getUserTweets(id)
        $scope.tweetsView = true
    }

    // First Run
    $scope.showUserProfile($scope.currentUser.id)
    $scope.getSuggestions()
    $scope.tweetsView = true

    $scope.postTweet = function(tweet){
        UserService.postTweet(tweet)
            .then(function(res){
                $('#newTweet').val('')
                $scope.tweets.push(res)
            })
        }

    $scope.followFriend = function(friend){
        UserService.followFriend(friend.id)
            .then(function(){
                if($scope.tweetPermission){$scope.targetUser.friends_count += 1}
                var index = $scope.suggestedUsers.indexOf(friend);
                $scope.suggestedUsers.splice(index, 1);
            }, function(){
                console.log('Follow event was unsuccessful')
            })
        }

    $scope.getRelationshipsList = function(id,list){
        $scope.tweetsView = false;
        UserService.getRelationshipsList(id)
            .then(function(response){
                if(list=='friends'){
                    $scope.list = response.friends_list
                    $scope.friendsList = true
                } else {
                    $scope.list = response.followers_list;
                    $scope.friendsList = false
                }
            })
        }

    $scope.logout = function(){
        AuthService.logout()
            .then(function(response){
                $location.path('/');
            })
        }

  });
