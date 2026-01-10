pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#241c1f"
    readonly property color surface: "#2b2125"
    readonly property color surfaceHigh: Qt.lighter(surface, 1.15)
    readonly property color foreground: "#dad6d8"
    readonly property color muted: "#6c545d"

    readonly property color accent: "#46201f"
    readonly property color secondary: "#47469d"

    readonly property color red: "#c43e3a"
    readonly property color blue: "#67f7f7"
    readonly property color yellow: "#67f767"
    readonly property color magenta: "#413fc5"
    readonly property color pink: "#f767e5"
    readonly property color error: "#f38ba8"
    readonly property color success: "#c3c53f"

    readonly property color bgAlpha90: Qt.rgba(background.r, background.g, background.b, 0.92)
    readonly property color bgAlpha80: Qt.rgba(background.r, background.g, background.b, 0.85)
    readonly property color bgAlpha50: Qt.rgba(0, 0, 0, 0.5)

    readonly property color border: Qt.rgba(accent.r, accent.g, accent.b, 0.15)

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
}
