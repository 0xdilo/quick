pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#1e1c24"
    readonly property color surface: "#24212b"
    readonly property color surfaceHigh: Qt.lighter(surface, 1.15)
    readonly property color foreground: "#d7d6da"
    readonly property color muted: "#5a546c"

    readonly property color accent: "#9d6446"
    readonly property color secondary: "#467f9d"

    readonly property color red: "#c56d3f"
    readonly property color blue: "#3f97c5"
    readonly property color yellow: "#67f767"
    readonly property color magenta: "#3b68c3"
    readonly property color pink: "#f767e5"
    readonly property color error: "#f38ba8"
    readonly property color success: "#c7b29d"

    readonly property color bgAlpha90: Qt.rgba(background.r, background.g, background.b, 0.94)
    readonly property color bgAlpha80: Qt.rgba(background.r, background.g, background.b, 0.88)
    readonly property color bgAlpha50: Qt.rgba(0, 0, 0, 0.5)

    readonly property color border: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.08)
    readonly property color borderLight: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.04)
    readonly property color glow: Qt.rgba(accent.r, accent.g, accent.b, 0.25)

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
}
