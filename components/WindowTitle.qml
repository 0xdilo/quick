import QtQuick
import Quickshell.Hyprland

Item {
    id: root
    visible: titleText.text !== ""

    property var client: Hyprland.focusedClient
    property string fullTitle: {
        if (!client || !client.title) return ""
        var t = client.title
        return t.replace(/ [-–—] (Brave|Mozilla Firefox|Visual Studio Code|kitty).*$/i, "")
    }

    Row {
        id: titleRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            font.family: theme.font
            font.pixelSize: theme.fontSizeIcon
            color: theme.accent

            text: {
                if (!client) return ""
                var c = (client.class_ || "").toLowerCase()
                if (c.includes("kitty")) return "󰄛"
                if (c.includes("brave")) return "󰖟"
                if (c.includes("firefox")) return "󰈹"
                if (c.includes("code")) return "󰨞"
                if (c.includes("discord")) return "󰙯"
                if (c.includes("spotify")) return "󰓇"
                return "󰏃"
            }

            Behavior on text { PropertyAnimation { duration: 0 } }
        }

        Text {
            id: titleText
            width: Math.min(implicitWidth, 200)
            elide: Text.ElideRight
            font.family: theme.font
            font.pixelSize: theme.fontSize
            color: titleMouse.containsMouse ? theme.text : theme.textSoft

            text: fullTitle.length > 30 ? fullTitle.substring(0, 30) + "…" : fullTitle

            Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }
        }
    }

    MouseArea {
        id: titleMouse
        anchors.fill: titleRow
        hoverEnabled: true

        onContainsMouseChanged: {
            if (containsMouse && fullTitle.length > 30) tooltipTimer.start()
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
        x: (titleRow.width - width) / 2 + titleRow.x
        y: root.height + 6
        visible: opacity > 0
        opacity: 0
        width: Math.min(tooltipText.implicitWidth + 14, 300)
        height: 24
        radius: 6
        color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.95)
        border.width: 1
        border.color: Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.08)

        Text {
            id: tooltipText
            anchors.centerIn: parent
            width: parent.width - 14
            text: fullTitle
            font.family: theme.font
            font.pixelSize: 10
            color: theme.text
            elide: Text.ElideRight
        }

        Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
    }
}
