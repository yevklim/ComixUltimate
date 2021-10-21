import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQml.Models 2.15
import "./MaterialIcons/MaterialIcons-Regular.js" as MD
import ComixUltimate 1.0

ApplicationWindow {
    id: window
    width: 960
    height: 640
    visible: true
    color: Palettes.current.appBg
    title: qsTr("ComixUltimate")

    property bool closing: false
    property bool safeMode: false

    function resetPopup() { //CHECK FOR BUG
        if (popup_loader.sourceComponent != undefined) {
            if (popup.opened) {
                popup.close();
            }
            popup_loader.sourceComponent = undefined;
            popup_loader.itemProperties = {};
        }
    }
    function showPopup(popupSrc, properties) {
        resetPopup();

        popup_loader.itemProperties = properties;
        popup_loader.sourceComponent = popupSrc;

        popup.open();
    }

    Loader {
        //TODO: accidentally closed popups
        id: popup_loader
        sourceComponent: null
        anchors.centerIn: parent
        property var itemProperties: ({})
        onLoaded: {
            for (let prop of Object.keys(itemProperties)) {
                item[prop] = Qt.binding(() => (itemProperties[prop]));
            }
            item["resetPopup"] = Qt.binding(() => (window.resetPopup));
            item.maximumWidth = Qt.binding(() => Math.round(window.width *.75))
            item.maximumHeight = Qt.binding(() => Math.round(window.height *.75))
        }
    }
    property alias popup: popup_loader.item

    SwipeView {
        id: swipeView
        anchors.fill: parent
//        orientation: Qt.Vertical
        SwipeView {
            id: libsSwipeView
            orientation: Qt.Vertical
            property Component bottombarComponent: libsSwipeView.currentItem.bottombarComponent ? libsSwipeView.currentItem.bottombarComponent : Item
            ItemsLibrary {
                id: itemsLibrary
                model: /*DataBase.items*/[]
                itemsDensity: 18
                Component.onCompleted: {
                    DataBaseViewer.sendItems.connect(items => { itemsLibrary.model = items });
                    DataBaseViewer.requestItems();
                }
    //            anchors.fill: parent
//                property alias safeMode: window.safeMode
    //            isViewerVisible: SwipeView.isCurrentItem
                openItemFunction: function(item) {
                    itemViewer.openItem(item);
                    swipeView.currentIndex = itemViewer.SwipeView.index
                }
            }

            ItemsLibrary {
                id: historyLibrary
                model: []
                itemsDensity: 18
                Component.onCompleted: {
                    HistoryViewer.sendItems.connect(items => { historyLibrary.model = items });
                    HistoryViewer.requestItems();
                }
    //            anchors.fill: parent
//                property alias safeMode: window.safeMode
    //            isViewerVisible: SwipeView.isCurrentItem
                openItemFunction: itemsLibrary.openItemFunction
            }

            property var currentViewer: currentIndex === 0 ? DataBaseViewer : HistoryViewer
        }
        //TODO: after image optimizations create playlists system
        ItemViewer {
            id: itemViewer
//            anchors.fill: parent
//            property alias safeMode: window.safeMode
//            isViewerVisible: SwipeView.isCurrentItem
            function showItem(url, links_num) {
                if (itemViewer.item.source === url) {
                    itemViewer.setItems(links_num);
                }
            }
            function loadItemPart(url, links_num, toEnd, toBegin) {
                if (itemViewer.item.source === url) {
                    itemViewer.addItems(links_num, toEnd, toBegin);
                }
            }
            Component.onCompleted: {
                Provider.completelyReady.connect(showItem);
                Provider.partiallyReady.connect(loadItemPart);
            }
        }
    }

    Loader {
        id: bottombar
//        sourceComponent: itemsLibrary.SwipeView.isCurrentItem ? itemsLibrary.bottombarComponent : itemViewer.bottombarComponent
        sourceComponent: swipeView.currentItem.bottombarComponent ? swipeView.currentItem.bottombarComponent : Item
//        opacity: (item.centerbar_ref.extended || item.rightbar_ref.extended) ? 1 : .1
//        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        height: 48
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
    }

    TopBar {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        slide.container {
            spacing: 8
//            topPadding: 0
//            leftPadding: 8
//            rightPadding: 8
//            bottomPadding: corners
        }
        slide2.container {
            spacing: 8
//            topPadding: 0
//            leftPadding: 8
//            rightPadding: 8
//            bottomPadding: corners
        }
        bar.items: [
            CustomTextField {
                id: search_input
                background: null
                palette.text: Palettes.current.barFg
                width: 216
                height: topBar.bar.availableHeight
                color: Palettes.current.barFg
                selectedTextColor: Palettes.current.barBg
                selectionColor: Palettes.current.barFg
                font.pixelSize: 24
                verticalAlignment: Text.AlignVCenter
                placeholderText: "Search"
                onTextChanged: {
                    if (libsSwipeView.currentViewer.filter_params.title !== (text).trim()) {
                        libsSwipeView.currentViewer.filter_params.title = (text).trim();
                        text = Qt.binding(() => libsSwipeView.currentViewer.filter_params.title);
                    }
                }
                Component.onCompleted: {
                    text = Qt.binding(() => libsSwipeView.currentViewer.filter_params.title);
                }
            }
        ]
        slide.items: [
            Item {
                width: topBar.slide.availableWidth
                height: 32
//                    QuteShape {
//                        anchors.fill: parent
//                        corners: 12
//                        topLeftCorner: corners
//                        bottomRightCorner: corners
//                        path {
//                            fillColor: Palettes.current.barBg
//                        }
//                    }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.right: parent.right//filters_reset_icon.left
                    anchors.rightMargin: 8
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Filter Parameters")
                    color: Palettes.current.barFg
                }
//                    IconButton {
//                        id: filters_reset_icon
//                        anchors.right: parent.right
//                        anchors.verticalCenter: parent.verticalCenter
//                        corners: 8
//                        topLeftCorner: corners
//                        bottomRightCorner: corners
//                        source: "Images/UI Elements/reset_24.svg"
//                    }
            },
            Item {
                width: topBar.slide.availableWidth
                height: 32
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Source")
                    color: Palettes.current.barFg
                    width: 64
                }
                TextInput {
                    id: filter_params_source_input
                    anchors.left: parent.left
                    anchors.leftMargin: 64
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onTextChanged: {
                        if (libsSwipeView.currentViewer.filter_params.source !== (text).trim()) {
                            libsSwipeView.currentViewer.filter_params.source = (text).trim();
                            text = Qt.binding(() => libsSwipeView.currentViewer.filter_params.source);
                        }
                    }
                    Component.onCompleted: {
                        text = Qt.binding(() => libsSwipeView.currentViewer.filter_params.source);
                    }
                    color: Palettes.current.barFg
                }
            },
            Item {
                width: topBar.slide.availableWidth
                height: 32
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Tags")
                    color: Palettes.current.barFg
                    width: 64
                }
                //TODO: autocomplete tags
                TextInput {
                    id: filter_params_tags
                    anchors.left: parent.left
                    anchors.leftMargin: 64
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onTextChanged: {
                        let tags = [];
                        for(let tag of (text).toLowerCase().split(";")) {
                            tag = tag.trim();
                            if(tags.indexOf(tag) === -1 && tag.length !== 0) {
                                tags.push(tag);
                            }
                        }
                        //                                    console.log(tags);
                        if (libsSwipeView.currentViewer.filter_params.tags !== tags) {
                            libsSwipeView.currentViewer.filter_params.tags = tags;
                            text = Qt.binding(() => libsSwipeView.currentViewer.filter_params.tags.join(";"));
                        }
                    }
                    Component.onCompleted: {
                        text = Qt.binding(() => libsSwipeView.currentViewer.filter_params.tags.join(";"));
                    }
                    color: Palettes.current.barFg
                }
            }
        ]
        slide2.items: [
            Item {
                width: topBar.slide2.availableWidth
                height: 32
//                    QuteShape {
//                        anchors.fill: parent
//                        corners: 12
//                        topLeftCorner: corners
//                        bottomRightCorner: corners
//                        path {
//                            fillColor: Palettes.current.barBg
//                        }
//                    }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.right: parent.right//sorting_reset_icon.left
                    anchors.rightMargin: 8
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Sorting Parameters")
                    color: Palettes.current.barFg
                }
//                    IconButton {
//                        id: sorting_reset_icon
//                        anchors.right: parent.right
//                        anchors.verticalCenter: parent.verticalCenter
//                        corners: 8
//                        topLeftCorner: corners
//                        bottomRightCorner: corners
//                        source: "Images/UI Elements/reset_24.svg"
//                    }
            },
            CustomToggle {
                width: topBar.slide2.availableWidth
                property var codenames: ["title", "source", "added", "lastview"].slice(libsSwipeView.currentViewer == DataBaseViewer ? 0 : 3)
                background {
                    corners: topBar.corners - topBar.slide2.container.padding
                }
                listview {
                    width: topBar.slide2.availableWidth
                    height: listview.contentHeight
                    orientation: Qt.Vertical
                    model: ["Title", "Source", "Added", "Last View"].slice(libsSwipeView.currentViewer == DataBaseViewer ? 0 : 3)
                    onCurrentIndexChanged: {
                        if (libsSwipeView.currentViewer.sorter_params.param !== codenames[listview.currentIndex]) {
                            libsSwipeView.currentViewer.sorter_params.param = codenames[listview.currentIndex];
                            listview.currentIndex = Qt.binding(() => codenames.indexOf(libsSwipeView.currentViewer.sorter_params.param));
                        }
                    }
                }
                autoWidth: false
//                                height: 32
                Component.onCompleted: {
                    listview.currentIndex = Qt.binding(() => codenames.indexOf(libsSwipeView.currentViewer.sorter_params.param));
                }
            },
            CustomToggle {
                width: topBar.slide2.availableWidth
                property var codenames: ["title", "source", "added", "lastview"].slice(libsSwipeView.currentViewer == DataBaseViewer ? 0 : 3)
                property bool isParamText: codenames.indexOf(libsSwipeView.currentViewer.sorter_params.param) < 2 && libsSwipeView.currentViewer == DataBaseViewer
                background {
                    corners: topBar.corners - topBar.slide2.container.padding
                }
                listview {
                    width: topBar.slide2.availableWidth
                    height: listview.contentHeight
                    orientation: Qt.Vertical
                    model: isParamText ? ["A-Z", "Z-A"] : ["New-Old", "Old-New"]
                    onCurrentIndexChanged: {
                        libsSwipeView.currentViewer.sorter_params.alphabet = true;
                        let reversed = Boolean(isParamText ^ (listview.currentIndex === 0));
                        if (libsSwipeView.currentViewer.sorter_params.reversed !== reversed) {
                            libsSwipeView.currentViewer.sorter_params.reversed = reversed;
                            listview.currentIndex = Qt.binding(() => (!isParamText ^ libsSwipeView.currentViewer.sorter_params.reversed));
                        }
                    }
                }

                autoWidth: false
                Component.onCompleted: {
                    listview.currentIndex = Qt.binding(() => (!isParamText ^ libsSwipeView.currentViewer.sorter_params.reversed));
                }
            }
        ]
    }

    SideBar {
        id: sideBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
//        opacity: sideBar.bar_ref.extended ? 1 : .1
//        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        bar_ref.items: [
            Item {
                width: sideBar.bar_ref.availableWidth
                height: width
                Icon {
                    id: menu_icon
                    anchors.centerIn: parent
                    iconCode: "menu"
                    iconSize: 32
                    layer.samples: 8
                }
            },
            IconButton2 {
                id: home_btn
                corners: sideBar.bar_ref.contentCorners
                side: sideBar.bar_ref.availableWidth
                icon_ref {
                    iconCode: "home"
                    iconSize: 48
                    layer.samples: 8
                }
                onClicked: {
//                    showPopup(Popups.palettesEditor);
                }
            },
            IconButton2 {
                id: toggle_btn
                corners: sideBar.bar_ref.contentCorners
                side: sideBar.bar_ref.availableWidth
                icon_ref {
                    iconCode: "settings"
                    iconSize: 48
                    layer.samples: 8
                }
                onClicked: {
                    showPopup(Popups.palettesEditor, ({}));
                }
            },
            IconButton2 {
                id: library_btn
                corners: sideBar.bar_ref.contentCorners
                side: sideBar.bar_ref.availableWidth
                icon_ref {
                    iconCode: "library"
                    iconSize: 48
                }
                onClicked: {
                    libsSwipeView.currentIndex = itemsLibrary.SwipeView.index
                    swipeView.currentIndex = libsSwipeView.SwipeView.index;
                }
            },
            IconButton2 {
                id: playlists_btn
                corners: sideBar.bar_ref.contentCorners
                side: sideBar.bar_ref.availableWidth
                icon_ref {
                    iconCode: "playlists"
                    iconSize: 48
                }
                onClicked: {}
            },
            IconButton2 {
                id: queue_btn
                corners: sideBar.bar_ref.contentCorners
                side: sideBar.bar_ref.availableWidth
                icon_ref {
                    iconCode: "queue"
                    iconSize: 48
                }
                onClicked: {}
            },
            IconButton2 {
                id: history_btn
                corners: sideBar.bar_ref.contentCorners
                side: sideBar.bar_ref.availableWidth
                icon_ref {
                    iconCode: "history-alt"
                    iconSize: 48
                }
                onClicked: {
                    libsSwipeView.currentIndex = historyLibrary.SwipeView.index
                    swipeView.currentIndex = libsSwipeView.SwipeView.index;
                }
            },
            IconButton2 {
                id: shuffled_library_btn
                corners: sideBar.bar_ref.contentCorners
                side: sideBar.bar_ref.availableWidth
                icon_ref {
                    iconCode: "shuffled-library"
                    iconSize: 48
                }
                onClicked: {}
            },
            IconButton2 {
                id: settings_btn
                corners: sideBar.bar_ref.contentCorners
                side: sideBar.bar_ref.availableWidth
                icon_ref {
                    iconCode: "settings"
                    iconSize: 48
                }
                onClicked: {}
            },
            IconButton2 {
                id: saveDB_btn
                corners: sideBar.bar_ref.contentCorners
                side: sideBar.bar_ref.availableWidth
                icon_ref {
                    iconCode: "save"
                    iconSize: 32
                }
                onClicked: DataBase.save();
            }
        ]
    }

    FontLoader {
        id: iconFont
        source: "./MaterialIcons/MaterialIcons-Regular.ttf"
    }

}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.25}
}
##^##*/

