var shiftSampleApp = angular.module('shiftSampleApp', ['ngMessages','ngRoute','routeStyles','ngStorage']);

shiftSampleApp
  .config(function($httpProvider, $routeProvider, $locationProvider){

    $httpProvider.interceptors.push('HttpInterceptor')      
    
    $routeProvider
      .when('/',{
        templateUrl: '/js/templates/home.html',
        controller: 'LoginCtrl',
        css: ['/css/animate.min.css','/css/lightbox.css','/css/main.css','/css/responsive.css']
      })
      .when('/users/:id',{
        templateUrl: '/js/templates/profile.html',
        controller: 'UsersCtrl',
        css: '/css/profile.css'
      })

      .otherwise({
        redirectTo: '/'
      });

      
      // use the HTML5 History API
      // $locationProvider.html5Mode(true);
  });
