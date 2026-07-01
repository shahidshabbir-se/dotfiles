//@ pragma Env QT_SCALE_FACTOR=1.0
//@ pragma Env QS_NO_RELOAD_POPUP=1
import Quickshell
import Quickshell.Wayland
import QtQuick
import "components" as Components

Scope {
  Components.DesktopVisualizer {}

  Connections {
    target: Quickshell

    function onReloadCompleted(): void {
      Quickshell.inhibitReloadPopup()
    }

    function onReloadFailed(error: string): void {
      Quickshell.inhibitReloadPopup()
    }
  }
}
