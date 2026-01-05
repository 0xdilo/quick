import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

ShellRoot {
    id: shell

    IpcHandler {
        target: "shell"

        function toggleLauncherIpc() { shell.toggleLauncher() }
        function toggleClipboardIpc() { shell.toggleClipboard() }
        function toggleToolsIpc() { shell.toggleTools() }
    }

    Launcher {
        id: launcher
        screen: Quickshell.screens[0]
    }

    ClipboardManager {
        id: clipboardManager
        screen: Quickshell.screens[0]
    }

    ToolsMenu {
        id: toolsMenu
        screen: Quickshell.screens[0]
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            Bar {
                required property var modelData
                screen: modelData
                onLauncherRequested: shell.toggleLauncher()
            }
        }
    }

    function toggleLauncher() {
        launcher.visible ? launcher.hide() : launcher.show()
    }

    function toggleClipboard() {
        clipboardManager.visible ? clipboardManager.hide() : clipboardManager.show()
    }

    function toggleTools() {
        toolsMenu.visible ? toolsMenu.hide() : toolsMenu.show()
    }
}
