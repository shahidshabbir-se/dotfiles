import QtQuick
import QtTest
import "../../plugins/notifications"

TestCase {
    name: "NotificationStore"

    function test_center_and_unread() {
        NotificationStore.clear();
        NotificationStore.closeCenter();
        compare(NotificationStore.unread, 0);
        compare(NotificationStore.centerOpen, false);

        NotificationStore.record({ appName: "A", summary: "S", body: "B" });
        compare(NotificationStore.unread, 1);
        compare(NotificationStore.history.length, 1);

        NotificationStore.toggleCenter();
        compare(NotificationStore.centerOpen, true);
        compare(NotificationStore.unread, 0);
        compare(NotificationStore.history.length, 1);

        NotificationStore.toggleCenter();
        compare(NotificationStore.centerOpen, false);
    }

    function test_dnd_keeps_history() {
        NotificationStore.clear();
        NotificationStore.closeCenter();
        NotificationStore.toggleDnd();
        compare(NotificationStore.dnd, true);

        NotificationStore.record({ appName: "Quiet", summary: "S" });
        compare(NotificationStore.unread, 1);
        compare(NotificationStore.history[0].appName, "Quiet");

        NotificationStore.toggleDnd();
        compare(NotificationStore.dnd, false);
        NotificationStore.clear();
    }

    function test_remove_entry() {
        NotificationStore.clear();
        NotificationStore.record({ appName: "one", summary: "1" });
        NotificationStore.record({ appName: "two", summary: "2" });
        const firstId = NotificationStore.history[0].id;
        NotificationStore.remove(firstId);
        compare(NotificationStore.history.length, 1);
        compare(NotificationStore.history[0].appName, "one");
        NotificationStore.clear();
    }
}
