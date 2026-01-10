import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Row {
    spacing: 6

    property int cpu: 0
    property real mem: 0
    property int temp: 0

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
            tempProc.running = true
        }
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "awk '/^cpu / {print int(($2+$4)*100/($2+$4+$5))}' /proc/stat"]
        stdout: SplitParser { onRead: data => cpu = parseInt(data) || 0 }
    }

    Process {
        id: memProc
        command: ["sh", "-c", "free -b | awk '/Mem:/ {printf \"%.1f\", $3/1073741824}'"]
        stdout: SplitParser { onRead: data => mem = parseFloat(data) || 0 }
    }

    Process {
        id: tempProc
        command: ["sh", "-c", "sensors 2>/dev/null | grep -E 'Package id|Tctl|Core 0:' | head -1 | grep -oE '[0-9]+\\.[0-9]+' | head -1 | cut -d. -f1"]
        stdout: SplitParser { onRead: data => temp = parseInt(data) || 0 }
    }

    Stat { icon: "\uf06d"; value: temp + "°" }
    Stat { icon: "\uf085"; value: cpu + "%" }
    Stat { icon: "\uf1c0"; value: mem.toFixed(1) + "G" }

    component Stat: Rectangle {
        property string icon
        property string value

        implicitWidth: statRow.implicitWidth + 14
        implicitHeight: 28
        radius: 14
        color: statMouse.containsMouse ? Qt.rgba(theme.icon.r, theme.icon.g, theme.icon.b, 0.1) : "transparent"

        Row {
            id: statRow
            anchors.centerIn: parent
            spacing: 5

            Text {
                text: icon
                font.family: theme.font
                font.pixelSize: 16
                color: theme.icon
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: value
                font.family: theme.font
                font.pixelSize: 12
                font.weight: Font.Medium
                color: statMouse.containsMouse ? theme.iconHover : theme.text
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: statMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }
}
