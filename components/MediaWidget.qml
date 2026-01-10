import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

Rectangle {
    id: root
    implicitWidth: visible ? mediaRow.implicitWidth + 20 : 0
    implicitHeight: 28
    radius: 14
    color: Qt.rgba(theme.icon.r, theme.icon.g, theme.icon.b, 0.1)
    visible: player !== null && playerStatus !== "Stopped"

    property var player: {
        var list = Mpris.players.values
        for (var i = 0; i < list.length; i++) {
            if (list[i].playbackStatus === "Playing") return list[i]
        }
        return list.length > 0 ? list[0] : null
    }

    property string playerStatus: player?.playbackStatus ?? "Stopped"
    property bool playing: playerStatus === "Playing"

    Row {
        id: mediaRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: playing ? "󰐊" : "󰏤"
            font.family: theme.font
            font.pixelSize: 16
            color: theme.icon

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: player?.togglePlaying()
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                var title = player?.trackTitle || ""
                return title.length > 20 ? title.substring(0, 20) + "…" : title
            }
            font.family: theme.font
            font.pixelSize: 13
            font.weight: Font.Medium
            color: theme.text
        }
    }
}
