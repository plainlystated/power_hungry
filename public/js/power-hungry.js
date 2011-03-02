function sensorGraph(slug, name, amperage_amplitude, voltages, amps) {
  $("#now-" + slug).click(function() {
    $.plot($("#holder"),
      [
        { data: voltages, label: "Voltage" },
        { data: amps, label: "Amps", yaxis: 2 },
      ], {
        xaxis: { ticks: [] },
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
        legend: { position: 'sw' }
      });
      return false;
    });
}
