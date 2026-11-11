pragma Singleton

import QtQuick
import "Calendar.js" as Calendar

// Calendar popup state shared by the clock widget, the popup, and the clock
// IPC target. Opening resets the month to the current one; navigation changes
// `month` until the popup closes. An Item host lets the singleton own a Timer.
Item {
    id: root

    property bool open: false
    property date month: Calendar.startOfMonth(new Date())
    property date today: new Date()
    property var screen: null

    readonly property string monthLabel: Calendar.monthLabel(root.month)
    readonly property string monthKey: Calendar.monthKey(root.month)
    readonly property string todayKey: Calendar.dateKey(root.today)
    readonly property var weekdayNames: Calendar.WEEKDAYS
    readonly property var cells: Calendar.buildGrid(root.month, root.today)

    function openCalendar(targetScreen) {
        root.screen = targetScreen || null;
        root.today = new Date();
        root.month = Calendar.startOfMonth(root.today);
        root.open = true;
    }

    function closeCalendar() {
        root.open = false;
    }

    function toggleCalendar(targetScreen) {
        if (root.open)
            root.closeCalendar();
        else
            root.openCalendar(targetScreen);
    }

    function previousMonth() {
        root.month = Calendar.shiftMonth(root.month, -1);
    }

    function nextMonth() {
        root.month = Calendar.shiftMonth(root.month, 1);
    }

    // Keep "today" correct if the popup stays open across midnight.
    Timer {
        interval: 60000
        running: root.open
        repeat: true
        onTriggered: root.today = new Date()
    }
}
