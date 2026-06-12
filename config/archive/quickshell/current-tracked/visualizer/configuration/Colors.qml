pragma Singleton
import QtQuick

QtObject {
    readonly property QtObject matugen: MatugenColors {}
    readonly property color visualizerColor: matugen.primary
}
