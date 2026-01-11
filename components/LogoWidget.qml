import QtQuick

Item {
    id: root
    implicitWidth: 32
    implicitHeight: 32

    signal clicked()

    Text {
        anchors.centerIn: parent
        text: "󰄛"
        font.family: theme.font
        font.pixelSize: 22
        color: logoMouse.containsMouse ? theme.pink : theme.pinkSoft
        scale: logoMouse.pressed ? 0.85 : (logoMouse.containsMouse ? 1.1 : 1.0)

        Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: logoMouse
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
            text: "App Launcher"
            font.family: theme.font
            font.pixelSize: 10
            color: theme.text
        }

        Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
    }
}
