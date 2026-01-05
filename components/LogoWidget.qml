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
    }

    MouseArea {
        id: logoMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
