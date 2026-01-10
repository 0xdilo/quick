import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris

PanelWindow {
    id: control
    visible: false
    color: "transparent"

    signal closed()

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property int currentTab: 0
    property var tabs: ["Dashboard", "Media", "Performance"]
    property var tabIcons: ["\uf0e4", "\uf001", "\uf201"]

    function show() {
        visible = true
        currentTab = 0
    }

    function hide() {
        visible = false
        closed()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: control.hide()
    }

    Rectangle {
        id: container
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 50
        width: 660
        height: 420
        radius: 24
        color: Theme.bgAlpha90
        border.width: 1
        border.color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.08)

        layer.enabled: true
        layer.smooth: true

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.04)
            anchors.margins: 1
        }

        scale: control.visible ? 1.0 : 0.95
        opacity: control.visible ? 1.0 : 0
        transformOrigin: Item.Top

        Behavior on scale { Anim {} }
        Behavior on opacity { Anim { duration: 100 } }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) control.hide()
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                color: "transparent"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Repeater {
                        model: control.tabs

                        Rectangle {
                            width: tabRow.implicitWidth + 28
                            height: 38
                            radius: 19
                            color: control.currentTab === index ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12) : (tabMa.containsMouse ? Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.05) : "transparent")

                            Behavior on color { CAnim {} }

                            Row {
                                id: tabRow
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: control.tabIcons[index]
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    color: control.currentTab === index ? Theme.accent : Theme.muted
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    font.weight: control.currentTab === index ? Font.Medium : Font.Normal
                                    color: control.currentTab === index ? Theme.foreground : Theme.muted
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: tabMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: control.currentTab = index
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.06)
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 16

                Loader {
                    anchors.fill: parent
                    sourceComponent: {
                        switch(control.currentTab) {
                            case 0: return dashboardTab
                            case 1: return mediaTab
                            case 2: return performanceTab
                            default: return dashboardTab
                        }
                    }
                }
            }
        }
    }

    Component {
        id: dashboardTab

        Row {
            anchors.fill: parent
            spacing: 12

            Column {
                width: 160
                height: parent.height
                spacing: 12

                Card {
                    width: parent.width
                    height: 90

                    Row {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        Text {
                            text: "\uf185"
                            font.family: Theme.fontFamily
                            font.pixelSize: 28
                            color: Theme.accent
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                id: tempText
                                text: "..."
                                font.family: Theme.fontFamily
                                font.pixelSize: 22
                                font.weight: Font.Medium
                                color: Theme.foreground

                                Timer {
                                    interval: 300000
                                    running: true
                                    repeat: true
                                    triggeredOnStart: true
                                    onTriggered: weatherProc.running = true
                                }

                                Process {
                                    id: weatherProc
                                    command: ["sh", "-c", "curl -s 'wttr.in/?format=%t' 2>/dev/null | tr -d '+' || echo '--'"]
                                    stdout: SplitParser {
                                        onRead: data => tempText.text = data || "--"
                                    }
                                }
                            }

                            Text {
                                text: "Weather"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                color: Theme.muted
                            }
                        }
                    }
                }

                Card {
                    width: parent.width
                    height: parent.height - 90 - 12

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            id: clockHour
                            text: "00"
                            font.family: Theme.fontFamily
                            font.pixelSize: 42
                            font.weight: Font.Bold
                            color: Theme.foreground
                            anchors.horizontalCenter: parent.horizontalCenter

                            Timer {
                                interval: 1000
                                running: true
                                repeat: true
                                triggeredOnStart: true
                                onTriggered: {
                                    var now = new Date()
                                    clockHour.text = Qt.formatDateTime(now, "HH")
                                    clockMin.text = Qt.formatDateTime(now, "mm")
                                    clockDate.text = Qt.formatDateTime(now, "ddd, MMM d")
                                }
                            }
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 4
                            Repeater {
                                model: 3
                                Rectangle { width: 5; height: 5; radius: 2.5; color: Theme.accent }
                            }
                        }

                        Text {
                            id: clockMin
                            text: "00"
                            font.family: Theme.fontFamily
                            font.pixelSize: 42
                            font.weight: Font.Bold
                            color: Theme.foreground
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            id: clockDate
                            text: "..."
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.muted
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            Column {
                width: parent.width - 160 - 12
                height: parent.height
                spacing: 12

                Card {
                    width: parent.width
                    height: 90

                    Row {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 14

                        Rectangle {
                            width: 56
                            height: 56
                            radius: 28
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "\uf17c"
                                font.family: Theme.fontFamily
                                font.pixelSize: 24
                                color: Theme.accent
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            Row {
                                spacing: 8
                                Text { text: "\uf303"; font.family: Theme.fontFamily; font.pixelSize: 11; color: Theme.accent }
                                Text { text: "Arch Linux"; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.foreground }
                            }

                            Row {
                                spacing: 8
                                Text { text: "\uf108"; font.family: Theme.fontFamily; font.pixelSize: 11; color: Theme.accent }
                                Text { text: "Hyprland"; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.foreground }
                            }

                            Row {
                                spacing: 8
                                Text { text: "\uf017"; font.family: Theme.fontFamily; font.pixelSize: 11; color: Theme.accent }
                                Text {
                                    id: uptimeText
                                    text: "..."
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    color: Theme.foreground

                                    Timer {
                                        interval: 60000
                                        running: true
                                        repeat: true
                                        triggeredOnStart: true
                                        onTriggered: uptimeProc.running = true
                                    }

                                    Process {
                                        id: uptimeProc
                                        command: ["sh", "-c", "uptime -p | sed 's/up //'"]
                                        stdout: SplitParser {
                                            onRead: data => uptimeText.text = data || "..."
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Card {
                    width: parent.width
                    height: parent.height - 90 - 12

                    CalendarWidget {
                        anchors.fill: parent
                        anchors.margins: 12
                    }
                }
            }
        }
    }

    Component {
        id: mediaTab

        RowLayout {
            anchors.fill: parent
            spacing: 16

            Card {
                Layout.preferredWidth: 280
                Layout.fillHeight: true

                property var player: {
                    var list = Mpris.players.values
                    for (var i = 0; i < list.length; i++) {
                        if (list[i].playbackStatus === "Playing") return list[i]
                    }
                    return list.length > 0 ? list[0] : null
                }

                property bool hasPlayer: player !== null
                property bool isPlaying: player?.playbackStatus === "Playing"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    Rectangle {
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 140
                        Layout.alignment: Qt.AlignHCenter
                        radius: 14
                        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)

                        Image {
                            id: albumArt
                            anchors.fill: parent
                            source: parent.parent.parent.player?.trackArtUrl ?? ""
                            fillMode: Image.PreserveAspectCrop
                            visible: status === Image.Ready
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "\uf001"
                            font.family: Theme.fontFamily
                            font.pixelSize: 40
                            color: Theme.muted
                            visible: albumArt.status !== Image.Ready
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: parent.parent.parent.player?.trackTitle ?? "No media"
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: Theme.foreground
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            Layout.fillWidth: true
                            text: parent.parent.parent.player?.trackArtist ?? "—"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: Theme.muted
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 16

                        MediaBtn {
                            icon: "\uf048"
                            onClicked: parent.parent.parent.player?.previous()
                        }

                        MediaBtn {
                            icon: parent.parent.parent.isPlaying ? "\uf04c" : "\uf04b"
                            size: 44
                            primary: true
                            onClicked: parent.parent.parent.player?.togglePlaying()
                        }

                        MediaBtn {
                            icon: "\uf051"
                            onClicked: parent.parent.parent.player?.next()
                        }
                    }
                }
            }

            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Text {
                        text: "Players"
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: Theme.foreground
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: Mpris.players
                        spacing: 6
                        clip: true

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 44
                            radius: 10
                            color: modelData.playbackStatus === "Playing" ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Text {
                                    text: "\uf001"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    color: modelData.playbackStatus === "Playing" ? Theme.accent : Theme.muted
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text: modelData.identity || "Unknown"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        color: Theme.foreground
                                    }

                                    Text {
                                        text: modelData.playbackStatus || "Stopped"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        color: Theme.muted
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: performanceTab

        Item {
            id: perfRoot
            anchors.fill: parent

            property int cpuVal: 0
            property real memVal: 0
            property real memTotal: 16
            property int tempVal: 0

            Timer {
                interval: 2000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    cpuProc.running = true
                    memProc.running = true
                    tempProc.running = true
                }
            }

            Process {
                id: cpuProc
                command: ["sh", "-c", "awk '/^cpu / {print int(($2+$4)*100/($2+$4+$5))}' /proc/stat"]
                stdout: SplitParser { onRead: data => perfRoot.cpuVal = parseInt(data) || 0 }
            }

            Process {
                id: memProc
                command: ["sh", "-c", "free -b | awk '/Mem:/ {printf \"%.1f %.1f\", $3/1073741824, $2/1073741824}'"]
                stdout: SplitParser {
                    onRead: data => {
                        var parts = data.split(" ")
                        perfRoot.memVal = parseFloat(parts[0]) || 0
                        perfRoot.memTotal = parseFloat(parts[1]) || 16
                    }
                }
            }

            Process {
                id: tempProc
                command: ["sh", "-c", "sensors 2>/dev/null | grep -E 'Package id|Tctl|Core 0:' | head -1 | grep -oE '[0-9]+\\.[0-9]+' | head -1 | cut -d. -f1"]
                stdout: SplitParser { onRead: data => perfRoot.tempVal = parseInt(data) || 0 }
            }

            Grid {
                anchors.fill: parent
                columns: 2
                spacing: 12

                PerfCard {
                    width: (parent.width - 12) / 2
                    height: (parent.height - 12) / 2
                    title: "CPU"
                    icon: "\uf2db"
                    value: perfRoot.cpuVal
                    suffix: "%"
                    barColor: Theme.accent
                }

                PerfCard {
                    width: (parent.width - 12) / 2
                    height: (parent.height - 12) / 2
                    title: "Memory"
                    icon: "\uf538"
                    value: perfRoot.memTotal > 0 ? Math.round(perfRoot.memVal / perfRoot.memTotal * 100) : 0
                    suffix: "%"
                    subtitle: perfRoot.memVal.toFixed(1) + " / " + perfRoot.memTotal.toFixed(0) + " GB"
                    barColor: Theme.secondary
                }

                PerfCard {
                    width: (parent.width - 12) / 2
                    height: (parent.height - 12) / 2
                    title: "Temperature"
                    icon: "\uf2c9"
                    value: perfRoot.tempVal
                    suffix: "°C"
                    barColor: perfRoot.tempVal > 70 ? Theme.error : Theme.accent
                }

                Card {
                    width: (parent.width - 12) / 2
                    height: (parent.height - 12) / 2

                    Column {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        Text {
                            text: "Quick Actions"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: Theme.foreground
                        }

                        Row {
                            width: parent.width
                            height: 54
                            spacing: 8

                            QuickAction { width: (parent.width - 24) / 4; icon: "\uf011"; label: "Power"; onClicked: Hyprland.dispatch("exec systemctl poweroff") }
                            QuickAction { width: (parent.width - 24) / 4; icon: "\uf01e"; label: "Reboot"; onClicked: Hyprland.dispatch("exec systemctl reboot") }
                            QuickAction { width: (parent.width - 24) / 4; icon: "\uf023"; label: "Lock"; onClicked: Hyprland.dispatch("exec hyprlock") }
                            QuickAction { width: (parent.width - 24) / 4; icon: "\uf186"; label: "Sleep"; onClicked: Hyprland.dispatch("exec systemctl suspend") }
                        }
                    }
                }
            }
        }
    }

    component Card: Rectangle {
        color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.7)
        radius: 16
        border.width: 1
        border.color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.06)

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.03)
            anchors.margins: 1
        }
    }

    component MediaBtn: Rectangle {
        property string icon
        property int size: 32
        property bool primary: false
        signal clicked()

        width: size
        height: size
        radius: size / 2
        color: primary ? Theme.accent : (btnMa.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent")

        Behavior on color { CAnim {} }

        Text {
            anchors.centerIn: parent
            text: parent.icon
            font.family: Theme.fontFamily
            font.pixelSize: parent.primary ? 16 : 12
            color: parent.primary ? Theme.background : Theme.foreground
        }

        MouseArea {
            id: btnMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component PerfCard: Card {
        property string title
        property string icon
        property int value
        property string suffix
        property string subtitle: ""
        property color barColor: Theme.accent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 6

            RowLayout {
                spacing: 8

                Text {
                    text: icon
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    color: barColor
                }

                Text {
                    text: title
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Theme.foreground
                }
            }

            Text {
                text: value + suffix
                font.family: Theme.fontFamily
                font.pixelSize: 28
                font.weight: Font.Bold
                color: barColor
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 5
                radius: 2.5
                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.8)

                Rectangle {
                    width: parent.width * Math.min(value, 100) / 100
                    height: parent.height
                    radius: 2.5
                    color: barColor

                    Behavior on width { Anim {} }
                }
            }

            Text {
                text: subtitle
                font.family: Theme.fontFamily
                font.pixelSize: 10
                color: Theme.muted
                visible: subtitle.length > 0
            }
        }
    }

    component QuickAction: Rectangle {
        property string icon
        property string label
        signal clicked()

        height: 54
        radius: 10
        color: qaMa.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"

        Behavior on color { CAnim {} }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4

            Text {
                text: icon
                font.family: Theme.fontFamily
                font.pixelSize: 16
                color: Theme.secondary
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: label
                font.family: Theme.fontFamily
                font.pixelSize: 9
                color: Theme.muted
                Layout.alignment: Qt.AlignHCenter
            }
        }

        MouseArea {
            id: qaMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component CalendarWidget: Item {
        id: calWidget

        property var today: new Date()
        property int currentDay: today.getDate()
        property int currentMonth: today.getMonth()
        property int currentYear: today.getFullYear()
        property int firstDayOfWeek: new Date(currentYear, currentMonth, 1).getDay()
        property int offset: firstDayOfWeek === 0 ? 6 : firstDayOfWeek - 1
        property int totalDays: new Date(currentYear, currentMonth + 1, 0).getDate()
        property int prevMonthDays: new Date(currentYear, currentMonth, 0).getDate()

        ColumnLayout {
            anchors.fill: parent
            spacing: 6

            Row {
                Layout.fillWidth: true

                Repeater {
                    model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

                    Text {
                        width: parent.width / 7
                        text: modelData
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: Theme.muted
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            Grid {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                spacing: 2

                Repeater {
                    model: 42

                    Rectangle {
                        width: (parent.width - 12) / 7
                        height: (parent.height - 10) / 6
                        radius: Math.min(width, height) / 2

                        property int num: {
                            var i = index
                            var o = calWidget.offset
                            var t = calWidget.totalDays
                            var p = calWidget.prevMonthDays
                            if (i < o) return p - o + i + 1
                            else if (i < o + t) return i - o + 1
                            else return i - o - t + 1
                        }
                        property bool inMonth: index >= calWidget.offset && index < calWidget.offset + calWidget.totalDays
                        property bool today: inMonth && num === calWidget.currentDay

                        color: today ? Theme.accent : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: parent.num
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: parent.today ? Theme.background : (parent.inMonth ? Theme.foreground : Theme.muted)
                            opacity: parent.inMonth ? 1 : 0.35
                        }
                    }
                }
            }
        }
    }
}
