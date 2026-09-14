// Окно-переводчик на Quickshell.
// Запуск:  qs -p ./shell.qml
// Enter — перевести, Shift+Enter — новая строка, Esc — закрыть.

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls

ShellRoot {
    id: root

    property string result: ""
    property string target: ":ru"

    PanelWindow {
        id: win

        implicitWidth: 700
        implicitHeight: 300
        color: "transparent"   // without this you get a white/opaque box

        Rectangle {
            id: bg
            anchors.fill: parent
            radius: 12
            color: "#1e1e2e"
        }
        // Overlay — поверх всего; Exclusive — забирает клавиатуру целиком,
        // иначе ввод уйдёт в окно под нами.
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Row {
                spacing: 12

                Text {
                    text: root.target === ":ru" ? "EN → RU" : "RU → EN"
                    color: "#89b4fa"
                    font.pixelSize: 13
                    font.bold: true
                }

                Text {
                    text: root.target === ":ru" ? "Tab — сменить направление" : "Tab - change direction"
                    color: "#6c7086"
                    font.pixelSize: 13
                }
            }

            TextArea {
                id: input

                width: parent.width
                height: 110
                focus: true
                color: "#cdd6f4"
                selectionColor: "#585b70"
                wrapMode: TextArea.Wrap
                font.pixelSize: 16
                placeholderText: root.target === ":ru" ? "текст для перевода…" : "translation text..."
                placeholderTextColor: "#aef0f8"

                background: Rectangle {
                    color: "#313244"
                    radius: 8
                }

                Keys.onPressed: function (event) {
                    if (event.key === Qt.Key_Escape) {
                        Qt.quit();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Tab) {
                        root.target = root.target === ":ru" ? ":en" : ":ru";
                        event.accepted = true;
                    } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                               && !(event.modifiers & Qt.ShiftModifier)) {
                        if (input.text.trim() !== "") {
                            root.result = "…";

                            translator.running = false;
                            translator.command = ["trans", "-b", root.target, input.text] 
                            translator.running = true;
                        }
                        event.accepted = true;
                    }
                }
            }

            Text {
                width: parent.width
                text: root.result
                color: "#a6e3a1"
                wrapMode: Text.Wrap
                font.pixelSize: 16
            }
        }
    }

    // trans из пакета translate-shell: sudo pacman -S translate-shell
    Process {
        id: translator

        stdout: StdioCollector {
            onStreamFinished: root.result = this.text.trim()
        }
    }
}
