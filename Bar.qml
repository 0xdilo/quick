import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "components"

PanelWindow {
    id: bar

    signal launcherRequested()
    signal controlCenterRequested()

    required property var targetScreen
    property string barPosition: "top"

    screen: targetScreen

    property bool isTop: barPosition === "top"

    anchors {
        top: true
        left: true
        right: isTop
        bottom: !isTop
    }

    implicitHeight: 38
    implicitWidth: 48
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    WlrLayershell.exclusiveZone: isTop ? 38 : 48

    QtObject {
        id: theme
        readonly property color bg: Theme.bgAlpha90
        readonly property color bgSoft: Theme.surface
        readonly property color bgCard: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.95)
        readonly property color bgHover: Theme.surfaceHigh
        readonly property color accent: Theme.accent
        readonly property color accentSoft: Theme.secondary
        readonly property color icon: Theme.muted
        readonly property color iconHover: Theme.accent
        readonly property color pink: Theme.accent
        readonly property color pinkSoft: Theme.secondary
        readonly property color text: Theme.foreground
        readonly property color textSoft: Qt.darker(Theme.foreground, 1.05)
        readonly property color textMuted: Theme.muted
        readonly property color success: Theme.success
        readonly property color error: Theme.error
        readonly property string font: Theme.fontFamily
        readonly property int fontSize: 13
        readonly property int fontSizeLg: 15
        readonly property int fontSizeXl: 18
        readonly property int fontSizeIcon: 16
        readonly property int fontSizeIconLg: 18
        readonly property int radius: 14
        readonly property int radiusMd: 10
        readonly property int radiusSm: 6
    }

    Rectangle {
        id: barBg
        anchors.fill: parent
        color: Theme.bgAlpha90

        Rectangle {
            anchors.left: bar.isTop ? parent.left : undefined
            anchors.right: parent.right
            anchors.top: bar.isTop ? undefined : parent.top
            anchors.bottom: bar.isTop ? parent.bottom : parent.bottom
            width: bar.isTop ? undefined : 1
            height: bar.isTop ? 1 : undefined
            color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.06)
        }

        RowLayout {
            visible: bar.isTop
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            RowLayout {
                spacing: 8
                LogoWidget { onClicked: bar.launcherRequested() }
                ClockWidget { onClicked: bar.controlCenterRequested() }
                TrayWidget {}
            }

            WindowTitle {
                Layout.fillWidth: true
                Layout.maximumWidth: 200
            }

            Item { Layout.fillWidth: true }

            WorkspacesWidget {}

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 4

                SystemWidget {}
                NetworkWidget {}
                BluetoothWidget {}
                MediaWidget {}
                VolumeWidget {}
                BatteryWidget {}
            }
        }

        ColumnLayout {
            visible: !bar.isTop
            anchors.fill: parent
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            spacing: 4

            LogoWidget {
                Layout.alignment: Qt.AlignHCenter
                onClicked: bar.launcherRequested()
            }

            ClockWidget {
                Layout.alignment: Qt.AlignHCenter
                vertical: true
                onClicked: bar.controlCenterRequested()
            }

            Item { Layout.fillHeight: true }

            WorkspacesWidget {
                Layout.alignment: Qt.AlignHCenter
                vertical: true
            }

            Item { Layout.fillHeight: true }

            SidebarVolume {}
            SidebarBattery {}
            SidebarTemp {}
        }
    }

    component Tooltip: Rectangle {
        id: tooltip
        property string text: ""
        property Item target: null

        visible: opacity > 0
        opacity: 0
        width: tooltipText.implicitWidth + 16
        height: 26
        radius: 8
        color: Theme.bgAlpha90
        border.width: 1
        border.color: Theme.border

        layer.enabled: true

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: tooltip.text
            font.family: Theme.fontFamily
            font.pixelSize: 11
            color: Theme.foreground
        }

        Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
    }

    component SidebarVolume: Rectangle {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: volMouse.containsMouse ? volLabel.width + 24 : 32
        implicitHeight: 32
        radius: 8
        color: volMouse.containsMouse ? Qt.rgba(theme.icon.r, theme.icon.g, theme.icon.b, 0.15) : "transparent"
        layer.enabled: volMouse.containsMouse

        Behavior on implicitWidth { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }

        property int vol: 0

        Process {
            id: volSubscribe
            running: true
            command: ["pactl", "subscribe"]
            stdout: SplitParser {
                onRead: data => {
                    if (data.includes("sink") && data.includes("change")) volProc.running = true
                }
            }
        }

        Component.onCompleted: volProc.running = true

        Process {
            id: volProc
            command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oE '[0-9]+%' | head -1 | tr -d '%'"]
            stdout: SplitParser { onRead: data => vol = parseInt(data) || 0 }
        }

        Text {
            id: volLabel
            anchors.centerIn: parent
            text: volMouse.containsMouse ? vol + "%" : (vol < 30 ? "\uf026" : (vol < 70 ? "\uf027" : "\uf028"))
            font.family: theme.font
            font.pixelSize: volMouse.containsMouse ? 12 : 16
            font.weight: volMouse.containsMouse ? Font.Medium : Font.Normal
            color: volMouse.containsMouse ? theme.iconHover : theme.icon

            Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            id: volMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }

    component SidebarBattery: Rectangle {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: batMouse.containsMouse ? batLabel.width + 24 : 32
        implicitHeight: 32
        radius: 8
        color: batMouse.containsMouse ? Qt.rgba(theme.icon.r, theme.icon.g, theme.icon.b, 0.15) : "transparent"
        visible: capacity >= 0
        layer.enabled: batMouse.containsMouse

        Behavior on implicitWidth { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }

        property int capacity: -1

        Process {
            id: batWatch
            running: true
            command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null && while inotifywait -qq -e modify /sys/class/power_supply/BAT0/capacity 2>/dev/null; do cat /sys/class/power_supply/BAT0/capacity; done"]
            stdout: SplitParser { onRead: data => capacity = parseInt(data) || -1 }
        }

        Text {
            id: batLabel
            anchors.centerIn: parent
            text: batMouse.containsMouse ? capacity + "%" : (capacity >= 80 ? "\uf240" : (capacity >= 50 ? "\uf242" : (capacity >= 20 ? "\uf243" : "\uf244")))
            font.family: theme.font
            font.pixelSize: batMouse.containsMouse ? 12 : 16
            font.weight: batMouse.containsMouse ? Font.Medium : Font.Normal
            color: batMouse.containsMouse ? theme.iconHover : theme.icon

            Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            id: batMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }

    component SidebarTemp: Rectangle {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: tempMouse.containsMouse ? tempLabel.width + 24 : 32
        implicitHeight: 32
        radius: 8
        color: tempMouse.containsMouse ? Qt.rgba(theme.icon.r, theme.icon.g, theme.icon.b, 0.15) : "transparent"
        layer.enabled: tempMouse.containsMouse

        Behavior on implicitWidth { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }

        property int temp: 0

        Timer {
            interval: 3000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: tempProc.running = true
        }

        Process {
            id: tempProc
            command: ["cat", "/sys/class/thermal/thermal_zone0/temp"]
            stdout: SplitParser { onRead: data => temp = Math.round((parseInt(data) || 0) / 1000) }
        }

        Text {
            id: tempLabel
            anchors.centerIn: parent
            text: tempMouse.containsMouse ? temp + "°" : "\uf06d"
            font.family: theme.font
            font.pixelSize: tempMouse.containsMouse ? 12 : 16
            font.weight: tempMouse.containsMouse ? Font.Medium : Font.Normal
            color: tempMouse.containsMouse ? theme.iconHover : theme.icon

            Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            id: tempMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }
}
