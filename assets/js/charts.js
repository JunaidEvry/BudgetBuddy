$(document).ready(function() {
    fetchWeeklyData(currentWeek);
    fetchYearlyData();
    $('#yearSelect').val(currentDate.getFullYear()); // Set the default year to the current year
    // Initialize date range and fetch data
    updateMonthDate(currentDate);
});

// Set up the current date and week
var currentDate = new Date();
var currentWeek = new Date();
for (let i = currentDate.getFullYear(); i >= 2000; i--) {
    console.log(i);
    $('#yearSelect').append(`<option value=${i}>${i}</option>`);
}

// Adjust the currentWeek to the most recent Monday
currentWeek = getMonday(currentWeek);
var chart;

// Event listener for the month select dropdown
$('#monthSelect').on('change', function() {
    var selectedMonth = $(this).val();
    var selectedYear = $('#yearSelect').val();
    var selectedType = $('#typeSelect').val();
    fetchMonthlyData(selectedMonth, selectedYear, selectedType);
    currentDate.setMonth(selectedMonth - 1);
});

// Event listener for the year select dropdown
$('#yearSelect').on('change', function() {
    var selectedMonth = $('#monthSelect').val();
    var selectedYear = $(this).val();
    var selectedType = $('#typeSelect').val();
    fetchMonthlyData(selectedMonth, selectedYear, selectedType);
});

// Event listener for the type select dropdown
$('#typeSelect').on('change', function() {
    var selectedMonth = $('#monthSelect').val();
    var selectedYear = $('#yearSelect').val();
    var selectedType = $(this).val();
    fetchMonthlyData(selectedMonth, selectedYear, selectedType);
});

// Event listener for the previous month button
$('#prevMonth').on('click', function() {
    currentDate = adjustMonth(currentDate, -1);
    $('#monthSelect').val(currentDate.getMonth() + 1);
    $('#yearSelect').val(currentDate.getFullYear());
    fetchMonthlyData(currentDate.getMonth() + 1, currentDate.getFullYear(), $('#typeSelect').val());
});

// Event listener for the next month button
$('#nextMonth').on('click', function() {
    currentDate = adjustMonth(currentDate, 1);
    $('#monthSelect').val(currentDate.getMonth() + 1);
    $('#yearSelect').val(currentDate.getFullYear());
    fetchMonthlyData(currentDate.getMonth() + 1, currentDate.getFullYear(), $('#typeSelect').val());
    // updateDateRange(currentDate);
});

// Format date to a readable string with the day suffix
function formatDate(date) {
    var day = date.getDate();
    var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    var month = monthNames[date.getMonth()];
    var year = date.getFullYear();

    // Get the day suffix
    var daySuffix;
    if (day % 10 === 1 && day !== 11) {
        daySuffix = "st";
    } else if (day % 10 === 2 && day !== 12) {
        daySuffix = "nd";
    } else if (day % 10 === 3 && day !== 13) {
        daySuffix = "rd";
    } else {
        daySuffix = "th";
    }

    return `${day}${daySuffix} ${month} ${year}`;
}

// Fetch and render weekly data
function fetchWeeklyData(weekStart) {
    var weekEnd = new Date(weekStart);
    weekEnd.setDate(weekEnd.getDate() - 7);

    // Set the date range text
    $('#dateRange').text(''+formatDate(weekEnd)+' - '+formatDate(weekStart)+'');

    $.ajax({
        url: '../cfc/controllers/chartsController.cfc?method=getWeeklyData',
        method: 'GET',
        data: { weekStart: weekStart.toISOString() },
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                renderBarChart(response.data);
            } else {
                $("#errorMessage").text(response.message).show();
                setTimeout(() => {
                    $("#errorMessage").fadeOut(1000);
                }, 1000);
            }
        },
        error: function(xhr, status, error) {
            $("#errorMessage").text("Error fetching weekly data " + error).show();
            setTimeout(() => {
                $("#errorMessage").fadeOut(1000);
            }, 1000);
        }
    });
}

// Render bar chart with weekly data
function renderBarChart(data) {
    var days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    var expenses = data.expenses;
    var income = data.income;

    echarts.init(document.querySelector("#barChart")).setOption({
        xAxis: {
            type: 'category',
            data: days
        },
        yAxis: {
            type: 'value'
        },
        legend: {
            data: ['Expenses', 'Income']
        },
        series: [
            {
                name: 'Expenses',
                data: expenses,
                type: 'bar',
                itemStyle: {
                    color: 'red'
                }
            },
            {
                name: 'Income',
                data: income,
                type: 'bar',
                itemStyle: {
                    color: 'green'
                }
            }
        ]
    });
}

