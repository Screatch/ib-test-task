String.prototype.capitalize = function () {

    return this.toLowerCase().replace(/\b[a-z]/g, function (letter) {
        return letter.toUpperCase();
    });
};

document.addEventListener("turbolinks:load", function() {

    ['historical','forecast'].forEach(function(key){
        // Create the chart
        Highcharts.chart(key+'-chart-container', {

            chart: {
                type: 'line'
            },
            title: {
                text: key.capitalize()+' Currency Exchange Data'
            },
            subtitle: {
                text: 'Source: fixer.io'
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