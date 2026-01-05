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

    Stat { icon: "\uf06d"; value: temp + "°"; accent: theme.peach; accentBg: Qt.rgba(theme.peach.r, theme.peach.g, theme.peach.b, 0.15) }
    Stat { icon: "\uf085"; value: cpu + "%"; accent: theme.lavender; accentBg: Qt.rgba(theme.lavender.r, theme.lavender.g, theme.lavender.b, 0.15) }
    Stat { icon: "\uf1c0"; value: mem.toFixed(1) + "G"; accent: theme.sky; accentBg: Qt.rgba(theme.sky.r, theme.sky.g, theme.sky.b, 0.15) }

    component Stat: Rectangle {
        property string icon
        property string value
        property color accent
        property color accentBg

        implicitWidth: statRow.implicitWidth + 14
        implicitHeight: 28
        radius: 14
        color: statMouse.containsMouse ? accentBg : "transparent"

        Row {
            id: statRow
            anchors.centerIn: parent
            spacing: 5

            Text {
                text: icon
                font.family: theme.font
                font.pixelSize: 16
                color: accent
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: value
                font.family: theme.font
                font.pixelSize: 12
                font.weight: Font.Medium
                color: statMouse.containsMouse ? accent : theme.text
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