// Adjust week by the specified offset
function adjustWeek(date, offset) {
    var newDate = new Date(date);
    newDate.setDate(newDate.getDate() + offset * 7);
    return newDate;
}

// Event listener for the previous week button
$('#prevWeek').on('click', function() {
    currentWeek = adjustWeek(currentWeek, -1);
    fetchWeeklyData(currentWeek);
});

// Event listener for the next week button
$('#nextWeek').on('click', function() {
    currentWeek = adjustWeek(currentWeek, 1);
    fetchWeeklyData(currentWeek);
});

// Fetch and render yearly data
function fetchYearlyData() {
    $.ajax({
        url: '../cfc/controllers/chartsController.cfc?method=getYearlyData',
        method: 'GET',
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                renderLineChart(response.data);
            } else {
                $("#errorMessage").text("Failed to fetch yearly data " + error).show();
                setTimeout(() => {
                    $("#errorMessage").fadeOut(1000);
                }, 1000);
            }
        },
        error: function(xhr, status, error) {
            $("#errorMessage").text("Failed to fetch yearly data " + error).show();
            setTimeout(() => {
                $("#errorMessage").fadeOut(1000);
            }, 1000);
        }
    });
}

// Render line chart with yearly data
function renderLineChart(data) {
    var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    var income = data.income;
    var expense = data.expense;

    var options = {
        series: [
            {
                name: 'Income',
                data: income
            },
            {
                name: 'Expenses',
                data: expense
            }
        ],
        chart: {
            height: 350,
            type: 'line',
            zoom: {
                enabled: false
            }
        },
        dataLabels: {
            enabled: false
        },
        stroke: {
            curve: 'straight'
        },
        grid: {
            row: {
                colors: ['#f3f3f3', 'transparent'],
                opacity: 0.5
            }
        },
        xaxis: {
            categories: months
        },
        tooltip: {
            shared: true,
            intersect: false
        }
    };

    var chart = new ApexCharts(document.querySelector("#lineChart"), options);
    chart.render();
}

// Get the Monday of the current week
function getMonday(d) {
    d = new Date(d);
    var day = d.getDay(),
        diff = d.getDate() - day + (day == 0 ? -6 : 1); // Adjust when day is Sunday
    return new Date(d.setDate(diff));
}

// Format date to "Month Year"
function formatMonthYear(date) {
    var options = { year: 'numeric', month: 'long' };
    return new Intl.DateTimeFormat('en-US', options).format(date);
}

// Fetch and render monthly data
function fetchMonthlyData(month, year, type) {
    $.ajax({
        url: '../cfc/controllers/chartsController.cfc?method=getMonthlyData',
        method: 'GET',
        data: { month: month, year: year, type: type },
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                renderPieChart(response.data);
            } else {
                $("#errorMessage").text("Failed to fetch monthly data " + error).show();
                setTimeout(() => {
                    $("#errorMessage").fadeOut(1000);
                }, 1000);
            }
        },
        error: function(xhr, status, error) {
            $("#errorMessage").text("Failed to fetch monthly data " + error).show();
            setTimeout(() => {
                $("#errorMessage").fadeOut(1000);
            }, 1000);
        }
    });
}

// Render pie chart with monthly data
function renderPieChart(data) {
    var categories = Object.keys(data);
    var amounts = Object.values(data);
    var options = {
        series: amounts,
        chart: {
            height: 350,
            type: 'pie',
            toolbar: {
                show: true
            }
        },
        labels: categories
    };

    if (chart) {
        chart.updateOptions(options);
        chart.updateSeries(amounts);
    } else {
        chart = new ApexCharts(document.querySelector("#pieChart"), options);
        chart.render();
    }
}

// Update month and year dropdowns and fetch data for the selected month
function updateMonthDate(date) {
    $('#monthSelect').val(date.getMonth() + 1);
    $('#yearSelect').val(date.getFullYear());
    $('#typeSelect').val('Income'); // Default to 'Income'
    fetchMonthlyData(date.getMonth() + 1, date.getFullYear(), 'Income');
}

// Adjust month by the specified offset
function adjustMonth(date, offset) {
    var newDate = new Date(date);
    newDate.setMonth(newDate.getMonth() + offset);
    return newDate;
}