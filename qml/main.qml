import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform

import Spectral.Panel 2.0
import Spectral.Component 2.0
import Spectral.Page 2.0
import Spectral.Effect 2.0

import Spectral 0.1
import Spectral.Setting 0.1

ApplicationWindow {
    Material.theme: MPalette.theme
    Material.background: MPalette.background

    width: 960
    height: 640
    minimumWidth: 720
    minimumHeight: 360

    id: window

    visible: true
    title: qsTr("Spectral")

    background: Rectangle {
        color: MSettings.darkTheme ? "#303030" : "#FFFFFF"
    }

    Platform.SystemTrayIcon {
        visible: MSettings.showTray
        iconSource: "qrc:/assets/img/icon.png"

        menu: Platform.Menu {
            Platform.MenuItem {
                text: qsTr("Hide Window")
                onTriggered: hideWindow()
            }
            Platform.MenuItem {
                text: qsTr("Quit")
                onTriggered: Qt.quit()
            }
        }

        onActivated: showWindow()
    }

    Controller {
        id: spectralController

        quitOnLastWindowClosed: !MSettings.showTray

        onNotificationClicked: {
            roomListForm.enteredRoom = spectralController.connection.room(roomId)
            roomForm.goToEvent(eventId)
            showWindow()
        }
        onErrorOccured: {
            roomListForm.errorControl.error = error
            roomListForm.errorControl.detail = detail
            roomListForm.errorControl.visible = true
        }
        onSyncDone: roomListForm.errorControl.visible = false
    }

    Shortcut {
        sequence: StandardKey.Quit
        onActivated: Qt.quit()
    }

    Dialog {
        property bool busy: false

        width: 360
        x: (window.width - width) / 2
        y: (window.height - height) / 2

        id: loginDialog

        parent: ApplicationWindow.overlay

        title: "Login"

        contentItem: Column {
            AutoTextField {
                width: parent.width

                id: serverField

                placeholderText: "Server Address"
                text: "https://matrix.org"
            }

            AutoTextField {
                width: parent.width

                id: usernameField

                placeholderText: "Username"

                onAccepted: passwordField.forceActiveFocus()
            }

            AutoTextField {
                width: parent.width

                id: passwordField

                placeholderText: "Password"
                echoMode: TextInput.Password

                onAccepted: loginDialog.doLogin()
            }
        }

        footer: DialogButtonBox {
            Button {
                text: "OK"
                flat: true
                enabled: !loginDialog.busy

                onClicked: loginDialog.doLogin()
            }

            Button {
                text: "Cancel"
                flat: true
                enabled: !loginDialog.busy

                onClicked: loginDialog.close()
            }

            ToolTip {
                id: loginButtonTooltip

            }
        }

        onVisibleChanged: {
            if (visible) spectralController.onErrorOccured.connect(showError)
            else spectralController.onErrorOccured.disconnect(showError)
        }

        function showError(error, detail) {
            loginDialog.busy = false
            loginButtonTooltip.text = error + ": " + detail
            loginButtonTooltip.open()
        }

        function doLogin() {
            if (!(serverField.text.startsWith("http") && serverField.text.includes("://"))) {
                loginButtonTooltip.text = "Server address should start with http(s)://"
                loginButtonTooltip.open()
                return
            }

            loginDialog.busy = true
            spectralController.loginWithCredentials(serverField.text, usernameField.text, passwordField.text)

            spectralController.connectionAdded.connect(function(conn) {
                busy = false
                loginDialog.close()
            })
        }
    }

    Dialog {
        anchors.centerIn: parent

        width: 200
        height: 300

        id: settingsDialog
    }

    SplitView {
        anchors.fill: parent

        RoomListPanel {
            width: window.width * 0.35
            Layout.minimumWidth: 180

            id: roomListForm

            clip: true

            controller: spectralController

            onLeaveRoom: roomForm.saveReadMarker(room)
        }

        RoomPanel {
            Layout.fillWidth: true
            Layout.minimumWidth: 480

            id: roomForm

            clip: true

            currentRoom: roomListForm.enteredRoom
        }
    }

    Binding {
        target: imageProvider
        property: "connection"
        value: spectralController.connection
    }

    function showWindow() {
        window.show()
        window.raise()
        window.requestActivate()
    }

    function hideWindow() {
        window.hide()
    }

    Component.onCompleted: {
        spectralController.initiated.connect(function() {
            if (spectralController.accountCount == 0) loginDialog.open()
        })
    }
}
