/*
  Topics  Component
  Shows up on the bottom part of each Topic's page
*/

app = window.app || {};

app.topics = {};


app.topics.fetch = function() {
  var tags = ($('#topic-resources').data('tags') || "")
  // var tags = container.data('tags') || "";
    try {
      tags = JSON.parse(tags.replace(/'/g, "\""));
    } catch (e) {
      tags = "";
    }

    if(tags){
      var tagsString = "";
      for (var i = 0; i < tags.length; i++) {
        if (i > 0) {
          tags[i] = "&tag=" + tags[i];
        }
        tagsString += (tags[i]).toLowerCase();
      }
    }
  $.getJSON(app.dcp.url.search + '/resources?tags_or_logic=true&newFirst=true&size25=true&tag=' + tagsString, function(data){
    if(data.hits && data.hits.hits) {
      app.topics.render(data.hits.hits);
    }
  });
}

app.topics.render = function(materials) {
  var html = [];
  materials.forEach(function(material){
    var type = material.fields.sys_type[0];
    var timeStamp = new Date(material.fields.sys_created[0]);
    var timeAgo = $.timeago(timeStamp);
    // var tags = item.fields.sys_tags.join(', ')
    var item = [
      '<a href="' + material.fields.sys_url_view[0] + '">',
        '<li class="large-6 columns">',
          '<h5>',
            material.fields.sys_title[0],
          '</h5>',
          '<p class="description">',
            material.fields.sys_description[0],
          '</p>',
          '<p class="tags">Tags: ',
            material.fields.sys_tags.join(', '),
          '</p>',
        '</li>',
      '</a>'
    ].join('');

    html.push(item);
  });

  $('.topic-resources-list').html(html.join(''));
}

$(function() {
  var $topicsResourceList = $('.topic-resources-list');
  // check if we are on a page that needs this to run
  if($topicsResourceList.length) {
    app.topics.fetch();
  }
});
