import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import Qt.labs.platform 1.0 as Platform

import Spectral 0.1
import Spectral.Setting 0.1

import Spectral.Component 2.0
import Spectral.Dialog 2.0
import Spectral.Menu.Timeline 2.0
import Spectral.Effect 2.0
import Spectral.Font 0.1

ColumnLayout {
    readonly property bool avatarVisible: !sentByMe && showAuthor
    readonly property bool sentByMe: author === currentRoom.localUser

    property bool openOnFinished: false
    readonly property bool downloaded: progressInfo && progressInfo.completed

    id: root

    spacing: 0

    onDownloadedChanged: {
        if (downloaded && openOnFinished) {
            openSavedFile()
            openOnFinished = false
        }
    }

    Label {
        Layout.leftMargin: 48

        text: author.displayName

        visible: avatarVisible

        font.pixelSize: 13
        verticalAlignment: Text.AlignVCenter
    }

    RowLayout {
        z: -5

        id: messageRow

        spacing: 4

        Avatar {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignTop

            visible: avatarVisible
            hint: author.displayName
            source: author.avatarMediaId

            Component {
                id: userDetailDialog

                UserDetailDialog {}
            }

            RippleEffect {
                anchors.fill: parent

                circular: true

                onClicked: userDetailDialog.createObject(ApplicationWindow.overlay, {"room": currentRoom, "user": author}).open()
            }
        }

        Label {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignTop

            visible: !(sentByMe || avatarVisible)

            text: Qt.formatDateTime(time, "hh:mm")
            color: "#5B7480"

            font.pixelSize: 10
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
        }

        BusyIndicator {
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64

            visible: img.status == Image.Loading
        }

        Image {
            Layout.maximumWidth: messageListView.width - (!sentByMe ? 32 + messageRow.spacing : 0) - 48

            id: img

            source: "image://mxc/" +
                    (content.info && content.info.thumbnail_info ?
                         content.thumbnailMediaId : content.mediaId)

            sourceSize.width: 720
            sourceSize.height: 720

            fillMode: Image.PreserveAspectCrop

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: img.width
                    height: img.height
                    radius: 24
                }
            }

            Rectangle {
                anchors.fill: parent

                visible: progressInfo.active && !downloaded

                color: "#BB000000"

                ProgressBar {
                    anchors.centerIn: parent

                    width: parent.width * 0.8

                    from: 0
                    to: progressInfo.total
                    value: progressInfo.progress
                }
            }

            RippleEffect {
                anchors.fill: parent

                id: messageMouseArea

                onPrimaryClicked: fullScreenImage.createObject(parent, {"filename": eventId, "localPath": currentRoom.urlToDownload(eventId)}).show()

                onSecondaryClicked: {
                    var contextMenu = imageDelegateContextMenu.createObject(ApplicationWindow.overlay)
                    contextMenu.viewSource.connect(function() {
                        messageSourceDialog.createObject(ApplicationWindow.overlay, {"sourceText": toolTip}).open()
                    })
                    contextMenu.downloadAndOpen.connect(downloadAndOpen)
                    contextMenu.saveFileAs.connect(saveFileAs)
                    contextMenu.reply.connect(function() {
                        roomPanelInput.replyUser = author
                        roomPanelInput.replyEventID = eventId
                        roomPanelInput.replyContent = message
                        roomPanelInput.isReply = true
                        roomPanelInput.focus()
                    })
                    contextMenu.redact.connect(function() {
                        currentRoom.redactEvent(eventId)
                    })
                    contextMenu.popup()
                }

                Component {
                    id: messageSourceDialog

                    MessageSourceDialog {}
                }

                Component {
                    id: openFolderDialog

                    OpenFolderDialog {}
                }

                Component {
                    id: imageDelegateContextMenu

                    FileDelegateContextMenu {}
                }

                Component {
                    id: fullScreenImage

                    FullScreenImage {}
                }
            }
        }
    }

    function saveFileAs() {
        var folderDialog = openFolderDialog.createObject(ApplicationWindow.overlay)

        folderDialog.chosen.connect(function(path) {
            if (!path) return

            currentRoom.downloadFile(eventId, path + "/" + currentRoom.fileNameToDownload(eventId))
        })

        folderDialog.open()
    }

    function downloadAndOpen()
    {
        if (downloaded) openSavedFile()
        else
        {
            openOnFinished = true
            currentRoom.downloadFile(eventId, Platform.StandardPaths.writableLocation(Platform.StandardPaths.CacheLocation) + "/" + eventId.replace(":", "_").replace("/", "_").replace("+", "_") + currentRoom.fileNameToDownload(eventId))
        }
    }

    function openSavedFile()
    {
        if (Qt.openUrlExternally(progressInfo.localPath)) return;
        if (Qt.openUrlExternally(progressInfo.localDir)) return;
    }
}
