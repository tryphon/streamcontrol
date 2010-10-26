Event.observe(window, "load", function() {
  // Disable Stream#mount_point in /streams/_form for shoutcast servers
  var toggle_stream_mount_point = function(enable) {
    $$('input[name="stream[mount_point]"]').each(function(input) {
      if (enable) {
        input.enable();
      } else {
        input.disable();
      };
    });
  };

  $$('select[name="stream[server_type]"]').each(function(select) {
    toggle_stream_mount_point(select.value != "shoutcast");
    Event.observe(select, 'change', function() {
      toggle_stream_mount_point(select.value != "shoutcast");
    });
  });

  // Disable Stream#mount_point in /streams/_form for shoutcast servers
  var toggle_stream_bitrate_quality = function(attribute, enable) {
    $$('[name="stream[' + attribute + ']"]').each(function(input) {
      if (enable) {
        console.log("show " + attribute);
        input.up().show();
      } else {
        console.log("hide " + attribute);
        input.up().hide();
      };
    });
  };

  $$('input[name="stream[format]"]').each(function(radio) {
    var requires_bitrate = radio.getAttribute("data-requires-bitrate") == "true";
    var requires_quality = radio.getAttribute("data-requires-quality") == "true";

    if (radio.checked) {
      toggle_stream_bitrate_quality("bitrate", requires_bitrate);
      toggle_stream_bitrate_quality("quality", requires_quality);
    }
                                        
    Event.observe(radio, 'change', function() {
      toggle_stream_bitrate_quality("bitrate", requires_bitrate);
      toggle_stream_bitrate_quality("quality", requires_quality);
    });
  });
});
