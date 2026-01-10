import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "components"

PanelWindow {
    id: bar

    signal launcherRequested()
    signal controlCenterRequested()

    required property var targetScreen
    screen: targetScreen

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 48
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    WlrLayershell.exclusiveZone: 48

    QtObject {
        id: theme

        property color bg: Theme.bgAlpha90
        property color bgSoft: Theme.surface
        property color bgCard: Qt.rgba(Theme.surfaceHigh.r, Theme.surfaceHigh.g, Theme.surfaceHigh.b, 0.95)
        property color bgHover: Theme.surfaceHigh

        property color accent: Theme.accent
        property color accentSoft: Theme.secondary
        property color icon: Theme.muted
        property color iconHover: Theme.accent

        property color pink: Theme.accent
        property color pinkSoft: Theme.secondary

        property color text: Theme.foreground
        property color textSoft: Qt.darker(Theme.foreground, 1.05)
        property color textMuted: Theme.muted

        property color success: Theme.success
        property color error: Theme.error

        property string font: Theme.fontFamily
        property int fontSize: 13
        property int fontSizeLg: 15
        property int fontSizeXl: 18
        property int fontSizeIcon: 16
        property int fontSizeIconLg: 18

        property int radius: 14
        property int radiusMd: 10
        property int radiusSm: 6
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: 6
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.bottomMargin: 6

        Rectangle {
            id: barBg
            anchors.fill: parent
            radius: 16
            color: Theme.bgAlpha90
            border.width: 1
            border.color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.08)

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: parent.radius - 1
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.04)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                RowLayout {
                    spacing: 8
                    LogoWidget { onClicked: bar.launcherRequested() }
                    ClockWidget { onClicked: bar.controlCenterRequested() }
                    TrayWidget {}
                }

                WindowTitle {
                    Layout.fillWidth: true
                    Layout.maximumWidth: 200
                }

                Item { Layout.fillWidth: true }

                WorkspacesWidget {}

                Item { Layout.fillWidth: true }

                RowLayout {
                    spacing: 4

                    SystemWidget {}
                    NetworkWidget {}
                    BluetoothWidget {}
                    MediaWidget {}
                    VolumeWidget {}
                    BatteryWidget {}
                }
            }
        }
    }
}
