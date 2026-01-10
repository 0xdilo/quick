pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#231b25"
    readonly property color surface: "#2a202c"
    readonly property color surfaceHigh: Qt.lighter(surface, 1.15)
    readonly property color foreground: "#dad6db"
    readonly property color muted: "#69516f"

    readonly property color accent: "#97438b"
    readonly property color secondary: "#759d46"

    readonly property color red: "#67e5f7"
    readonly property color blue: "#67f7f7"
    readonly property color yellow: "#67f767"
    readonly property color magenta: "#7b3fc5"
    readonly property color pink: "#c43ab0"
    readonly property color error: "#f38ba8"
    readonly property color success: "#87c53f"

    readonly property color bgAlpha90: Qt.rgba(background.r, background.g, background.b, 0.94)
    readonly property color bgAlpha80: Qt.rgba(background.r, background.g, background.b, 0.88)
    readonly property color bgAlpha50: Qt.rgba(0, 0, 0, 0.5)

    readonly property color border: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.08)
    readonly property color borderLight: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.04)
    readonly property color glow: Qt.rgba(accent.r, accent.g, accent.b, 0.25)

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
}
