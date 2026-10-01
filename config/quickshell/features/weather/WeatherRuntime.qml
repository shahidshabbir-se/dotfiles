pragma Singleton

import QtQuick

// Hands the weather facade to the panel wherever the panel is instantiated.
//
// The panel is hosted by the bar (like the calendar popup) so it can be anchored
// to the clock with PopupWindow — Quickshell has no item-to-screen mapping, so a
// feature-owned window would have to guess the clock's screen position. The bar
// cannot be given the facade directly, so the facade registers itself here and
// the panel picks it up.
QtObject {
    property var facade: null

    function attach(instance) {
        facade = instance
    }

    function detach(instance) {
        if (facade === instance)
            facade = null
    }
}
