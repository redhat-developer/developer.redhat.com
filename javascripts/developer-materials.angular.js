---
interpolate: true
---

var dcp = angular.module('dcp', []);

/*
  Modify $browser.url()
  We need proper + and not encoded + in the URL
  https://github.com/angular/angular.js/issues/3042
*/

dcp.config(function($provide){
  $provide.decorator('$browser', function($delegate) {
      var superUrl = $delegate.url;
      $delegate.url = function(url, replace) {
          if(url !== undefined) {
              return superUrl(url.replace(/\%20/g,"+"), replace);
          } else {
              return superUrl().replace(/\+/g,"%20");
          }
      }
      return $delegate;
  });
});

/*
  Create a service for fetching materials
*/
dcp.service('materialService',function($http, $q) {

  this.getDcp2Blogpost = function(){
    var query = {
      "field"  : ["sys_url_view", "sys_title", "sys_contributors", "sys_description", "sys_created", "author", "sys_tags", "sys_content_id"],
      "size" : 5,
      "sys_type" : "blogpost",
      "sortBy" : "new-create"
    };

    var deferred = $q.defer();

    $http.get(app.dcp2.url.search, { params : query }).success(
        function (data) {
          deferred.resolve(data);
        })
        .error(function () {
          $(".panel[ng-hide='data.materials.length']").replaceWith(app.dcp.error_message);
        });
    return deferred.promise;



  };

  this.getMaterials = function(searchTerms, project) {
    var query = {
      "field"  : ["sys_author", "target_product", "contributors", "duration", "github_repo_url", "level", "sys_contributors",  "sys_created", "sys_description", "sys_title", "sys_tags", "sys_url_view", "thumbnail", "sys_type", "sys_rating_num", "sys_rating_avg", "experimental"],
      "size" : 500,
      "content_provider" : ["jboss-developer", "rht", "openshift"],
      "sortBy" : "new-create"
    };

    if(searchTerms) {
      query.query = decodeURIComponent(decodeURIComponent(searchTerms)); // stop it from being encoded twice
    }
    if(project) {
      query.project = project;
    }

    var deferred = $q.defer();
    // app.dcp.url.search = "//dcp.jboss.org/v1/rest/search"; // testing with live data
    // query = decodeURIComponent(query);
    $http.get(app.dcp.url.search, { params : query }).success(
        function (data) {
          deferred.resolve(data);
        })
        .error(function () {
          $(".panel[ng-hide='data.materials.length']").replaceWith(app.dcp.error_message);
        });
    return deferred.promise;
  }

});

/*
  Filter to determine which thumbnail to return
*/
dcp.filter('thumbnailURL',function(){
  return function(item) {
    var thumbnails = {
      // jboss
      "jbossdeveloper_quickstart" : "#{cdn( site.base_url + '/images/design/get-started/jbossdeveloper_quickstart.png')}",
      "jbossdeveloper_archetype" : "#{cdn( site.base_url + '/images/design/get-started/jbossdeveloper_archetype.png')}",
      "jbossdeveloper_bom" : "#{cdn( site.base_url + '/images/design/get-started/jbossdeveloper_bom.png')}",
      "jbossdeveloper_demo" : "#{cdn( site.base_url + '/images/design/get-started/jbossdeveloper_demo.png')}",
      // futurerproof for when jboss goes unprefixed
      "quickstart" : "#{cdn( site.base_url + '/images/design/get-started/jbossdeveloper_quickstart.png')}",
      "archetype" : "#{cdn( site.base_url + '/images/design/get-started/jbossdeveloper_archetype.png')}",
      "bom" : "#{cdn( site.base_url + '/images/design/get-started/jbossdeveloper_bom.png')}",
      "demo" : "#{cdn( site.base_url + '/images/design/get-started/jbossdeveloper_demo.png')}",
      // redhat
      "solution" : "#{cdn( site.base_url + '/images/design/get-started/solution.png')}",
      "article" : "#{cdn( site.base_url + '/images/design/get-started/article.png')}",
      // need icons?
      "rht_knowledgebase_article" : "#{cdn( site.base_url + '/images/design/get-started/article.png')}",
      "rht_knowledgebase_solution" : "#{cdn( site.base_url + '/images/design/get-started/solution.png')}",
      "jbossdeveloper_vimeo" : "#{cdn( site.base_url + '/images/design/get-started/article.png')}",
      "jbossdeveloper_connector" : "#{cdn( site.base_url + '/images/design/get-started/article.png')}"
    };
    if(item.fields.thumbnail) {
      return item.fields.thumbnail;
    }
    else if(item._type) {
      return thumbnails[item._type];
    }
    else {
      return thumbnails["rht_knowledgebase_article"];
    }
  }

});

