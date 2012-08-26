$(function () { $('.tabs').tabs(); })
$(function () { hljs.initHighlightingOnLoad(); })

var Site = {}
Site.animation = (function() {

  var me = {};

  me.init = function(container_id) {

    // Page structure 
    var container = $(container_id),
        canvas    = container.find('.canvas'),
        paper     = Raphael(canvas.attr('id'));

    // Lines visualization settings
    var path_attr   = {"stroke-width": 2, stroke: "#ddd"},
        first_line  = paper.path("M18 20L292 20").attr(path_attr),
        second_line = paper.path("M308 20L610 20").attr(path_attr);

    // Circle visualization settings
    var circle_attr   = {stroke: "none", fill: "#ddd"},
        first_circle  = paper.circle(15, 20, 10).attr(circle_attr);
        second_circle = paper.circle(300, 20, 10).attr(circle_attr);
        third_circle  = paper.circle(615, 20, 10).attr(circle_attr);

    // Moving circle visualization settings
    var moving_circle_attr = {stroke: "#FF7600", "stroke-width": 4},
        moving_circle      = paper.circle(15, 20, 4).attr(moving_circle_attr);

    // Apply a bouncing animation to the first circle
    setTimeout(fade(first_circle, container.find('.first-step')), 1000);

    // Show the first stem description
    show_step('.first-step');

    // Buttons click
    container.find(".first-step .btn-warning").click(function (e)  { go_to_second_step(e) })
    container.find(".second-step .btn-warning").click(function (e) { go_to_third_step(e) })
    container.find(".third-step .btn-warning").click(function (e)  { go_to_first_step(e) })

    first_circle.click(function (e) { go_to_first_step(e) })
    second_circle.click(function (e) { go_to_second_step(e) })
    third_circle.click(function (e) { go_to_third_step(e) })

    // ----------
    // Private
    // ----------

      // Node arrival animation
      //   - circle: object to animate at the end of the animation
      //   - content_id: step description to show
      function fade(circle, step) {
        return function () {
          show_step(step);
          circle.attr({fill: "#FF7600", r: 14}).animate({fill: "#ddd", r: 10, easing: '>'}, 1000);
        };
      }

      // Create animation
      //   - x: final x position
      //   - circle: object to animate at the end of the animation
      //   - content_id: step description to show
      function animate(x, circle, content_id) {
        moving_circle.stop().animate({"100%": {cx: x, easing: '<', callback: fade(circle, content_id)}});
      }

      // Visible step description
      //   - step: id related to the step description to show
      function show_step(step) {
        container.find('.first-step').hide();
        container.find('.second-step').hide();
        container.find('.third-step').hide();
        container.find(step).show();
      }

      // Animation to first position
      function go_to_first_step(e) {
        moving_circle.attr({cx: 15});
        setTimeout(fade(first_circle, '.first-step'), 0);
        e.preventDefault();       
      }

      // Animation to second position
      function go_to_second_step(e) {
        moving_circle.attr({cx: 15});
        animate(300, second_circle, '.second-step', 0);
        e.preventDefault();
      }

      // Animation to third position
      function go_to_third_step(e) {
        moving_circle.attr({cx: 300});
        animate(615, third_circle, '.third-step', 0);
        e.preventDefault();
      }

  }

  return me;
})();


