import QtQuick
import Quickshell.Io

Row {
    spacing: 6

    property int cpu: 0
    property real mem: 0
    property int temp: 0

    property int lastTotal: 0
    property int lastIdle: 0

    Timer {
        interval: 2000
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
        command: ["cat", "/proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data.startsWith("cpu ")) return
                var parts = data.split(/\s+/)
                var user = parseInt(parts[1]) || 0
                var nice = parseInt(parts[2]) || 0
                var system = parseInt(parts[3]) || 0
                var idle = parseInt(parts[4]) || 0
                var total = user + nice + system + idle
                if (lastTotal > 0) {
                    var diffTotal = total - lastTotal
                    var diffIdle = idle - lastIdle
                    cpu = diffTotal > 0 ? Math.round((diffTotal - diffIdle) * 100 / diffTotal) : 0
                }
                lastTotal = total
                lastIdle = idle
            }
        }
    }

    Process {
        id: memProc
        command: ["cat", "/proc/meminfo"]
        property int memTotal: 0
        property int memAvail: 0
        stdout: SplitParser {
            onRead: data => {
                if (data.startsWith("MemTotal:")) {
                    memProc.memTotal = parseInt(data.match(/\d+/)[0]) || 0
                } else if (data.startsWith("MemAvailable:")) {
                    memProc.memAvail = parseInt(data.match(/\d+/)[0]) || 0
                    var used = memProc.memTotal - memProc.memAvail
                    mem = used / 1048576
                }
            }
        }
    }

    Process {
        id: tempProc
        command: ["cat", "/sys/class/thermal/thermal_zone0/temp"]
        stdout: SplitParser {
            onRead: data => temp = Math.round((parseInt(data) || 0) / 1000)
        }
    }

    Stat { icon: "\uf06d"; value: temp + "°"; hint: "Temperature" }
    Stat { icon: "\uf085"; value: cpu + "%"; hint: "CPU Usage" }
    Stat { icon: "\uf1c0"; value: mem.toFixed(1) + "G"; hint: "Memory Used" }

    component Stat: Rectangle {
        property string icon
        property string value
        property string hint: ""

        implicitWidth: statRow.implicitWidth + 14
        implicitHeight: 28
        radius: 14
        color: statMouse.containsMouse ? Qt.rgba(theme.icon.r, theme.icon.g, theme.icon.b, 0.1) : "transparent"

        Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }

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

                Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }
            }
        }

        MouseArea {
            id: statMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

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
                text: hint
                font.family: theme.font
                font.pixelSize: 10
                color: theme.text
            }

            Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
        }
    }
}
