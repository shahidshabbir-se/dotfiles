import QtQuick
import Quickshell
import Quickshell.Io
import "RemoteSession.js" as RemoteSession

Scope {
    id: root

    // logind is authoritative when it answers, but the environment is still
    // checked first so an SSH session is reported even if logind is slow or
    // unavailable (for example inside a nested sandbox).
    property var logind: ({})

    readonly property string sessionId: root.env("XDG_SESSION_ID")

    readonly property var facts: ({
        sshConnection: root.env("SSH_CONNECTION"),
        sshClient: root.env("SSH_CLIENT"),
        sshTty: root.env("SSH_TTY"),
        remoteFlag: root.logind.Remote || "",
        sessionId: root.sessionId,
        sessionType: root.env("XDG_SESSION_TYPE") || root.logind.Type || "",
        sessionClass: root.env("XDG_SESSION_CLASS") || root.logind.Class || "",
        service: root.logind.Service || "",
        display: root.env("DISPLAY"),
        waylandDisplay: root.env("WAYLAND_DISPLAY"),
        tty: root.env("TTY")
    })

    readonly property var classification: RemoteSession.classify(root.facts)
    readonly property bool remote: root.classification.remote
    readonly property string reason: root.classification.reason
    readonly property string summary: RemoteSession.summary(root.classification)

    function env(name) {
        const value = Quickshell.env(name);
        return value === undefined || value === null ? "" : String(value);
    }

    function probeNow() {
        if (root.sessionId.length === 0)
            return;
        if (logindProbe.running)
            return;
        logindProbe.running = true;
    }

    function statusJson() {
        return JSON.stringify(RemoteSession.statusObject(root.facts, root.classification));
    }

    Component.onCompleted: root.probeNow()

    Process {
        id: logindProbe

        running: false
        command: [
            "loginctl", "show-session", root.sessionId,
            "-p", "Remote", "-p", "Type", "-p", "Class", "-p", "Service"
        ]

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.logind = RemoteSession.parseLogind(text)
        }
    }

    // Session type and remote state can change during a reconnect. Poll at a
    // low rate instead of treating the launch-time answer as permanent.
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.probeNow()
    }

    IpcHandler {
        target: "remoteSession"

        function status(): string {
            return root.statusJson();
        }

        function isRemote(): string {
            return root.remote ? "yes" : "no";
        }

        function summary(): string {
            return root.summary;
        }

        function refresh(): void {
            root.probeNow();
        }
    }
}
