import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

Rectangle {
    id: root
    implicitWidth: volRow.implicitWidth + 18
    implicitHeight: 28
    radius: 14
    color: volMouse.containsMouse ? Qt.rgba(theme.icon.r, theme.icon.g, theme.icon.b, 0.1) : "transparent"
    layer.enabled: volMouse.containsMouse

    Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }

    property int vol: 0
    property bool muted: false

    Process {
        id: volumeSubscribe
        running: true
        command: ["pactl", "subscribe"]
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("sink") && data.includes("change")) {
                    volProc.running = true
                    muteProc.running = true
                }
            }
        }
    }

    Component.onCompleted: {
        volProc.running = true
        muteProc.running = true
    }

    Process {
        id: volProc
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oE '[0-9]+%' | head -1 | tr -d '%'"]
        stdout: SplitParser { onRead: data => vol = parseInt(data) || 0 }
    }

    Process {
        id: muteProc
        command: ["sh", "-c", "pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -q yes && echo 1 || echo 0"]
        stdout: SplitParser { onRead: data => muted = (parseInt(data) === 1) }
    }

    Process {
        id: setVolProc
        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", volChange]
        property string volChange: "+5%"
    }

    Process {
        id: setMuteProc
        command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]
    }

    Row {
        id: volRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: muted ? "\uf6a9" : (vol < 30 ? "\uf026" : (vol < 70 ? "\uf027" : "\uf028"))
            font.family: theme.font
            font.pixelSize: 18
            color: muted ? theme.textMuted : theme.icon
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: vol + "%"
            font.family: theme.font
            font.pixelSize: 13
            font.weight: Font.Medium
            color: muted ? theme.textMuted : (volMouse.containsMouse ? theme.iconHover : theme.text)
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: 60; easing.type: Easing.OutCubic } }
        }
    }

    MouseArea {
        id: volMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) Hyprland.dispatch("exec pavucontrol")
            else setMuteProc.running = true
        }

        onWheel: wheel => {
            setVolProc.volChange = wheel.angleDelta.y > 0 ? "+5%" : "-5%"
            setVolProc.running = true
        }

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
            text: "Click: Mixer • Right: Mute • Scroll: Volume"
            font.family: theme.font
            font.pixelSize: 10
            color: theme.text
        }

        Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
    }
}
