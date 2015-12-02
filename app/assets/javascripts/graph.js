$(function () {
    var screen_name = $('p.screen_name').html();
    var xData = JSON.parse($('p.xData').text());
    var followers_record = JSON.parse($('p.followers_record').text());
    var favorites = JSON.parse($('p.favorites').text());
    var data_changes = JSON.parse($('p.data_changes').text());
    Array.max = function( array ){
    return Math.max.apply( Math, array );
    };
    Array.min = function( array ){
        return Math.min.apply( Math, array );
    };

    var min = Array.min(followers_record)
    var max = Array.max(followers_record)

    // split the data set into Followers and Favourites
    var followers_count = [],
        favorites_count = [],
        dataLength = xData.length,
        // set the allowed units for data grouping
        groupingUnits = [['week',[1]], ['month',[1, 2, 3, 4, 6]]],

        i = 0
    for (i; i < dataLength; i += 1) {
        followers_count.push([
            xData[i],
            followers_record[i]
        ]);

        favorites_count.push([
            xData[i],
            favorites[i]
        ]);
    }


    function updateTwitterStream(msg){
        if (msg.length >= 1) {
            for(var i = 0; i < msg.length; i++) {
              var tweet = msg[i]
              twttr.widgets.createTweet(
              tweet,
              document.getElementById('new-tweets'),
              {
                theme: 'light'
              }
            ).then( function( el ) {
                console.log('Tweet added.');
              });
            }
        } else {
            $('.tweet-stream').show()
        }
    }

    // This function is called when user clicks on a point on the graph
    function showFollowersUnfollowers(point_of_time){
        new_followers = data_changes[point_of_time]["new_followers"];
        unfollowers = data_changes[point_of_time]["unfollowers"];
        $('#new_followers').empty();
        $('#unfollowers').empty();
        // populating list of new_followers
        for(var follower=0; follower<new_followers.length; follower++){
          $('#new_followers').append("<tr> <td> <img src=" +new_followers[follower]["photo"] + ">" + "</td> <td> <a href='https://twitter.com/" + new_followers[follower]["screen_name"] + "'>" + new_followers[follower]["screen_name"] + "</td> </tr>")}
        // populating list of unfollowers
        for(var unfollower=0; unfollower<unfollowers.length; unfollower++){
          $('#unfollowers').append("<tr> <td> <img src=" +unfollowers[unfollower]["photo"] + ">" + "</td> <td> <a href='https://twitter.com/" + unfollowers[unfollower]["screen_name"] + "'>" + unfollowers[unfollower]["screen_name"] + "</td> </tr>")}
    }

    $('#container').highcharts('StockChart', {
        chart: {
            zoomType: 'x',
            spacingTop: 0
        },
        tooltip: {
            formatter: function () {
                var point_of_time = this.x.toString();
                followers = data_changes[point_of_time]["new_followers"].length;
                unfollowers = data_changes[point_of_time]["unfollowers"].length;
                totalFollowers = this["y"]
                return "Total Followers:" + totalFollowers + "<br>New Followers: " + followers + "<br>Unfollowers: " + unfollowers;
            },
        },
        rangeSelector: {
            // enabled: false,
            selected: 1
        },
        title: {
            text: 'Your Twitter Activity Trends'
        },
        subtitle: {
            text: document.ontouchstart === undefined ? 'Click and drag in the plot area to zoom in<br>Click a data point to view your tweets' : 'Pinch the chart to zoom in'
        },
        yAxis: [{
                min: min - ((max-min) * 0.05),
                labels: {
                    align: 'right',
                    x: -3
                },
                title: {
                    text: 'Followers'
                },
                // height: '60%',
                // lineWidth: 2
            }
            // , {
            //     labels: {
            //         align: 'right',
            //         x: -3
            //     },
            //     title: {
            //         text: 'Favorites'
            //     },
            //     top: '65%',
            //     height: '35%',
            //     offset: 0,
            //     lineWidth: 2
            // }
            ],
        series: [{
                    type: 'areaspline',
                    name: 'Followers',
                    data: followers_count,
                    dataGrouping: {
                        units: groupingUnits
                    },
                    allowPointSelect: true,
                    point: {
                        events:{
                            select: function(e){
                                var point_of_time = (e.currentTarget.x)
                                showFollowersUnfollowers(point_of_time)
                                // $('#tweets').empty()
                                $('#new-tweets').empty()
                                $('.tweet-stream').hide()
                                $.ajax({
                                    url: '/users',
                                    method: "GET",
                                    data: {timestamp: point_of_time, screen_name: screen_name}
                                }).done(function(msg){
                                    updateTwitterStream(msg)
                                });
                            }
                        }
                    },
                    fillColor : {
                        linearGradient : {
                            x1: 0,
                            y1: 0,
                            x2: 0,
                            y2: 1
                        },
                        stops : [
                            [0, Highcharts.getOptions().colors[0]],
                            [1, Highcharts.Color(Highcharts.getOptions().colors[2]).setOpacity(0).get('rgba')]
                        ]
                    }
                }
                // ,{
                //     type: 'area',
                //     name: 'Favorites',
                //     data: favorites_count,
                //     yAxis: 1,
                //     dataGrouping: {
                //         units: groupingUnits
                //     }
                // }
                ]
        // });
    });
});
