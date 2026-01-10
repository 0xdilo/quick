import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

PanelWindow {
    id: launcher
    implicitWidth: 500
    implicitHeight: 450
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

    property var apps: []
    property var filteredApps: []
    property int selectedIndex: 0
    property string searchText: ""
    property bool appsLoaded: false
    property var commands: []

    Component.onCompleted: loadApps()

    function show() {
        if (!appsLoaded) loadApps()
        searchInput.text = ""
        searchText = ""
        selectedIndex = 0
        filteredApps = apps.slice(0, 9)
        visible = true
        searchInput.forceActiveFocus()
    }

    function hide() {
        visible = false
        closed()
    }

    function loadApps() {
        appsProc.running = true
    }

    function filterApps() {
        if (searchText === "") {
            filteredApps = apps.slice(0, 9)
            commands = []
        } else {
            var query = searchText.toLowerCase()
            var result = []

            for (var j = 0; j < apps.length && result.length < 6; j++) {
                if (apps[j].name.toLowerCase().indexOf(query) !== -1) {
                    result.push(apps[j])
                }
            }

            if (result.length < 6 && searchText.length >= 2) {
                cmdProc.command = ["sh", "-c", "compgen -c " + searchText + " 2>/dev/null | head -4"]
                cmdProc.running = true
            }

            filteredApps = result
        }
        selectedIndex = 0
    }

    Process {
        id: cmdProc
        stdout: SplitParser {
            onRead: data => {
                if (data && data.length > 0) {
                    var newCmds = launcher.commands.slice()
                    newCmds.push({ name: data, exec: data, icon: "", isCmd: true })
                    launcher.commands = newCmds
                    var newFiltered = launcher.filteredApps.slice()
                    if (newFiltered.length < 9) {
                        newFiltered.push({ name: data, exec: data, icon: "", isCmd: true })
                        launcher.filteredApps = newFiltered
                    }
                }
            }
        }
        onStarted: launcher.commands = []
    }

    function launchApp(exec) {
        var cmd = exec.replace(/%[fFuUdDnNickvm]/g, "").trim()
        Hyprland.dispatch("exec " + cmd)
        hide()
    }

    function runCommand(cmd) {
        Hyprland.dispatch("exec " + cmd)
        hide()
    }

    Process {
        id: appsProc
        command: ["sh", "-c", "find /usr/share/applications ~/.local/share/applications -name '*.desktop' 2>/dev/null | while read f; do name=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2); exec=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2); icon=$(grep -m1 '^Icon=' \"$f\" | cut -d= -f2); nodisplay=$(grep -m1 '^NoDisplay=' \"$f\" | cut -d= -f2); if [ -n \"$name\" ] && [ -n \"$exec\" ] && [ \"$nodisplay\" != \"true\" ]; then echo \"$name|||$exec|||$icon\"; fi; done | sort -u"]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.split("|||")
                if (parts.length >= 2) {
                    var newApps = launcher.apps.slice()
                    newApps.push({ name: parts[0], exec: parts[1], icon: parts[2] || "", isCmd: false })
                    launcher.apps = newApps
                }
            }
        }
        onExited: (code, status) => {
            appsLoaded = true
            filterApps()
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: launcher.hide()
    }

    Rectangle {
        id: container
        anchors.centerIn: parent
        width: 420
        height: 380
        radius: 20
        color: Theme.bgAlpha90
        border.width: 1
        border.color: Theme.border

        layer.enabled: true
        layer.smooth: true

        scale: launcher.visible ? 1.0 : 0.95
        opacity: launcher.visible ? 1.0 : 0
        Behavior on scale { Anim {} }
        Behavior on opacity { Anim { duration: 100 } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    anchors.centerIn: parent
                    text: launcher.filteredApps.length === 0 ? (launcher.searchText.length > 0 ? "\uf002" : "\uf135") : ""
                    font.family: Theme.fontFamily
                    font.pixelSize: 48
                    color: Theme.muted
                    opacity: 0.3
                    visible: launcher.filteredApps.length === 0
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.verticalCenter
                    anchors.topMargin: 30
                    text: launcher.searchText.length > 0 ? "Press Enter to run" : "Type to search"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.muted
                    visible: launcher.filteredApps.length === 0
                }

                ListView {
                    id: appsList
                    anchors.fill: parent
                    model: launcher.filteredApps
                    clip: true
                    spacing: 4
                    currentIndex: launcher.selectedIndex
                    cacheBuffer: 400

                    delegate: Rectangle {
                        id: itemDelegate
                        width: appsList.width
                        height: 52
                        radius: 12
                        color: index === launcher.selectedIndex ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"

                        Behavior on color { CAnim {} }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 14

                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                radius: 10
                                color: "transparent"

                                Image {
                                    id: appIcon
                                    anchors.centerIn: parent
                                    width: 32
                                    height: 32
                                    source: modelData.icon ? "image://icon/" + modelData.icon : ""
                                    sourceSize: Qt.size(32, 32)
                                    visible: status === Image.Ready
                                    asynchronous: true
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 10
                                    color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.1)
                                    visible: appIcon.status !== Image.Ready

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.isCmd ? "\uf120" : "\uf135"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 16
                                        color: Theme.secondary
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.weight: index === launcher.selectedIndex ? Font.Medium : Font.Normal
                                    color: Theme.foreground
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: modelData.isCmd
                                    text: "command"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    color: Theme.muted
                                }
                            }

                            Text {
                                text: "\uf054"
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                color: Theme.accent
                                visible: index === launcher.selectedIndex
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: launcher.launchApp(modelData.exec)
                            onEntered: launcher.selectedIndex = index
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: 24
                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.8)
                border.width: 1
                border.color: searchInput.activeFocus ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : Theme.border

                Behavior on border.color { CAnim {} }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 12

                    Text {
                        text: "\uf002"
                        font.family: Theme.fontFamily
                        font.pixelSize: 16
                        color: searchInput.activeFocus ? Theme.accent : Theme.muted
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        color: Theme.foreground
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.background
                        clip: true
                        verticalAlignment: TextInput.AlignVCenter

                        Text {
                            anchors.fill: parent
                            text: "Search..."
                            font: parent.font
                            color: Theme.muted
                            visible: !parent.text
                            verticalAlignment: Text.AlignVCenter
                        }

                        onTextChanged: {
                            launcher.searchText = text
                            launcher.filterApps()
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                launcher.hide()
                            } else if (event.key === Qt.Key_Down) {
                                launcher.selectedIndex = Math.min(launcher.selectedIndex + 1, launcher.filteredApps.length - 1)
                            } else if (event.key === Qt.Key_Up) {
                                launcher.selectedIndex = Math.max(launcher.selectedIndex - 1, 0)
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (launcher.filteredApps.length > 0) {
                                    launcher.launchApp(launcher.filteredApps[launcher.selectedIndex].exec)
                                } else if (launcher.searchText.length > 0) {
                                    launcher.runCommand(launcher.searchText)
                                }
                            }
                        }
                    }

                    Text {
                        text: "esc"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.muted
                        opacity: 0.6
                    }
                }
            }
        }
    }
}