dcp.filter('stars',['$sce',function($sce){
  return function(fields) {
    var html = "";
    var fullStars = fields.sys_rating_avg || 0;
    var emptyStars = 5 - fullStars;
    html += new Array(fullStars + 1).join("<i class='fa fa-star'></i>");
    html += new Array(emptyStars + 1).join("<i class='fa fa-star-o'></i>");
    return $sce.trustAsHtml(html);
  }
}]);

/*
  Filter to return whether or not an item is premium
*/
dcp.filter('isPremium',function() {
  return function(url) {
    if(url) {
      return !!url.match("access.redhat.com");
    }
    else {
      return false;
    }
  }
});

/*
  Filter to add brackets
*/
dcp.filter('brackets',function(){
  return function(num){
    if(num > 0) {
      return  "  (" + num + ")";
    }
    return;
  }
});

/*
  Filter to add truncate
*/
dcp.filter('truncate',function(){
  return function(str){
    str = $("<p>").html(str).text(); // parse html entities
    if(str.length <= 150) {
      return str;
    }
    //
    return str.slice(0,150) + "…";
  }
});

/*
  Filter to format time
*/
dcp.filter('HHMMSS',function() {
  return function(seconds) {
    var sec_num = parseInt(seconds, 10); // don't forget the second param
    var hours   = Math.floor(sec_num / 3600);
    var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
    var seconds = sec_num - (hours * 3600) - (minutes * 60);

    if (hours   < 10) {hours   = "0"+hours;}
    if (minutes < 10) {minutes = "0"+minutes;}
    if (seconds < 10) {seconds = "0"+seconds;}

    var time    = minutes+':'+seconds;
    // only show hours if there are some
    if(parseInt(hours) > 0) {
      time = hours+':'+ time;
    }
    return time;
  }
});

/*
  Filter to return human readable time ago
*/
dcp.filter('timeAgo',function() {
  return function(timestamp){
    if(!timestamp) return;

    var date = new Date(timestamp);
    return $.timeago(date);
  }
});

/*
 Remove fields that don't contain required sys_url_view links
 */
dcp.filter('noURL', function() {
    return function(str){
        var filterArray = [];
        angular.forEach(str, function(ref){
            if(ref.fields.sys_url_view){
                filterArray.push(ref);

            }
        })
        return filterArray;
    }
});

/*
  Filter to use the correct location for links coming from seachisko.
*/
dcp.filter('urlFix', function() {
  return function(str){
    if(!str.length) {
      return; // no string provided
    }
    else if (str.contains("access.redhat.com") || str.contains("hub-osdevelopers.rhcloud.com")) {
      return str;
    } else {
      return str.replace(/^http(s)?:\/\/(\w|\.|\-|:)*(\/pr\/\d+\/build\/\d+)?/, '#{site.base_url}');
    }
  }
});

/*
  Filter to trim whitespace
*/
dcp.filter('trim',function() {
  return function(str){
    return str.trim();
  }
});

/*
  Return just the name, no email
*/
dcp.filter('name',function(){
  return function(str){
    str = str || "";
    var pieces = str.split('<');
    if(pieces.length) {
      return pieces[0].trim()
    }
    else {
      return;
    }
  }
});

/*
  Return the proper name for formats
*/
dcp.filter('formatName',function(){
  return function(value, scope){
    for(f in scope.data.availableFormats) {
      var format = scope.data.availableFormats[f];
      if(format.value === value) {
        return format.name;
        break;
      }
    }
    // if not in our object, returnt the original value
    return value;
  }
});

/**
 * safeNumber is an "ng filter" that accept string value
 * and convert to number (using radix of 10). If parsing
 * fails (NaN) then 0 is returned.
 */
