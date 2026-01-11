import QtQuick
import Quickshell.Io

Rectangle {
    id: root
    implicitWidth: visible ? batRow.implicitWidth + 18 : 0
    implicitHeight: 28
    radius: 14
    color: charging ? Qt.rgba(theme.success.r, theme.success.g, theme.success.b, 0.15) : "transparent"
    visible: capacity >= 0

    Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }

    property int capacity: -1
    property string status: ""
    property bool charging: status === "Charging" || status === "Full"

    Process {
        id: batWatch
        running: true
        command: ["sh", "-c", "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E 'percentage|state' && upower --monitor-detail | grep -E 'percentage|state'"]
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("percentage")) {
                    var match = data.match(/([0-9]+)%/)
                    if (match) capacity = parseInt(match[1])
                } else if (data.includes("state:")) {
                    if (data.includes("charging")) status = "Charging"
                    else if (data.includes("discharging")) status = "Discharging"
                    else if (data.includes("fully-charged")) status = "Full"
                    else status = ""
                }
            }
        }
    }

    property color batColor: charging ? theme.success : (capacity <= 20 ? theme.error : theme.icon)

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

            Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }
        }

        Text {
            text: capacity + "%"
            font.family: theme.font
            font.pixelSize: 13
            font.weight: Font.Medium
            color: batColor
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }
        }
    }

    MouseArea {
        id: batMouse
        anchors.fill: parent
        hoverEnabled: true

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
            text: status || "Battery"
            font.family: theme.font
            font.pixelSize: 10
            color: theme.text
        }

        Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
    }
}
