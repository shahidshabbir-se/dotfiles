// Pure calendar-grid logic for the clock popup. Kept free of Qt imports so the
// same functions run under node in tests/. Grids are Monday-first so the week
// reads like a work calendar (`Mon` ... `Sun`).

var WEEKDAYS = [ "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" ];
var MONTHS = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
];
var CELL_COUNT = 42;

function pad2(value) {
    return value < 10 ? "0" + value : "" + value;
}

function dateKey(value) {
    var date = new Date(value.getTime());
    return date.getFullYear() + "-"
        + pad2(date.getMonth() + 1) + "-"
        + pad2(date.getDate());
}

function monthKey(value) {
    var date = new Date(value.getTime());
    return date.getFullYear() + "-" + pad2(date.getMonth() + 1);
}

function startOfMonth(value) {
    return new Date(value.getFullYear(), value.getMonth(), 1, 12, 0, 0, 0);
}

function shiftMonth(value, delta) {
    return new Date(value.getFullYear(), value.getMonth() + delta, 1, 12, 0, 0, 0);
}

function monthLabel(value) {
    return MONTHS[value.getMonth()] + " " + value.getFullYear();
}

function daysInMonth(value) {
    return new Date(value.getFullYear(), value.getMonth() + 1, 0).getDate();
}

// Monday-first index of the first day in the month (0 = Monday).
function leadingCells(value) {
    return (startOfMonth(value).getDay() + 6) % 7;
}

// Six fixed rows keep the popup a stable size while moving between months.
// Cells outside the displayed month are still returned so the grid can dim
// them instead of leaving holes.
function buildGrid(monthValue, todayValue) {
    var month = startOfMonth(monthValue);
    var today = dateKey(todayValue);
    var leading = leadingCells(month);
    var cells = [];

    for (var index = 0; index < CELL_COUNT; index++) {
        var cellDate = new Date(
            month.getFullYear(),
            month.getMonth(),
            1 + index - leading,
            12, 0, 0, 0
        );
        var key = dateKey(cellDate);
        cells.push({
            key: key,
            day: cellDate.getDate(),
            inMonth: cellDate.getMonth() === month.getMonth()
                && cellDate.getFullYear() === month.getFullYear(),
            isToday: key === today
        });
    }

    return cells;
}