dcp.filter('safeNumber', function() {
  return function(input) {
    var n = parseInt(input, 10);
    return isNaN(n) ? 0 : n;
  }
});

/**
 * checkInternal checks is a link is internal
 */
dcp.filter('checkInternal',function() {
  return function(item) {
    if(!item.fields.sys_url_view) {
      return true;
    }
    else if(!!item.fields.sys_url_view.match(window.location.host)) {
      return true;
    }
    return false;
  }
});

dcp.controller('developerMaterialsController', function($scope, materialService) {

  window.scope = $scope;
  $scope.data = {};
  $scope.filters = {};
  $scope.randomize = false;
  $scope.pagination = {
    size : 10
  };

  // Add Math object to $scope so we can use it directly in Angular expressions
  // like: {{ Math.min(data.materials.length, paginate.currentPage * pagination.size) }}
  // This might not be clean technique from Angular perspective (more clear would be
  // to do all required calculations in controller and not the view)
  $scope.Math = Math;

  /*
    Handle Pagination
  */
  $scope.paginate = function(page) {
    $scope.pagination.size = ($scope.pagination.viewall ? 500 : $scope.pagination.size);
    var startAt = (page * $scope.pagination.size) - $scope.pagination.size;
    var endAt = page * $scope.pagination.size;
    var pages = Math.ceil($scope.data.materials.length / $scope.pagination.size);

    // do nothing if we have no more pages
    if(page > pages || page < 1 || typeof page === "string") {
      return;
    }

    $scope.paginate.pages = pages;
    // $scope.paginate.pagesArray = new Array(pages);
    $scope.paginate.currentPage = page;

    // $scope.data.displayedMaterials = [];
    $scope.data.displayedMaterials = $scope.data.materials.slice(startAt,endAt);

    // pagination display logic
    $scope.paginate.pagesArray = app.utils.diplayPagination($scope.paginate.currentPage, pages, 4);

    // next tick
    window.setTimeout(function() {
      app.dcp.resolveContributors();
    },0);
  }

  /*
    Handle Filters
  */
  $scope.filters = {}; // stores data
  $scope.filter = {}; // stores util functions

  $scope.data.availableTopics = #{site.dev_mat_techs.flatten.uniq.sort};

  $scope.data.availableFormats = [
    { value : "quickstart" , "name" : "Quickstart", "description" : "Single use-case code examples tested with the latest stable product releases" },
    { value : "video" , "name" : "Video", "description" : "Short tutorials and presentations for Red Hat JBoss Middleware products and upstream projects" },
    { value : "demo" , "name" : "Demo", "description" : "Full applications that show what you can achieve with Red Hat JBoss Middleware" },
    { value : "jbossdeveloper_example" , "name" : "Tutorial", "description" : "Guided content, teaching you how to build complex applications from the ground up" },
    { value : "jbossdeveloper_archetype" , "name" : "Archetype", "description" : "Maven Archetypes for building Red Hat JBoss Middleware applications" },
    { value : "jbossdeveloper_bom" , "name" : "BOM", "description" : "Maven BOMs for managing dependencies within Red Hat JBoss Middleware applications" },
    { value : "jbossdeveloper_sandbox" , "name" : "Early Access", "description" : "Single use-case code examples demonstrating features not yet available in a product release" },
    { value : "article" , "name" : "Articles (Premium)", "description" : "Technical articles and best practices for Red Hat JBoss Middleware products" },
    { value : "solution" , "name" : "Solutions (Premium)", "description" : "Answers to questions or issues you may be experiencing" }
  ];

  $scope.filters.sys_tags = [];
  $scope.filters.sys_type = [];
  $scope.filter.toggleSelection = function toggleSelection(itemName, selectedArray) {

      if(!$scope.filters[selectedArray]) {
        $scope.filters[selectedArray] = [];
      }

      var idx = $scope.filters[selectedArray].indexOf(itemName);
      // is currently selected
      if (idx > -1) {
        $scope.filters[selectedArray].splice(idx, 1);
      }

      // is newly selected
      else {
        $scope.filters[selectedArray].push(itemName);
      }
  };

  /*
    Update skill level when the range input changes
  */
  $scope.filter.updateSkillLevel = function() {
    var n = parseInt($scope.data.skillNumber);
    var labels = ["All", "Beginner", "Intermediate", "Advanced"];
    $scope.data.displaySkill = labels[n];
    switch (n) {
      case 0 :
        delete $scope.filters.level;
        break;
      case 1 :
        $scope.filters.level = "Beginner";
        break;
      case 2 :
        $scope.filters.level = "Intermediate";
        break;
      case 3 :
        $scope.filters.level = "Advanced";
        break;
    }
  }

  /*
    Update date when the range input changes
  */
  $scope.filter.updateDate = function() {
    var n = parseInt($scope.data.dateNumber);
    var d = new Date();
    var labels = ["All", "Within 1 Year", "Within 30 days", "Within 7 days", "Within 24hrs"];
    $scope.data.displayDate = labels[n];

    switch(n) {
      case 0 :
        delete $scope.filters.sys_created;
        break;
      case 1 :
        //Within 1 Year
        d.setFullYear(d.getFullYear() - 1);
        break;
      case 2 :
        //Within 30 days
        d.setDate(d.getDate() - 30);
        break;
      case 3 :
        //Within 7 days
        d.setDate(d.getDate() - 7);
        break;
      case 4 :
        //Within 24 hours
        d.setDate(d.getDate() - 1);
        break;
    }

    if(n) {
      $scope.filters.sys_created = ">=" + d.getFullYear() + "-" + ( d.getMonth() + 1 ) + "-" + d.getDate();
    }
  }

  $scope.filter.clear = function() {
    $scope.filters.sys_tags = [];
    $scope.filters.sys_type = [];
    $scope.data.dateNumber = 0;
    $scope.data.skillNumber = 0;
    delete $scope.filters.query;
    delete $scope.filters.sys_rating_avg;
    delete $scope.filters.level;
    delete $scope.filters.sys_created;
    // clear local storage
    delete localStorage[$scope.data.pageType + '-filters'];
    // trigger chosen
    $(".chosen").trigger("chosen:updated");
  }

  $scope.filter.createString = function() {
    var searchTerms = [];

    if($scope.filters.query){
      searchTerms.push($scope.filters.query);
    }

    if($scope.filters.sys_rating_avg) {
      searchTerms.push("sys_rating_avg:>="+$scope.filters.sys_rating_avg);
    }

    if($scope.filters.sys_tags && $scope.filters.sys_tags.length){
        if(typeof $scope.filters.sys_tags === 'string') {
          var tags = $scope.filters.sys_tags; // singular string
        }
        else {
          var tags = "\"" + $scope.filters.sys_tags.join("\" \"") + "\""; // array
        }
        searchTerms.push('sys_tags:('+tags+')');
    }

    if($scope.data.sys_type_string && $scope.data.sys_type_string.length){
      // convert single sys_type into an array - allows us to switch to multi-select down the road
      $scope.filters.sys_type = [$scope.data.sys_type_string];
      // remove jbossdeveloper_sandbox "Early Access and convert it to experimental"

        var idx = $scope.filters.sys_type.indexOf("jbossdeveloper_sandbox");

        if(idx >= 0 && $scope.filters.sys_type.length > 1) {
          // We have experimental turned on, but we also have other types to search for
          searchTerms.push("(experimental:true AND sys_type:(jbossdeveloper_sandbox jbossdeveloper_quickstart)) OR sys_type:("+$scope.filters.sys_type.join(" ")+")");
        }
        else if(idx >= 0 && scope.filters.sys_type.length === 1) {
          // Only Experimental - just search for that without sys_types
          searchTerms.push("experimental:true");
        }
        else {
          // no experimental - just regular search
          searchTerms.push("sys_type:("+$scope.filters.sys_type.join(" ")+")");
        }

    } else {
      // There are no types, set the default ones
      searchTerms.push("sys_type:(jbossdeveloper_bom quickstart jbossdeveloper_archetype video article solution jbossdeveloper_example)");
    }

    if($scope.filters.level){
      searchTerms.push("(level:"+$scope.filters.level + "%20OR%20_missing_:level)");
    }

    if($scope.filters.sys_created){
      searchTerms.push("sys_created:"+$scope.filters.sys_created);
    }

    searchTerms = searchTerms.join(" AND ");

    $scope.data.searchTerms = searchTerms;

    return searchTerms;
  };

  $scope.filter.applyFilters = function() {
    $scope.data.displayedMaterials = [];
    $scope.data.loading = true;
    var q = this.createString();

    materialService.getMaterials(q, $scope.filters.project).then(function(data){
      $scope.data.materials = data.hits.hits;
      // http://www.codinghorror.com/blog/2007/12/the-danger-of-naivete.html
      // explicity check for true, or "true" as it comes in as a string
      if ($scope.randomize == true) {
        $scope.data.materials = (function knuthfisheryates(arr) {
          var i, temp, j, len = arr.length;
          for (i = 0; i < len; i++) {
            j = ~~(Math.random() * (i + 1));
            temp = arr[i];
            arr[i] = arr[j];
            arr[j] = temp;
          }
          return arr;
        })($scope.data.materials);
      }
      $scope.data.loading = false;
      $scope.paginate(1); // start at page 1
      $scope.filter.group();
    });

    // save search in local storage
    $scope.filter.store();
    // update the page hash
    window.location.hash = "!" + $.param($scope.filters);

  }

  /*
    groups the items together by type so we can provide a count
  */
  $scope.filter.group = function() {
    $scope.data.groups = {};
    for (var i = 0; i < $scope.data.materials.length; i++) {
      (function(sys_type, sys_tags){

        // group the types (formats)
        if($scope.data.groups[sys_type] >= 0) {
          $scope.data.groups[sys_type]++;
        }
        else {
         $scope.data.groups[sys_type] = 0;
        }

        // group the tags (topics)
        if(sys_tags) {

          // we prefix the index with tag- because "demo" is both a tag and a topic
          for (var i = 0; i < sys_tags.length; i++) {
            if($scope.data.groups['tag-' + sys_tags[i]] >= 0) {
              $scope.data.groups['tag-' + sys_tags[i]]++;
            }
            else {
             $scope.data.groups['tag-' + sys_tags[i]] = 0;
            }
          };

        }

      })($scope.data.materials[i].fields.sys_type, $scope.data.materials[i].fields.sys_tags);
    };
  }

  $scope.filter.store = function() {
    // check if we have local storage, abort if not
    // if(!window.localStorage || $scope.filters.project || $scope.filters.solution) { return; }
    // store them in local storage
    window.localStorage[$scope.data.pageType + '-filters'] = JSON.stringify(scope.filters);
    window.localStorage[$scope.data.pageType + '-filtersTimeStamp'] = new Date().getTime();
  }

  $scope.filter.restore = function() {
    // restore and set
    $scope.data.skillNumber = 0;
    $scope.data.dateNumber = 0;

    if(window.localStorage.layout === 'grid' || window.localStorage.layout === 'list') {
      $scope.data.layout = window.localStorage.layout;
    } else {
      $scope.data.layout = 'list';
    }

    // if we are on a project page, skip restoring
    // if($scope.filters.project || $scope.filters.solution) {
    //   $scope.filter.applyFilters(); // run without restoring filters
    //   return;
    // }

    // check if we have window hash,  local storage or any stored filters, abort if not
    if(!window.location.hash && (!window.localStorage || !window.localStorage[$scope.data.pageType + '-filters'])) {
      $scope.filter.applyFilters(); // run with no filters
      return;
    }

    if(window.location.hash) {
      var hashFilters = window.location.hash.replace('#!','');
      var filters = deparam(hashFilters);

      // check for single string sys_type
      if(typeof filters.sys_type === "string") {
        // convert to array with 1 item
        var filterArr = [];
        filterArr.push(filters.sys_type);
        filters.sys_type = filterArr;
      }

      $scope.filters = filters;

      // restore skill level slider
      if($scope.filters.level) {
        var labels = ["All", "Beginner", "Intermediate", "Advanced"];
        var idx = labels.indexOf($scope.filters.level);
        if(idx>=0) {
          $scope.data.skillNumber = idx;
        }
        $scope.filter.updateSkillLevel();
      }

      // restore date slider to closest match
      if($scope.filters.sys_created) {
        var parts = scope.filters.sys_created.replace('>=','').split('-'); // YYYY MM DD
        var d = new Date(parts[0], parts[1], parts[2]); // Year, month date
        var now = new Date().getTime();
        var ago = now - d;
        var daysAgo = Math.floor(ago / 1000 / 60 / 60 / 24);

        if(daysAgo <= 1) {
          $scope.data.dateNumber = 4;
        } else if(daysAgo > 1 && daysAgo <= 7) {
          $scope.data.dateNumber = 3;
        } else if(daysAgo > 7 && daysAgo <= 30) {
          $scope.data.dateNumber = 2;
        } else {
          $scope.data.dateNumber = 1;
        }
        $scope.filter.updateDate();
      }

    }
    else if(window.localStorage && window.localStorage[$scope.data.pageType + '-filters']) {
      // only restore if less than 2 hours old
      var now = new Date().getTime();
      var then = window.localStorage[$scope.data.pageType + '-filtersTimeStamp'] || 0;

      if((now - then) < 7200000) { // 2 hours
        $scope.filters = JSON.parse(window.localStorage[$scope.data.pageType + '-filters']);
      }
    }

    $scope.filter.applyFilters();
  }


  $scope.chosen = function() {
    $('select.chosen').unbind().chosen().change(function() {
      var tags = $(this).val();
      if(tags) {
        $scope.filters.sys_tags = tags;
      }
      else {
        delete $scope.filters.sys_tags;
      }
      $scope.$apply();
      $scope.filter.applyFilters()
    }).trigger('chosen:updated');
  }

  /*
    Update chosen when the available topics update
  */
  $scope.$watch('data.availableTopics',function(){
    // next tick
    window.setTimeout(function(){
      $scope.chosen();
    },0);
  });

  /*
    Update chosen when the counts update
  */
  $scope.$watch('data.groups',function() {
    window.setTimeout(function() {
      $(".chosen").trigger("chosen:updated");
    },0);
  });

  /*
    Watch for the layout to change and update localstorage
  */
  $scope.$watch('data.layout',function(newVal, oldVal) {
    if($scope.data.layout) {
      window.localStorage.layout = $scope.data.layout;
    }
  });

  /*
    Get latest materials on page load
  */
  window.setTimeout($scope.filter.restore, 0);

});

