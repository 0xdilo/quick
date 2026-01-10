import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    implicitWidth: clockRow.implicitWidth + 20
    implicitHeight: 32
    radius: 16
    color: clockMouse.containsMouse ? Qt.rgba(theme.icon.r, theme.icon.g, theme.icon.b, 0.1) : "transparent"

    signal clicked()

    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "󰥔"
            font.family: theme.font
            font.pixelSize: 18
            color: theme.icon
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            spacing: -2

            Text {
                id: timeText
                font.family: theme.font
                font.pixelSize: 15
                font.weight: Font.DemiBold
                color: clockMouse.containsMouse ? theme.iconHover : theme.text

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    triggeredOnStart: true
                    onTriggered: timeText.text = Qt.formatDateTime(new Date(), "HH:mm")
                }
            }

            Text {
                id: dateText
                font.family: theme.font
                font.pixelSize: 11
                color: theme.textMuted

                Timer {
                    interval: 60000
                    running: true
                    repeat: true
                    triggeredOnStart: true
                    onTriggered: dateText.text = Qt.formatDateTime(new Date(), "ddd d MMM")
                }
            }
        }
    }

    MouseArea {
        id: clockMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
