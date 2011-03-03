function formatWithMicroseconds(time, axis) {
  date = new Date(time);
  hour = date.getHours();
  min = date.getMinutes();
  if (min < 10) {
    min = "0" + min;
  }
  seconds = date.getSeconds();
  if (seconds < 10) {
    seconds = "0" + seconds;
  }

  // timestamps don't store microseconds, so we stored them in the milliseconds spot
  milliseconds = date.getMilliseconds();

  return hour + ":" + min + ":" + seconds + " + " + milliseconds + "&micro;sec" ;
}

function sensorGraph(slug, name, amperage_amplitude, voltages, amps) {
  $("#now-" + slug).click(function() {
    showDetails(slug, name);
    $.plot($("#holder"),
      [
        { data: voltages, label: "Voltage" },
        { data: amps, label: "Amps", yaxis: 2 },
      ], {
        xaxis: { mode: 'time', tickFormatter: formatWithMicroseconds, ticks: [voltages[3][0], voltages[7][0], voltages[11][0], voltages[15][0]] },
        yaxis: { min: -200, max: 200, tickFormatter: function(val, axis) { return val.toFixed(axis.tickDecimals) + " V"} },
        y2axis: { min: -amperage_amplitude, max: amperage_amplitude, tickFormatter: function(val, axis) { return val.toFixed(axis.tickDecimals) + " A"; } },
        legend: { position: 'sw' }
      }
    );
    return false;
  });
}

function timeGraph(id, sensor_list, watt_hours) {
  $("#" + id).click(function() {
    showDetails(id, "Past " + id);
    var lines = [];

    for (sensor_data in sensor_list) {
      lines.push({ data: sensor_list[sensor_data][2], label: sensor_list[sensor_data][1] });
    }
    lines.push({ data: watt_hours, label: "Watt Hours", yaxis: 2, lines: { lineWidth: 5 } });

    $.plot($("#holder"),
      lines,
      {
        xaxis: { mode: 'time' },
        yaxis: { min: 0, tickFormatter: function(val, axis) { return val.toFixed(axis.tickDecimals) + " W"; } },
        y2axis: { min: 0, tickFormatter: function(val, axis) { return val.toFixed(axis.tickDecimals) + " W Hr"; } },
        legend: { position: 'nw' }
      });
      return false;
    });
}

function showDetails(slug, name) {
  $('.graph-details').each(function(i) {
    $(this).hide();
  });
  $('#graph-details-' + slug).show();

  $('#current-graph-name').text(name);
}
