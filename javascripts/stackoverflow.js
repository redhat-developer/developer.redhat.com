var stackoverflow = angular.module('stackoverflow', []);

stackoverflow.service('searchService',function($http, $q) {
  this.getSearchResults = function(params) {
    var deferred = $q.defer();
    // http://dcp.stage.jboss.org/v2/rest/search?size=1&field=_source&agg=per_project_counts&agg=tag_cloud&agg=top_contributors&agg=activity_dates_histogram&agg=per_sys_type_counts
    // http://docs.jbossorg.apiary.io/#reference/search-api/2restsearchqueryqueryhighlightsortbyfromsizeaggfieldcontentprovidertypesystypetagprojectactivitydateintervalactivitydatefromactivitydatetocontributor

    // fold in params with defaults
    var stackoverflow = Object.assign(params, {
      // field: '_source',
      field: ["sys_url_view", "sys_title", "is_answered", "author", "sys_tags", "answers", "sys_created", "view_count", "answer_count", "down_vote_count", "up_vote_count", "sys_content"],
      // Disable aggregations until ready
      // agg: ['per_project_counts','tag_cloud', 'top_contributors', 'activity_dates_histogram', 'per_sys_type_counts'],
      query_highlight: true
    });

    var endpoint = (!!window.location.pathname.match(/\/stack-overflow/) ? app.dcp.url.stackoverflow : app.dcp.url.developer_materials);

    $http.get(endpoint, { params: stackoverflow })
      .success(function(data){
        deferred.resolve(data);
      })
      .error(function (err) {
        throw new Error(err);
      });
    return deferred.promise;
  }
});

/*
  Filter to return human readable time ago
*/
stackoverflow.filter('timeAgo', function($sce) {
  return function(result){
    var time = jQuery.timeago(new Date((result._source.sys_created / 1000) * 1000));
    return time;
  }
});

stackoverflow.filter('MDY', function() {
  return function(timestamp){
    if(!timestamp) return;
    var months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    var date = new Date(timestamp);
    window.date = date;
    return months[date.getMonth()] + ' ' + date.getDate() + ', ' + date.getFullYear();
  }
});

stackoverflow.filter('timestamp', function() {
  return function(timestamp){
    var date = new Date(timestamp);
    return date.getTime();
  }
});


/*
 Filter to remove undesirable tags from sys_tags
 */
stackoverflow.filter('tagGroup', function() {
  return function(tag){
    var modifiedTags = [];
    var matcher = new RegExp('feed_group_name_.*|feed_name_.*|red hat|redhat')
    angular.forEach(tag, function(value){
      if(!value.match(matcher))
        modifiedTags.push(value)
    });
    return modifiedTags;
  }
});

stackoverflow.filter('title', function($sce) {
  return function(result){
    if(result.highlight && result.highlight.sys_title) {
      return $sce.trustAsHtml(result.highlight.sys_title);
    }
    return $sce.trustAsHtml(result._source.sys_title);
  }
});

stackoverflow.filter('question', function($sce) {
  return function(result){
    if(result.highlight && result.highlight._source.sys_content_plaintext) {
      return $sce.trustAsHtml(result.highlight._source.sys_content_plaintext[0]);
    }
    return $sce.trustAsHtml(result._source.sys_content_plaintext);
  }
});

/*
 Filter to remove author Stack Overflow id number from 'author'
 */
stackoverflow.filter('author', function($sce) {
  return function(result){
    var authorName = result._source.author.split('-')[0];
    return authorName;
  }
});

stackoverflow.controller('StackOverflowController', ['$scope', 'searchService', searchCtrlFunc]);