dcp.controller('latestMaterialsController', function($scope, materialService) {

  window.scope = $scope;
  $scope.data = {};
  $scope.filters = {};
  $scope.randomize = false;
  $scope.pagination = {
    size : 10
  };

  // Add Math object to $scope so we can use it directly in Angular expressions
  // like: {{ Math.min(data.materials.length, paginate.currentPage * pagination.size) }}
  // This might not be clean technique from Angular perspective (more clear would be
  // to do all required calculations in controller and not the view)
  $scope.Math = Math;

  /*
   Handle Pagination
   */
  $scope.paginate = function(page) {
    $scope.pagination.size = ($scope.pagination.viewall ? 500 : $scope.pagination.size);
    var startAt = (page * $scope.pagination.size) - $scope.pagination.size;
    var endAt = page * $scope.pagination.size;
    var pages = Math.ceil($scope.data.materials.length / $scope.pagination.size);

    // do nothing if we have no more pages
    if(page > pages || page < 1 || typeof page === "string") {
      return;
    }

    $scope.paginate.pages = pages;
    // $scope.paginate.pagesArray = new Array(pages);
    $scope.paginate.currentPage = page;

    // $scope.data.displayedMaterials = [];
    $scope.data.displayedMaterials = $scope.data.materials.slice(startAt,endAt);

    // pagination display logic
    $scope.paginate.pagesArray = app.utils.diplayPagination($scope.paginate.currentPage, pages, 4);

    // next tick
    window.setTimeout(function() {
      app.dcp.resolveContributors();
    },0);
  }

  /*
   Handle Filters
   */
  $scope.filters = {}; // stores data
  $scope.filter = {}; // stores util functions



  $scope.filters.sys_tags = [];
  $scope.filters.sys_type = [];




  $scope.filter.applyFilters = function() {
    $scope.data.displayedMaterials = [];
    $scope.data.loading = true;
    var q = "";


    materialService.getMaterials(q, $scope.filters.project).then(function(data){
      $scope.data.materials = data.hits.hits;
      // http://www.codinghorror.com/blog/2007/12/the-danger-of-naivete.html
      // explicity check for true, or "true" as it comes in as a string
      if ($scope.randomize == true) {
        $scope.data.materials = (function knuthfisheryates(arr) {
          var i, temp, j, len = arr.length;
          for (i = 0; i < len; i++) {
            j = ~~(Math.random() * (i + 1));
            temp = arr[i];
            arr[i] = arr[j];
            arr[j] = temp;
          }
          return arr;
        })($scope.data.materials);
      }

      $scope.paginate(1); // start at page 1
      $scope.filter.group();
      /*
       Promise has been returned from dcp1 - now we need updated blogposts from dcp2
       */
      materialService.getDcp2Blogpost().then(function(data){
        var blogposts = data.hits.hits;
        /*
         Only take blogposts with valid dates
         */
        var validBlogPosts = [];
        angular.forEach(blogposts, function(blogpost){
          var valid = true;
          if(blogpost.fields.sys_created !== undefined && moment().diff(blogpost.fields.sys_created.toString(), 'days') < 0){
            valid = false;
          }
          angular.forEach(blogpost.fields, function(key, value){
            var keyString = key.toString();
            if(value == "sys_url_view" && !(keyString.startsWith('http://developerblog.redhat.com'))){
              keyString = "//planet.jboss.org/post/" + blogpost.fields.sys_content_id;
            }
            blogpost.fields[value] = keyString;
          });
          if(valid){
            validBlogPosts.push(blogpost);
          }

        });
        $scope.data.latestMaterials = $scope.filter.mergeResults($scope.data.displayedMaterials, validBlogPosts)
        $scope.data.loading = false;

      });


    });

    $scope.filter.mergeResults = function(dest, src){
      for(i=0; i < src.length; i++) {
        dest.push(src[i]);

      }
      dest.sort(function (a, b) {
        return (a.fields.sys_created < b.fields.sys_created ? 1 : -1);
      });
      return dest;

    }
    // save search in local storage
    $scope.filter.store();
    // update the page hash
    window.location.hash = "!" + $.param($scope.filters);

  }

  /*
   groups the items together by type so we can provide a count
   */
  $scope.filter.group = function() {
    $scope.data.groups = {};
    for (var i = 0; i < $scope.data.materials.length; i++) {
      (function(sys_type, sys_tags){

        // group the types (formats)
        if($scope.data.groups[sys_type] >= 0) {
          $scope.data.groups[sys_type]++;
        }
        else {
          $scope.data.groups[sys_type] = 0;
        }

        // group the tags (topics)
        if(sys_tags) {

          // we prefix the index with tag- because "demo" is both a tag and a topic
          for (var i = 0; i < sys_tags.length; i++) {
            if($scope.data.groups['tag-' + sys_tags[i]] >= 0) {
              $scope.data.groups['tag-' + sys_tags[i]]++;
            }
            else {
              $scope.data.groups['tag-' + sys_tags[i]] = 0;
            }
          };

        }

      })($scope.data.materials[i].fields.sys_type, $scope.data.materials[i].fields.sys_tags);
    };
  }

  $scope.filter.store = function() {
    // check if we have local storage, abort if not
    // if(!window.localStorage || $scope.filters.project || $scope.filters.solution) { return; }
    // store them in local storage
    window.localStorage[$scope.data.pageType + '-filters'] = JSON.stringify(scope.filters);
    window.localStorage[$scope.data.pageType + '-filtersTimeStamp'] = new Date().getTime();
  }

  $scope.filter.restore = function() {
    // restore and set
    $scope.data.skillNumber = 0;
    $scope.data.dateNumber = 0;

    if(window.localStorage.layout === 'grid' || window.localStorage.layout === 'list') {
      $scope.data.layout = window.localStorage.layout;
    } else {
      $scope.data.layout = 'list';
    }

    // if we are on a project page, skip restoring
    // if($scope.filters.project || $scope.filters.solution) {
    //   $scope.filter.applyFilters(); // run without restoring filters
    //   return;
    // }

    // check if we have window hash,  local storage or any stored filters, abort if not
    if(!window.location.hash && (!window.localStorage || !window.localStorage[$scope.data.pageType + '-filters'])) {
      $scope.filter.applyFilters(); // run with no filters
      return;
    }

    if(window.location.hash) {
      var hashFilters = window.location.hash.replace('#!','');
      var filters = deparam(hashFilters);

      // check for single string sys_type
      if(typeof filters.sys_type === "string") {
        // convert to array with 1 item
        var filterArr = [];
        filterArr.push(filters.sys_type);
        filters.sys_type = filterArr;
      }

      $scope.filters = filters;

      // restore skill level slider
      if($scope.filters.level) {
        var labels = ["All", "Beginner", "Intermediate", "Advanced"];
        var idx = labels.indexOf($scope.filters.level);
        if(idx>=0) {
          $scope.data.skillNumber = idx;
        }
        $scope.filter.updateSkillLevel();
      }

      // restore date slider to closest match
      if($scope.filters.sys_created) {
        var parts = scope.filters.sys_created.replace('>=','').split('-'); // YYYY MM DD
        var d = new Date(parts[0], parts[1], parts[2]); // Year, month date
        var now = new Date().getTime();
        var ago = now - d;
        var daysAgo = Math.floor(ago / 1000 / 60 / 60 / 24);

        if(daysAgo <= 1) {
          $scope.data.dateNumber = 4;
        } else if(daysAgo > 1 && daysAgo <= 7) {
          $scope.data.dateNumber = 3;
        } else if(daysAgo > 7 && daysAgo <= 30) {
          $scope.data.dateNumber = 2;
        } else {
          $scope.data.dateNumber = 1;
        }
        $scope.filter.updateDate();
      }

    }
    else if(window.localStorage && window.localStorage[$scope.data.pageType + '-filters']) {
      // only restore if less than 2 hours old
      var now = new Date().getTime();
      var then = window.localStorage[$scope.data.pageType + '-filtersTimeStamp'] || 0;

      if((now - then) < 7200000) { // 2 hours
        $scope.filters = JSON.parse(window.localStorage[$scope.data.pageType + '-filters']);
      }
    }

    $scope.filter.applyFilters();
  }


  $scope.chosen = function() {
    $('select.chosen').unbind().chosen().change(function() {
      var tags = $(this).val();
      if(tags) {
        $scope.filters.sys_tags = tags;
      }
      else {
        delete $scope.filters.sys_tags;
      }
      $scope.$apply();
      $scope.filter.applyFilters()
    }).trigger('chosen:updated');
  }

  /*
   Update chosen when the available topics update
   */
  $scope.$watch('data.availableTopics',function(){
    // next tick
    window.setTimeout(function(){
      $scope.chosen();
    },0);
  });

  /*
   Update chosen when the counts update
   */
  $scope.$watch('data.groups',function() {
    window.setTimeout(function() {
      $(".chosen").trigger("chosen:updated");
    },0);
  });

  /*
   Watch for the layout to change and update localstorage
   */
  $scope.$watch('data.layout',function(newVal, oldVal) {
    if($scope.data.layout) {
      window.localStorage.layout = $scope.data.layout;
    }
  });

  /*
   Get latest materials on page load
   */
  window.setTimeout($scope.filter.restore, 0);

});


// jQuery for mobile filters

$(function() {
  $('form.dev-mat-filters').on('submit',function(e) {
    e.preventDefault();
  });

  $('.filters-clear').on('click',function(e){
    e.preventDefault();
    app.dm.clearFilters($(this));
  });

  // slide toggle on mobile
  $('.filter-block h5').on('click',function() {
    if(window.innerWidth <= 768) {
      var el = $(this);
      el.toggleClass('filter-block-open');
      el.next('.filter-block-inputs').slideToggle(300);
    }
  });

  // toggle filters on mobile
  $('.filter-toggle').on('click',function() {
    if(window.innerWidth <= 768) {
      $('.developer-materials-sidebar').toggleClass('open');
    }
  });

});

