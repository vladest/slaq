import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import ".."
import "../pages"

import com.iskrembilen 1.0

Drawer {
    id: filesSharesDialog

    y: Theme.paddingMedium
    bottomMargin: Theme.paddingMedium

    edge: Qt.RightEdge
    width: 0.3 * window.width
    height: window.height - Theme.paddingMedium
    property int currentPage: -1
    property int totalPages: -1
    property string teamId: teamsSwipe.currentItem.item.teamId

    function fetchData() {
        if (radioGroup.checkedButton == allFilesButton) {
            listView.model.retreiveFilesFor("", "")
        } else if (radioGroup.checkedButton == myFilesButton) {
            var selfUser = SlackClient.selfUser(teamId)
            listView.model.retreiveFilesFor("", selfUser.userId)
        } else if (radioGroup.checkedButton == channelFilesButton) {
            listView.model.retreiveFilesFor(teamsSwipe.currentItem.item.currentChannelId, "")
        }
    }

    onOpened: {
        listView.model = SlackClient.getFilesSharesModel(teamId)
        fetchData()
    }
    ButtonGroup {
        id: radioGroup
        onCheckedButtonChanged: {
            if (filesSharesDialog.opened) {
                fetchData()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.paddingSmall
        spacing: Theme.paddingMedium

        RowLayout {
            Layout.fillWidth: true
            Button {
                id: allFilesButton
                checkable: true
                ButtonGroup.group: radioGroup
                text: qsTr("All files")
            }
            Button {
                id: myFilesButton
                checkable: true
                ButtonGroup.group: radioGroup
                checked: true
                text: qsTr("My files")
            }
            Button {
                id: channelFilesButton
                checkable: true
                ButtonGroup.group: radioGroup
                text: qsTr("Channel files")
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollIndicator.vertical: ScrollIndicator { }
            verticalLayoutDirection: ListView.BottomToTop
            clip: true
            spacing: Theme.paddingMedium
            delegate: Item {
                id: delegate
                width: listView.width - listView.ScrollIndicator.vertical.width
                property FileShare fileShare: model.FileShareObject
                height: Theme.avatarSize
                RowLayout {
                    width: parent.width
                    Image {
                        source: fileShare.thumb_64 != "" ? "team://" + teamId + "/" + fileShare.thumb_64 :
                                    SlackClient.resourceForFileType(fileShare.filetype, fileShare.name)
                        sourceSize: Qt.size(Theme.avatarSize, Theme.avatarSize)
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        height: Theme.avatarSize
                        Label {
                            id: name
                            Layout.fillWidth: true
                            text: fileShare.title
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Label {
                                text: qsTr("Created by ") + delegate.fileShare.user.username + " at " + Qt.formatDateTime(delegate.fileShare.created, "dd MMM yyyy hh:mm")
                            }
                            Image {
                                source: delegate.fileShare.user.avatarUrl
                                sourceSize: Qt.size(Theme.avatarSize/2, Theme.avatarSize/2)
                            }
                        }
                    }
                }
            }
        }
    }
}