function searchCtrlFunc($scope, searchService) {

  var isSearch = !!window.location.href.match(/\/stackoverflow\//);
  // var searchTerm = window.location.stackoverflow.split('=');
  var q = '';

  /* defaults */
  $scope.params = {
    query: q,
    sortBy: 'score',
    size: 10,
    size10: true,
    from: 0,
    sys_type: [],
    project: '',
    newFirst: false
  };

  // Search Page Specifics
  if(isSearch && searchTerm) {
    $scope.params.query = decodeURIComponent(searchTerm.pop().replace(/\+/g,' '));
    $scope.params.type = 'rht_website';
  }

  $scope.paginate = {
    currentPage: 1
  };

  $scope.loading = true;

  $scope.resetPagination = function() {
    $scope.params.from = 0; // start on the first page
    $scope.paginate.currentPage = 1;
  };

  /*
    Clean Params
  */

  $scope.cleanParams = function(p) {
      var params = Object.assign({}, p);

      // if "custom" is selected, remove it
      if(params.publish_date_from && params.publish_date_from === 'custom') {
        params.publish_date_from = params.publish_date_from_custom;
      } else {
        delete params.publish_date_from_custom;
        delete params.publish_date_to;
      }

      // if relevance is "most recent" is turned on, set newFirst to true, otherwise remove it entirely
      if(params.newFirst !== "true") {
        delete params.newFirst;
      }

      // delete old size params
      ['10', '25', '50', '100'].forEach(function(size){
        delete params['size' + size];
      });

      // use the size10=true format
      params['size'+params.size] = true;

      // return cleaned params
      return params;
  };

  $scope.updateSearch = function() {
    $scope.loading = true;
    $scope.query = $scope.params.query; // this is static until the update re-runs
    var params = $scope.cleanParams($scope.params);
    if(isSearch) {
      // DOUBLE CHECK THIS LINE
      history.pushState($scope.params,$scope.params.query,app.baseUrl + '/search/stackoverflow/?q=' + $scope.params.query);
    }
    searchService.getSearchResults(params).then(function(data) {
      $scope.results = data.hits.hits;
      $scope.totalCount = data.hits.total;
      $scope.buildPagination(); // update pagination
      $scope.loading = false;
    });
  };

  /*
   Handle Pagination
   */
  $scope.buildPagination = function() {

    var page = $scope.paginate.currentPage;

    var startAt = (page * $scope.totalCount) - $scope.params.size;
    var endAt = page * $scope.params.size;
    var pages = Math.ceil($scope.totalCount / $scope.params.size);
    var lastVisible = parseFloat($scope.params.size) + $scope.params.from;

    if($scope.totalCount < lastVisible) {
      lastVisible = $scope.totalCount;
    }

    $scope.paginate = {
      currentPage: page,
      pagesArray: app.utils.diplayPagination(page, pages, 4),
      pages: pages,
      lastVisible: lastVisible
    };
  };

  /*
    Pagination goTo
  */

  $scope.goToPage = function(page) {

    switch(page) {
      case 'first':
        page = 1;
        break;
      case 'prev':
        page = $scope.paginate.currentPage - 1;
        break;
      case 'next':
        page = $scope.paginate.currentPage + 1;
        break;
      case 'last':
        page = Math.ceil($scope.totalCount / $scope.params.size);
        break;
      default:
        break;
    }

    if(typeof page !== 'number') return;

    $scope.params.from = (page * $scope.params.size) - $scope.params.size;
    $scope.paginate.currentPage = page;
    $scope.updateSearch();
  };


  $scope.toggleSelection = function toggleSelection(event) {

    var checkbox = event.target;
    var topicNames = checkbox.value.split(' ');

    if (checkbox.checked) {
      // Add - allow for multiple checks
      // $scope.params.sys_type = $scope.params.sys_type.concat(topicNames);
      // Replace - only allow one thing to be checked
      $scope.params.sys_type = topicNames;
    }
    else {
      topicNames.forEach(function(topic) {
        var idx = $scope.params.sys_type.indexOf(topic);
        $scope.params.sys_type.splice(idx, 1);
      });
    }
    // re run the search and reset pagination
    $scope.updateSearch();
    $scope.resetPagination();
  };

  $scope.updateSearch();
}
