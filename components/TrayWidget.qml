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

            Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }

            Image {
                anchors.centerIn: parent
                source: modelData.icon
                sourceSize.width: 18
                sourceSize.height: 18
                asynchronous: true
                cache: true
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
                    text: modelData.tooltipTitle || modelData.title || modelData.id || "Tray"
                    font.family: theme.font
                    font.pixelSize: 10
                    color: theme.text
                }

                Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
            }
        }
    }
}
