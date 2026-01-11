import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import "components"

ShellRoot {
    id: shell

    property bool hasScreens: Quickshell.screens.length > 0
    property string activeMonitor: hasScreens ? (Hyprland.focusedMonitor?.name ?? "") : ""

    IpcHandler {
        target: "shell"

        function toggleLauncherIpc() { shell.toggleLauncher() }
        function toggleClipboardIpc() { shell.toggleClipboard() }
        function toggleToolsIpc() { shell.toggleTools() }
        function toggleControlCenterIpc() { shell.toggleControlCenter() }
        function toggleBarPositionIpc() { shell.toggleBarPosition() }
    }

    property bool launcherOpen: false
    property bool clipboardOpen: false
    property bool toolsOpen: false
    property bool controlCenterOpen: false
    property string barPosition: "top"

    function toggleBarPosition() {
        barPosition = barPosition === "top" ? "left" : "top"
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            Launcher {
                id: launcherInstance
                required property var modelData
                screen: modelData

                property bool shouldShow: shell.launcherOpen && modelData.name === shell.activeMonitor

                onShouldShowChanged: {
                    if (shouldShow) show()
                    else hide()
                }

                onClosed: shell.launcherOpen = false
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            ClipboardManager {
                id: clipboardInstance
                required property var modelData
                screen: modelData

                property bool shouldShow: shell.clipboardOpen && modelData.name === shell.activeMonitor

                onShouldShowChanged: {
                    if (shouldShow) show()
                    else hide()
                }

                onClosed: shell.clipboardOpen = false
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            ToolsMenu {
                id: toolsInstance
                required property var modelData
                screen: modelData

                property bool shouldShow: shell.toolsOpen && modelData.name === shell.activeMonitor

                onShouldShowChanged: {
                    if (shouldShow) show()
                    else hide()
                }

                onClosed: shell.toolsOpen = false
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            ControlCenter {
                id: controlInstance
                required property var modelData
                screen: modelData

                property bool shouldShow: shell.controlCenterOpen && modelData.name === shell.activeMonitor

                onShouldShowChanged: {
                    if (shouldShow) show()
                    else hide()
                }

                onClosed: shell.controlCenterOpen = false
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            Bar {
                required property var modelData
                targetScreen: modelData
                barPosition: shell.barPosition
                onLauncherRequested: shell.toggleLauncher()
                onControlCenterRequested: shell.toggleControlCenter()
            }
        }
    }

    property int osdVolume: 50
    property int osdBrightness: 50
    property string osdType: "volume"
    property bool osdVisible: false
    property int lastVolume: -1
    property int lastBrightness: -1

    Process {
        id: volumeSubscribe
        running: true
        command: ["pactl", "subscribe"]
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("sink") && data.includes("change")) {
                    getVolumeProc.running = true
                }
            }
        }
    }

    Process {
        id: getVolumeProc
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oE '[0-9]+%' | head -1 | tr -d '%'"]
        stdout: SplitParser {
            onRead: data => {
                var newVolume = parseInt(data) || 0
                if (newVolume !== shell.lastVolume && shell.lastVolume !== -1) {
                    shell.osdVolume = newVolume
                    shell.osdType = "volume"
                    shell.osdVisible = true
                    hideTimer.restart()
                }
                shell.lastVolume = newVolume
            }
        }
    }

    property int maxBrightness: 30720

    Process {
        id: brightnessWatch
        running: true
        command: ["sh", "-c", "cat /sys/class/backlight/intel_backlight/brightness && while inotifywait -qq -e modify /sys/class/backlight/intel_backlight/brightness; do cat /sys/class/backlight/intel_backlight/brightness; done"]
        stdout: SplitParser {
            onRead: data => {
                var current = parseInt(data) || 0
                var percent = Math.round(current * 100 / shell.maxBrightness)
                if (percent !== shell.lastBrightness && shell.lastBrightness !== -1) {
                    shell.osdBrightness = percent
                    shell.osdType = "brightness"
                    shell.osdVisible = true
                    hideTimer.restart()
                }
                shell.lastBrightness = percent
            }
        }
    }

    Component.onCompleted: getVolumeProc.running = true

    IpcHandler {
        target: "osd"

        function show() {
            shell.osdVisible = true
            hideTimer.restart()
        }

        function hide() {
            shell.osdVisible = false
        }
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: osdVisible = false
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: osdWindow
                required property var modelData
                screen: modelData

                property bool shouldShow: modelData.name === shell.activeMonitor && shell.osdVisible

                visible: shouldShow

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay

                Rectangle {
                    id: osdCard
                    width: 280
                    height: 56
                    radius: 28
                    color: Theme.background
                    border.width: 1
                    border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)
                    layer.enabled: true
                    layer.smooth: true

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 80

                    opacity: osdWindow.shouldShow ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 60; easing.type: Easing.OutCubic }
                    }

                    property bool isVolume: shell.osdType === "volume"
                    property int value: isVolume ? shell.osdVolume : shell.osdBrightness

                    Row {
                        anchors.centerIn: parent
                        spacing: 14

                        Text {
                            text: {
                                if (osdCard.isVolume) {
                                    return shell.osdVolume === 0 ? "\uf026" : (shell.osdVolume < 50 ? "\uf027" : "\uf028")
                                } else {
                                    return shell.osdBrightness < 30 ? "\uf185" : (shell.osdBrightness < 70 ? "\uf185" : "\uf185")
                                }
                            }
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                            color: Theme.accent
                            opacity: osdCard.isVolume ? 1 : (shell.osdBrightness < 30 ? 0.5 : 1)
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item {
                            width: 160
                            height: 6
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                anchors.fill: parent
                                radius: 3
                                color: Theme.surface
                            }

                            Rectangle {
                                id: barFill
                                width: parent.width * osdCard.value / 100
                                height: parent.height
                                radius: 3
                                color: Theme.accent

                                Behavior on width { NumberAnimation { duration: 50; easing.type: Easing.OutCubic } }
                            }
                        }

                        Text {
                            text: osdCard.value + "%"
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: Theme.foreground
                            width: 36
                            horizontalAlignment: Text.AlignRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }

    function toggleLauncher() {
        shell.launcherOpen = !shell.launcherOpen
    }

    function toggleClipboard() {
        shell.clipboardOpen = !shell.clipboardOpen
    }

    function toggleTools() {
        shell.toolsOpen = !shell.toolsOpen
    }

    function toggleControlCenter() {
        shell.controlCenterOpen = !shell.controlCenterOpen
    }

    property var dnsRequests: []
    property bool dnsMonitoring: false

    function startDnsMonitor() {
        dnsRequests = []
        dnsMonitoring = true
        dnsProc.running = true
    }

    function stopDnsMonitor() {
        dnsMonitoring = false
        dnsProc.running = false
    }

    Process {
        id: dnsProc
        command: ["tshark", "-l", "-i", "any", "-Y", "dns.flags.response == 0", "-T", "fields", "-e", "dns.qry.name"]
        stdout: SplitParser {
            onRead: data => {
                var domain = data.trim()
                if (domain && domain.length > 0) {
                    var entry = {
                        time: new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss"),
                        domain: domain
                    }
                    var list = shell.dnsRequests.slice()
                    list.unshift(entry)
                    if (list.length > 100) list.pop()
                    shell.dnsRequests = list
                }
            }
        }
    }
}
