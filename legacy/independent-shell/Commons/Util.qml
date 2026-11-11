pragma Singleton

import QtQuick

QtObject {
    function isRealScreen(screen) {
        if (!screen)
            return false;
        const name = String(screen.name || "");
        if (name.length === 0 || name === "FALLBACK")
            return false;
        return name.toLowerCase().indexOf("placeholder") < 0;
    }

    function clockText(date, format) {
        return Qt.formatDateTime(date, format || "ddd HH:mm");
    }
}
