import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtWebEngine 1.10

ApplicationWindow {
    visible: true
    width: 1200
    height: 800
    title: "NeonCode Editor"
    
    property bool isDarkMode: true
    property string activeLang: langSelector.currentText

    // Synthwave Gradient Background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: isDarkMode ? "#0f0c29" : "#ffb8d2" }
            GradientStop { position: 0.5; color: isDarkMode ? "#302b63" : "#e0c3fc" }
            GradientStop { position: 1.0; color: isDarkMode ? "#24243e" : "#8ec5fc" }
        }
    }

    // Main Layout
    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // LEFT PANEL: Editor
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: isDarkMode ? "#40000000" : "#40FFFFFF" // Glassmorphism base
            border.color: isDarkMode ? "#80ff00ff" : "#8000d2ff" // Neon borders
            border.width: 1
            radius: 15

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15

                RowLayout {
                    ComboBox {
                        id: langSelector
                        model: ["HTML/CSS/JS", "Python", "C++", "C"]
                        font.pixelSize: 14
                    }
                    Switch {
                        id: liveMode
                        text: "Real-Time"
                    }
                    Button {
                        text: "▶ Run"
                        onClicked: CodeRunner.executeCode(activeLang, codeInput.text)
                    }
                    Item { Layout.fillWidth: true } // Spacer
                    Switch {
                        text: "Dark Mode"
                        checked: isDarkMode
                        onCheckedChanged: isDarkMode = checked
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    TextArea {
                        id: codeInput
                        font.family: "monospace"
                        font.pixelSize: 16
                        color: isDarkMode ? "#00ffff" : "#000000"
                        placeholderText: "Enter your code here..."
                        onTextChanged: {
                            if (liveMode.checked) {
                                CodeRunner.executeCode(activeLang, text)
                            }
                        }
                        background: null
                    }
                }
            }
        }

        // RIGHT PANEL: Output
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: isDarkMode ? "#40000000" : "#40FFFFFF"
            border.color: isDarkMode ? "#8000ffff" : "#80ff00d2"
            border.width: 1
            radius: 15
            clip: true

            StackLayout {
                anchors.fill: parent
                anchors.margins: 10
                currentIndex: activeLang === "HTML/CSS/JS" ? 0 : 1

                // View 0: Web Output
                WebEngineView {
                    id: webOutput
                    Connections {
                        target: CodeRunner
                        function onWebOutputReady(htmlContent) {
                            webOutput.loadHtml(htmlContent)
                        }
                    }
                }

                // View 1: Console Output
                ScrollView {
                    TextArea {
                        id: consoleOutput
                        font.family: "monospace"
                        color: isDarkMode ? "#00ff00" : "#000000"
                        readOnly: true
                        background: null
                        Connections {
                            target: CodeRunner
                            function onConsoleOutputReady(output) {
                                consoleOutput.text += output + "\n"
                            }
                        }
                    }
                }
            }
        }
    }
}
