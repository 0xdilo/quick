import QtQuick
import Quickshell.Io

Rectangle {
    id: root
    implicitWidth: visible ? batRow.implicitWidth + 18 : 0
    implicitHeight: 28
    radius: 14
    color: charging ? Qt.rgba(theme.mint.r, theme.mint.g, theme.mint.b, 0.2) : "transparent"
    visible: capacity >= 0

    property int capacity: -1
    property string status: ""
    property bool charging: status === "Charging" || status === "Full"

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: batProc.running = true
    }

    Process {
        id: batProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null"]
        stdout: SplitParser {
            onRead: data => {
                capacity = parseInt(data) || -1
                if (capacity >= 0) statusProc.running = true
            }
        }
        onExited: (code, st) => { if (code !== 0) capacity = -1 }
    }

    Process {
        id: statusProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/status 2>/dev/null"]
        stdout: SplitParser { onRead: data => status = data || "" }
    }

    property color batColor: charging ? theme.mint : (capacity <= 20 ? theme.pink : theme.text)

    Row {
        id: batRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: charging ? "\uf0e7" : (capacity >= 80 ? "\uf240" : (capacity >= 50 ? "\uf242" : (capacity >= 20 ? "\uf243" : "\uf244")))
            font.family: theme.font
            font.pixelSize: 18
            color: batColor
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: capacity + "%"
            font.family: theme.font
            font.pixelSize: 13
            font.weight: Font.Medium
            color: batColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
