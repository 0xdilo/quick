import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

Rectangle {
    id: root
    implicitWidth: 32
    implicitHeight: 28
    radius: 14
    color: btMouse.containsMouse ? Qt.rgba(theme.icon.r, theme.icon.g, theme.icon.b, 0.1) : "transparent"

    Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }

    property bool powered: false
    property int devices: 0

    function updateBt() { btRefresh.running = true }

    Process {
        id: btWatch
        running: true
        command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo $(bluetoothctl devices Connected 2>/dev/null | wc -l) || echo off; dbus-monitor --system \"type='signal',interface='org.freedesktop.DBus.Properties',path_namespace='/org/bluez'\" 2>/dev/null | while read line; do echo refresh; done"]
        stdout: SplitParser {
            onRead: data => {
                if (data === "off") { powered = false; devices = 0 }
                else if (data === "refresh") { updateBt() }
                else { powered = true; devices = parseInt(data) || 0 }
            }
        }
    }

    Process {
        id: btRefresh
        command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo $(bluetoothctl devices Connected 2>/dev/null | wc -l) || echo off"]
        stdout: SplitParser {
            onRead: data => {
                if (data === "off") { powered = false; devices = 0 }
                else { powered = true; devices = parseInt(data) || 0 }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: "\uf293"
        font.family: theme.font
        font.pixelSize: 18
        color: !powered ? theme.textMuted : (devices > 0 ? theme.icon : theme.textSoft)

        Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        visible: devices > 0
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 2
        width: 14
        height: 14
        radius: 7
        color: theme.icon

        Text {
            anchors.centerIn: parent
            text: devices.toString()
            font.family: theme.font
            font.pixelSize: 9
            font.weight: Font.Bold
            color: theme.bg
        }
    }

    MouseArea {
        id: btMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) Hyprland.dispatch("exec blueman-manager")
            else {
                Hyprland.dispatch("exec rfkill toggle bluetooth")
                updateBt()
            }
        }

        onContainsMouseChanged: {
            if (containsMouse) tooltipTimer.start()
            else { tooltipTimer.stop(); tooltip.opacity = 0 }
        }
    }

    Timer {
        id: tooltipTimer
        interval: 500
        onTriggered: tooltip.opacity = 1
    }

    Rectangle {
        id: tooltip
        x: (parent.width - width) / 2
        y: parent.height + 6
        visible: opacity > 0
        opacity: 0
        width: tooltipText.implicitWidth + 14
        height: 24
        radius: 6
        color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.95)
        border.width: 1
        border.color: Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.08)

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: "Click: Manager • Right: Toggle"
            font.family: theme.font
            font.pixelSize: 10
            color: theme.text
        }

        Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
    }
}
