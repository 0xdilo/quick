import QtQuick
import Quickshell.Hyprland

Item {
    visible: titleText.text !== ""

    Row {
        anchors.centerIn: parent
        spacing: 8

        Text {
            id: iconText
            font.family: theme.font
            font.pixelSize: theme.fontSizeIcon
            color: theme.lavender

            text: {
                var client = Hyprland.focusedClient
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
        }

        Text {
            id: titleText
            width: Math.min(implicitWidth, 200)
            elide: Text.ElideRight
            font.family: theme.font
            font.pixelSize: theme.fontSize
            color: theme.textSoft

            text: {
                var client = Hyprland.focusedClient
                if (!client || !client.title) return ""
                var t = client.title
                t = t.replace(/ [-–—] (Brave|Mozilla Firefox|Visual Studio Code|kitty).*$/i, "")
                return t.length > 30 ? t.substring(0, 30) + "…" : t
            }
        }
    }
}
