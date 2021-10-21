import QtQuick 2.15
//import QtPositioning 5.15
//import QtGraphicalEffects 1.12
import QtQuick.Controls 2.15
//import QtQuick.Extras 1.4
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQml.Models 2.15
import QtQuick.Shapes 1.0
import "./MaterialIcons/MaterialIcons-Regular.js" as MD
import ComixUltimate 1.0
//import "db.js" as DataBase

Item {
    id: root
    clip: true
    property var model: []// DataBase.items
    readonly property var visibleModel: model.slice(itemsDensity * pager.page, itemsDensity * (pager.page + 1));
    property int minDelegateWidth: 162
    property int itemsDensity: 48 //items per page
    readonly property QtObject pager: Pager {
        id: pager
        page: 0
        pages: Math.ceil(model.length / itemsDensity)
    }
    property bool safeMode: window.safeMode
    property int corners: 16
    readonly property int rowWidthWithoutPaddingWithSpacing: flow.width - flow.rightPadding - flow.leftPadding + flow.spacing
    readonly property int itemsPerRow: Math.floor(rowWidthWithoutPaddingWithSpacing / (minDelegateWidth + flow.spacing))
    readonly property int delegateWidth: Math.floor(rowWidthWithoutPaddingWithSpacing / itemsPerRow) - flow.spacing
    property bool isViewerVisible: true
    property alias bottombarComponent: bottombar_component
    property var openItemFunction

    ScrollView {
        id: scrollView
        anchors.fill: parent
        wheelEnabled: true
        contentWidth: width

        Flow {
            id: flow
            //anchors.fill: parent//????
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            padding: 32
            rightPadding: 48
            spacing: 24//16

            property var itemObjs: []

            Repeater {
                id: repeater
                anchors.fill: parent
                delegate: LibraryItem {
                    enabled: index < visibleModel.length
                    visible: enabled

                    model: enabled ? visibleModel[index] : emptyModel
                    width: root.delegateWidth
                    minWidth: root.minDelegateWidth
                    safeMode: root.safeMode
                    z: root.itemsDensity - index
                    isImageVisible: root.isViewerVisible
                    openItemFunction: root.openItemFunction
                    onItemFocus: {
                        for(let i = 0; i < visibleModel.length; i++) {
                            if(i !== index) {
                                if (repeater.itemAt(i)) repeater.itemAt(i).unfocusItem()
                            }
                        }
                    }
                }
                model: itemsDensity//root.model.slice(itemsPerPage * page, itemsPerPage * (page + 1));
            }
        }
    }

    Component {
        id: bottombar_component
        BottomBar {
            id: bottombar
//            height: 48
            centerbar_ref.items: [
                IconButton2 {
                    id: firstpage_btn
                    corners: bottombar.centerbar_ref.contentCorners
                    side: bottombar.centerbar_ref.availableHeight
                    icon_ref {
                        iconCode: "first"
                        iconSize: 32
                    }
                    onClicked: pager.toFirstPage();
                },
                IconButton2 {
                    id: prevpage_btn
                    corners: bottombar.centerbar_ref.contentCorners
                    side: bottombar.centerbar_ref.availableHeight
                    icon_ref {
                        iconCode: "prev"
                        iconSize: 32
                    }
                    onClicked: pager.page--;
                },
                TextInputButton {
                    id: current_page_num
                    corners: bottombar.centerbar_ref.contentCorners
                    width: /*bottombar.centerbar.extended ? */label1.width + leftPadding + rightPadding/* : height*/
//                    width: implicitWidth
                    height: bottombar.centerbar_ref.availableHeight
                    rightPadding: 8
                    leftPadding: 8
//                    fgColorDefault: Palettes.current.barFg
//                    fgColorPressed: Palettes.current.barBg
                    label1 {
                        text: (pager.page + 1) + qsTr(" of ") + pager.pages
                        font.pixelSize: 24
                        opacity: bottombar.centerbar_ref.shown && current_page_num.state === "" ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                    label2 {
                        text: pager.page + 1
                        opacity: bottombar.centerbar_ref.shown || current_page_num.state !== "" ? 0 : 1
                        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                    textInput {
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: pager.page + 1
//                        color: Palettes.current.barFg
//                        selectedTextColor: Palettes.current.barBg
//                        selectionColor: Palettes.current.barFg
                        onEditingFinished: {
                            pager.page = Number(current_page_num.textInput.text) - 1
                            if (current_page_num) {
                                current_page_num.textInput.text = Qt.binding(() => (pager.page + 1));
                            }
                        }
                        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
//                    Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.InQuad } }
                },
                IconButton2 {
                    corners: bottombar.centerbar_ref.contentCorners
                    id: nextpage_btn
                    side: bottombar.centerbar_ref.availableHeight
                    icon_ref {
                        iconCode: "next"
                        iconSize: 32
                    }
                    onClicked: pager.page++;
                },
                IconButton2 {
                    corners: bottombar.centerbar_ref.contentCorners
                    id: lastpage_btn
                    side: bottombar.centerbar_ref.availableHeight
                    icon_ref {
                        iconCode: "last"
                        iconSize: 32
                    }
                    onClicked: pager.toLastPage()
                }
            ]
            rightbar_ref.items: [
                IconButton2 {
                    corners: bottombar.rightbar_ref.contentCorners
                    id: add_new_item_btn
                    side: bottombar.rightbar_ref.availableHeight;
                    icon_ref {
                        iconCode: "add-new-item"
                        iconSize: 48
                    }
                    onClicked: {
                        showPopup(Popups.itemCreator, {"dataBase": DataBase});
                    }
                },
                IconButton2 {
                    corners: bottombar.rightbar_ref.contentCorners
                    id: gallery_view_mode_btn
                    side: bottombar.rightbar_ref.availableHeight
                    icon_ref {
                        iconCode: "gallery-view"
                        iconSize: 48
                    }
                    onClicked: {}
                },
                IconButton2 {
                    corners: bottombar.rightbar_ref.contentCorners
                    id: list_view_mode_btn
                    side: bottombar.rightbar_ref.availableHeight
                    icon_ref {
                        iconCode: "list-view"
                        iconSize: 48
                    }
                    onClicked: {}
                },
                IconButton2 {
                    corners: bottombar.rightbar_ref.contentCorners
                    id: visibility_btn
                    side: bottombar.rightbar_ref.availableHeight
                    icon_ref {
                        iconCode: window.safeMode ? "visibility-off" : "visibility-on"
                        iconSize: 48
                        layer.samples: 8
                    }
                    onClicked: window.safeMode = !window.safeMode
                }
            ]
//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.bottom: parent.bottom
//            anchors.leftMargin: 0
//            anchors.rightMargin: 0
//            anchors.bottomMargin: 0
        }

    }
}

/*##^##
Designer {
    D{i:0;height:432;width:400}
}
##^##*/

