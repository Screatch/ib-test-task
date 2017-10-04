Highcharts.dateFormats = {
    W: function (timestamp) {
        var date = new Date(timestamp),
            day = date.getUTCDay() == 0 ? 7 : date.getUTCDay(),
            dayNumber;
        date.setDate(date.getUTCDate() + 4 - day);
        dayNumber = Math.floor((date.getTime() - new Date(date.getUTCFullYear(), 0, 1, -6)) / 86400000);
        return 1 + Math.floor(dayNumber / 7);

    }
}

document.addEventListener("turbolinks:load", function() {

    ['historical','forecast'].forEach(function(key){
        // Create the chart
        Highcharts.chart(key+'-chart-container', {

            chart: {
                type: 'line'
            },
            title: {
                text: 'Monthly Average Temperature'
            },
            subtitle: {
                text: 'Source: WorldClimate.com'
            },
            xAxis: {
                categories: JSON.parse($('#'+key+'_weeks_array').val())
            },
            yAxis: {
                title: {
                    text: 'Temperature (°C)'
                }
            },
            plotOptions: {
                line: {
                }
            },
            series: [{
                name: 'London',
                data: JSON.parse($('#'+key+'_target_amount_array').val())
            }]
        });
    });
});