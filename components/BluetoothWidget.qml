import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

Rectangle {
    id: root
    implicitWidth: 32
    implicitHeight: 28
    radius: 14
    color: btMouse.containsMouse ? Qt.rgba(theme.lavender.r, theme.lavender.g, theme.lavender.b, 0.15) : "transparent"

    property bool powered: false
    property int devices: 0

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: btProc.running = true
    }

    Process {
        id: btProc
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
        color: !powered ? theme.textMuted : (devices > 0 ? theme.lavender : theme.textSoft)
    }

    Rectangle {
        visible: devices > 0
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 2
        width: 14
        height: 14
        radius: 7
        color: theme.lavender

        Text {
            anchors.centerIn: parent
            text: devices.toString()
            font.family: theme.font
            font.pixelSize: 9
            font.weight: Font.Bold
            color: "#ffffff"
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
            else Hyprland.dispatch("exec rfkill toggle bluetooth")
        }
    }
}
