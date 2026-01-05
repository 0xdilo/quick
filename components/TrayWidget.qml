import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

Row {
    spacing: 4
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        Rectangle {
            width: 32
            height: 32
            radius: 10
            color: trayMouse.containsMouse ? theme.bgHover : "transparent"

            Image {
                anchors.centerIn: parent
                source: modelData.icon
                sourceSize.width: 18
                sourceSize.height: 18
                asynchronous: true
            }

            MouseArea {
                id: trayMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) modelData.activate()
                    else modelData.secondaryActivate()
                }
            }
        }
    }
}
