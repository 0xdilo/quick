import QtQuick

Rectangle {
    id: root
    property bool vertical: false

    implicitWidth: vertical ? 40 : clockRow.implicitWidth + 22
    implicitHeight: vertical ? 50 : 30
    radius: vertical ? 8 : 15
    color: clockMouse.containsMouse ? Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.12) : "transparent"

    Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }

    signal clicked()

    property string currentTime: ""
    property string currentDate: ""
    property string currentHour: ""
    property string currentMin: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            currentTime = Qt.formatDateTime(now, "HH:mm")
            currentHour = Qt.formatDateTime(now, "HH")
            currentMin = Qt.formatDateTime(now, "mm")
            if (now.getSeconds() === 0 || currentDate === "") {
                currentDate = Qt.formatDateTime(now, "ddd d MMM")
            }
        }
    }

    Row {
        id: clockRow
        visible: !root.vertical
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "󰥔"
            font.family: theme.font
            font.pixelSize: 16
            color: clockMouse.containsMouse ? theme.accent : theme.icon
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }
        }

        Column {
            spacing: -2

            Text {
                text: currentTime
                font.family: theme.font
                font.pixelSize: 15
                font.weight: Font.DemiBold
                color: clockMouse.containsMouse ? theme.iconHover : theme.text
            }

            Text {
                text: currentDate
                font.family: theme.font
                font.pixelSize: 11
                color: theme.textMuted
            }
        }
    }

    Column {
        visible: root.vertical
        anchors.centerIn: parent
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: currentHour
            font.family: theme.font
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: clockMouse.containsMouse ? theme.iconHover : theme.text
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: currentMin
            font.family: theme.font
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: clockMouse.containsMouse ? theme.iconHover : theme.text
        }
    }

    MouseArea {
        id: clockMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()

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
            text: "Control Center"
            font.family: theme.font
            font.pixelSize: 10
            color: theme.text
        }

        Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
    }
}
