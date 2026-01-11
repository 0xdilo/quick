import QtQuick
import Quickshell.Services.Mpris

Rectangle {
    id: root
    implicitWidth: visible ? mediaRow.implicitWidth + 20 : 0
    implicitHeight: 28
    radius: 14
    color: mediaMouse.containsMouse ? Qt.rgba(theme.icon.r, theme.icon.g, theme.icon.b, 0.15) : Qt.rgba(theme.icon.r, theme.icon.g, theme.icon.b, 0.1)
    visible: player !== null && playerStatus !== "Stopped"

    Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }

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
            color: playMouse.containsMouse ? theme.iconHover : theme.icon

            Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }

            MouseArea {
                id: playMouse
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

    MouseArea {
        id: mediaMouse
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onPressed: mouse => mouse.accepted = false

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
            text: player?.trackArtist ? player.trackArtist : "Now Playing"
            font.family: theme.font
            font.pixelSize: 10
            color: theme.text
        }

        Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
    }
}
