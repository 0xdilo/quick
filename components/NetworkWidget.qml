import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

Rectangle {
    id: root
    implicitWidth: netRow.implicitWidth + 16
    implicitHeight: 28
    radius: 14
    color: netMouse.containsMouse ? Qt.rgba(theme.icon.r, theme.icon.g, theme.icon.b, 0.1) : "transparent"

    Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }

    property string ssid: ""
    property string status: "disconnected"

    function parseNetLine(data) {
        if (data.startsWith("wifi:connected:")) {
            ssid = data.substring(15)
            status = "wifi"
        } else if (data.startsWith("ethernet:connected")) {
            ssid = "Wired"
            status = "ethernet"
        }
    }

    Process {
        id: netWatch
        running: true
        command: ["sh", "-c", "nmcli -t -f type,state,connection dev 2>/dev/null | grep -v disconnected | head -1 && nmcli monitor 2>/dev/null"]
        stdout: SplitParser {
            onRead: data => {
                if (data.startsWith("wifi:") || data.startsWith("ethernet:")) {
                    parseNetLine(data)
                } else if (data.includes("disconnected") || data.includes("Disconnecting")) {
                    ssid = ""
                    status = "disconnected"
                } else if (data.includes("connected")) {
                    netRefresh.running = true
                }
            }
        }
    }

    Process {
        id: netRefresh
        command: ["sh", "-c", "nmcli -t -f type,state,connection dev 2>/dev/null | grep connected | grep -v disconnected | head -1"]
        stdout: SplitParser { onRead: data => parseNetLine(data) }
    }

    Row {
        id: netRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: status === "ethernet" ? "\uf6ff" : "\uf1eb"
            font.family: theme.font
            font.pixelSize: 16
            color: status === "disconnected" ? theme.textMuted : theme.icon
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: ssid || "Offline"
            font.family: theme.font
            font.pixelSize: 12
            font.weight: Font.Medium
            color: netMouse.containsMouse ? theme.iconHover : theme.text
            anchors.verticalCenter: parent.verticalCenter
            visible: ssid.length > 0 || status === "disconnected"

            Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }
        }
    }

    MouseArea {
        id: netMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch("exec nm-connection-editor")

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
            text: "Network Settings"
            font.family: theme.font
            font.pixelSize: 10
            color: theme.text
        }

        Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
    }
}
