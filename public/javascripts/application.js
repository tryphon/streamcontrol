// Disable Stream#mount_point in /streams/_form for shoutcast servers
Event.observe(window, "load", function() {
  var toggle_stream_mount_point = function(enable) {
    $$('input[name="stream[mount_point]"]').each(function(input) {
      console.log(input);
      if (enable) {
        input.enable();
      } else {
        input.disable();
      };
    });
  };

  $$('select[name="stream[server_type]"]').each(function(select) {
    console.log(select.value);
    toggle_stream_mount_point(select.value != "shoutcast");
    Event.observe(select, 'change', function() {
      toggle_stream_mount_point(select.value != "shoutcast");
    });
  });
});
