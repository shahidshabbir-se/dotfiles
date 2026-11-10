import QtQuick
import QtTest
import "../../plugins/clock"

TestCase {
    name: "ClockCalendarState"

    function cleanup() {
        CalendarState.closeCalendar();
    }

    function test_toggle_opens_the_current_month() {
        CalendarState.closeCalendar();
        CalendarState.month = new Date(2000, 5, 10, 12);

        CalendarState.toggleCalendar(null);

        compare(CalendarState.open, true);
        const now = new Date();
        compare(CalendarState.month.getFullYear(), now.getFullYear());
        compare(CalendarState.month.getMonth(), now.getMonth());
        compare(CalendarState.month.getDate(), 1);

        CalendarState.toggleCalendar(null);
        compare(CalendarState.open, false);
    }

    function test_month_navigation_crosses_year_boundaries() {
        CalendarState.month = new Date(2026, 0, 1, 12);

        CalendarState.previousMonth();
        compare(CalendarState.month.getFullYear(), 2025);
        compare(CalendarState.month.getMonth(), 11);
        compare(CalendarState.month.getDate(), 1);

        CalendarState.nextMonth();
        CalendarState.nextMonth();
        compare(CalendarState.month.getFullYear(), 2026);
        compare(CalendarState.month.getMonth(), 1);
    }

    function test_today_key_matches_the_calendar_grid() {
        const now = new Date();
        CalendarState.openCalendar(null);

        compare(CalendarState.todayKey, Qt.formatDate(CalendarState.today, "yyyy-MM-dd"));
        verify(CalendarState.cells.some(cell => cell.isToday));
    }
}
