import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons as Commons

// Plugin-level IPC surface for the clock. The widget and this service share
// CalendarState, so a binding and a click cannot disagree about what is open.
Scope {
    id: root

    readonly property var targetScreen: {
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++) {
            if (Commons.Util.isRealScreen(screens[i]))
                return screens[i];
        }
        return null;
    }

    function statusJson() {
        return JSON.stringify({
            open: CalendarState.open,
            month: CalendarState.monthKey,
            today: CalendarState.todayKey,
            screen: CalendarState.screen ? String(CalendarState.screen.name || "") : ""
        });
    }

    IpcHandler {
        target: "clock"

        function toggleCalendar(): string {
            CalendarState.toggleCalendar(root.targetScreen);
            return root.statusJson();
        }

        function openCalendar(): string {
            CalendarState.openCalendar(root.targetScreen);
            return root.statusJson();
        }

        function closeCalendar(): string {
            CalendarState.closeCalendar();
            return root.statusJson();
        }

        function previousMonth(): string {
            CalendarState.previousMonth();
            return root.statusJson();
        }

        function nextMonth(): string {
            CalendarState.nextMonth();
            return root.statusJson();
        }

        function status(): string {
            return root.statusJson();
        }
    }
}
