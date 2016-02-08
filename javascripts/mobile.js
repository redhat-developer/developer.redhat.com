/**
 * Dependencies: vendor/jquery.js, vendor/swipe.js
 */

app.createSlider = function($el) {
  var slider = Swipe($el[0], {
    auto : 0,
    transitionEnd : function() {
      $('.current-slide').text(slider.getPos() + 1);
      // $('.slider-pager-active').removeClass('slider-pager-active');
      // $('.slider-pager a:eq('+idx+')').addClass('slider-pager-active');
    }
  });
  // unbind the next/ prev icons
  $('.solutions-slider-controls a').unbind();

  // Bind the next / prev icons
  $('.solutions-slider-controls a').on('click',function(e){
    e.preventDefault();
    var el = $(this);
    var direction = (el.hasClass('next') ? 'next' : 'prev');
    slider[direction]();
  });

  // Update text
  $('span.current-slide').text('1');
  $('.total-slides').text(slider.getNumSlides());

  return slider;
};

(function() {
 /*
    initialize All sliders
  */
    var sliderEl = document.getElementById('slider');
    var $sliderEl = $(sliderEl);

    /*
      Shuffle if we need to
    */
    var shouldShuffle = $sliderEl.data('shuffle');

    if(shouldShuffle) {
      var slides = $sliderEl.find('.slide');
      slides = slides.sort(function() {
        return 0.5 - Math.random();
      });

      $sliderEl.find('.swipe-wrap').html(slides);
    }

    app.slider = Swipe(sliderEl, {
      auto : $(sliderEl).data('timeout') || 0,

      transitionEnd : function() {
        var idx = app.slider.getPos();
        $('.slider-pager-active').removeClass('slider-pager-active');
        $('.slider-pager a:eq('+idx+')').addClass('slider-pager-active');
        $('.slider-item a[data-index="'+idx+'"]').parent().addClass('slider-pager-active');
      }
    });

    if(app.slider) {
      $(sliderEl).addClass('slider-loaded');

      var numSlides = app.slider.getNumSlides(),
          pagerHtml = "";

      for (var i = 0; i < numSlides; i++) {
        pagerHtml+="<a href='#"+i+"'>"+(i+1)+"</a>";
      }

      $('.slider-pager').html(pagerHtml);
      $('.slider-pager a:first').addClass('slider-pager-active');

      /* Bind Arrows and pager */
      $('.slider-controls').on('click','a',function(e){
        e.preventDefault();

        // pause it
        app.slider.stop();

        var el = $(this);
        var direction = el.data('direction');
        var index = el.data('index');

        if(index >= 0) {
          app.slider.slide(index);
        }
        else {
          app.slider[direction]();
        }

      });

      $('.slider-pager').on('click','a',function(e){
        e.preventDefault();
        var idx = this.href.split('#').pop();
        app.slider.slide(idx);
      });

      if($sliderEl.data('pause-on-hover')) {

        $sliderEl.on('mouseenter',function() {
          app.slider.stop();
        }).on('mouseleave',function(){
          app.slider.start();
        });
      }
    }


})();

/*
  Toggle mobile Nav
*/

$('.nav-toggle').on('click touchend',function(e){
   if (!app.fastClick) {
     // we're binding to touchstart and click. If we have a touchstart, don't also run on click
     app.fastClick = true;
     setTimeout(function(){ app.fastClick = false; }, 100);
     $('body').toggleClass('nav-open');
   }
});

/*
  Mobile Nav dropdown
*/

$('.has-sub-nav').on('click touchend',function(e){
    // e.preventDefault();
    if (!app.fastClick) {
      // we're binding to touchstart and click. If we have a touchstart, don't also run on click
      app.fastClick = true;
      setTimeout(function(){ app.fastClick = false; }, 100);
      // close others
      $('.sub-nav-open').not(this).removeClass('sub-nav-open');
      // open this one
      $(this).toggleClass('sub-nav-open');
    }
});
