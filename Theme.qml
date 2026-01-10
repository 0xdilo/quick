pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#13111a"
    readonly property color surface: "#1a1723"
    readonly property color surfaceHigh: "#231f2e"
    readonly property color foreground: "#e4e0ed"
    readonly property color muted: "#6b6478"

    readonly property color accent: "#c4a7e7"
    readonly property color secondary: "#9ccfd8"

    readonly property color red: "#eb6f92"
    readonly property color blue: "#9ccfd8"
    readonly property color yellow: "#f6c177"
    readonly property color magenta: "#c4a7e7"
    readonly property color pink: "#ebbcba"
    readonly property color error: "#eb6f92"
    readonly property color success: "#9ccfd8"

    readonly property color bgAlpha90: Qt.rgba(background.r, background.g, background.b, 0.94)
    readonly property color bgAlpha80: Qt.rgba(background.r, background.g, background.b, 0.88)
    readonly property color bgAlpha50: Qt.rgba(0, 0, 0, 0.5)

    readonly property color border: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.08)
    readonly property color glow: Qt.rgba(accent.r, accent.g, accent.b, 0.3)

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
}
