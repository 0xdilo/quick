import QtQuick
import Quickshell.Hyprland

Item {
    id: root
    property bool vertical: false

    implicitWidth: vertical ? 30 : wsRow.implicitWidth + 12
    implicitHeight: vertical ? wsCol.implicitHeight + 12 : 30

    property var occupiedSet: ({})
    property int activeWs: Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1

    property int maxWs: {
        var max = 5
        var list = Hyprland.workspaces?.values ?? []
        var newOccupied = {}
        for (var i = 0; i < list.length; i++) {
            var ws = list[i]
            if (ws.id > max) max = ws.id
            if (ws.windows > 0) newOccupied[ws.id] = true
        }
        if (activeWs > max) max = activeWs
        occupiedSet = newOccupied
        return max
    }

    Row {
        id: wsRow
        visible: !root.vertical
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: root.maxWs

            Rectangle {
                id: wsH
                property int wsId: index + 1
                property bool active: root.activeWs === wsId
                property bool occupied: !!root.occupiedSet[wsId]

                width: 26
                height: 26
                radius: 13
                color: wsMouse.containsMouse ? Qt.rgba(theme.pink.r, theme.pink.g, theme.pink.b, 0.15) : "transparent"
                scale: wsMouse.pressed ? 0.9 : 1.0

                Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 60; easing.type: Easing.OutCubic } }

                Text {
                    anchors.centerIn: parent
                    text: wsH.active ? "\uf004" : (wsH.occupied ? "\uf004" : "\uf08a")
                    font.family: theme.font
                    font.pixelSize: 18
                    color: wsH.active ? theme.pink : (wsH.occupied ? theme.pink : theme.pinkSoft)
                    opacity: (wsH.active || wsH.occupied) ? 1.0 : 0.4
                    scale: wsH.active ? 1.1 : 1.0

                    Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 80; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + wsH.wsId)
                }
            }
        }
    }

    Column {
        id: wsCol
        visible: root.vertical
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: root.maxWs

            Rectangle {
                id: wsV
                property int wsId: index + 1
                property bool active: root.activeWs === wsId
                property bool occupied: !!root.occupiedSet[wsId]

                width: 22
                height: 22
                radius: 11
                color: wsMouseV.containsMouse ? Qt.rgba(theme.pink.r, theme.pink.g, theme.pink.b, 0.15) : "transparent"
                scale: wsMouseV.pressed ? 0.9 : 1.0

                Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 60; easing.type: Easing.OutCubic } }

                Text {
                    anchors.centerIn: parent
                    text: wsV.active ? "\uf004" : (wsV.occupied ? "\uf004" : "\uf08a")
                    font.family: theme.font
                    font.pixelSize: 14
                    color: wsV.active ? theme.pink : (wsV.occupied ? theme.pink : theme.pinkSoft)
                    opacity: (wsV.active || wsV.occupied) ? 1.0 : 0.4
                    scale: wsV.active ? 1.1 : 1.0

                    Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 80; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    id: wsMouseV
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + wsV.wsId)
                }
            }
        }
    }
}
