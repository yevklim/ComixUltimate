import QtQuick 2.15
//import QtPositioning 5.15
//import QtGraphicalEffects 1.12
import QtQuick.Controls 2.15
//import QtQuick.Extras 1.4
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQml.Models 2.15
import QtQuick.Shapes 1.0
import ComixUltimate 1.0

Item {
    id: root
    clip: true
    property bool safeMode: window.safeMode
    readonly property int corners: 16
    property var item: {
        "type": 1,
        "source": "",
        "title": "",
        "cover": "",
        "added": 1584393258696,
        "lastview": 1586702793137,
        "tags": [],
        "rate": 5,
    }
    property var links: []
    function updateLinks() {
        links = Provider.get_real_links(item.hash, 0, root.linksNumber);
        visiblePages.updateLimit();
    }
    property int bigLIMIT: 100

    //TODO: implement BIG LIMITER (with button "VIEW MORE" at the end of current slice)
    property QtObject bitLimiter: PageLimiter {
        id: bigLimiter
        rangeSize: root.linksNumber
        maximumLimit: 100
    }
    property QtObject visiblePages: PageLimiter {
        id: visiblePages
        rangeSize: root.linksNumber
        minimumLimit: {
            if (item.type === 4 || item.type === 3) {
                return 3;
            }
            return 5;
        }
        maximumLimit: {
            if (item.type === 4 || item.type === 3) {
                return 3;
            }
            if (item.source.indexOf("file://") !== -1) {
                return 8;
            }
            return 24;
        }
        current: swipeView.currentIndex

        property int maximumReadinessDelta: 3

        function updateLimit() {
            if (item.type === 4 || item.type === 3) {
                return;
            }
            if (item.source.indexOf("file://") !== -1) {
                maximizeLimit();
                return;
            }
            let visibleArray = view.itemsArray.slice(first, last + 1);
            let readyArray = visibleArray.filter((item) => item.ready);
            let readinessDelta = limit - readyArray.length;
            let toDecrease = limit > 10 && readinessDelta > maximumReadinessDelta;
            let toIncrease = readinessDelta === 0;

            if (isViewerVisible && toIncrease) {
                increaseLimit();
//                console.info(
//                            "limit increased to",
//                            limit);
            }
            else
            if (isViewerVisible && toDecrease) {
                decreaseLimitTo(readyArray.length + maximumReadinessDelta);
//                console.info(
//                            "limit decreased to",
//                            limit);
            }
//            console.info(`limit: ${limit}, first: ${first}, last: ${last}, readinessDelta: ${readinessDelta}`);
        }
    }

    property int linksNumber: 0
    property alias slideshowInterval: slideshowTimer.interval
    property alias slideshowRunning: slideshowTimer.running
    property alias page: swipeView.currentIndex
    readonly property int lastpage: Math.max(linksNumber - 1, 0)
    readonly property int pages: linksNumber

    property bool isViewerVisible: true
    property alias bottombarComponent: bottombar_component
    width: 1080

    function nextPage() { swipeView.incrementCurrentIndex() }
    function prevPage() { swipeView.decrementCurrentIndex() }
    function lastPage() { page = lastpage }
    function firstPage() { page = 0 }

    onPageChanged: if (slideshowTimer.running && !safeMode) slideshowTimer.restart();
    onSafeModeChanged: slideshowTimer.stop();
    function set_as_cover() {
        item.cover = Provider.get_real_link(root.item.hash, page);
    }
    //TODO: implement efficient item reopening
    function openItem(item) {
        resetItems();
        item.update_lastview();
        root.item = item;
        updateLinks();
        Provider.requestLinks(item.source);
    }
    function resetItems() {
        links = [];
        root.linksNumber = 0;
//        root.page = 0;
        visiblePages.resetLimit();
        for (let itemObj of view.itemsArray) {
            swipeView.removeItem(itemObj);
        }
        view.itemsArray.length = 0;
    }
    function setItems(all_items : Number) {
        if (all_items !== root.linksNumber) {
            resetItems();
            addItems(all_items);
        }
    }
    function addItems(items : Number) {
        let i = root.linksNumber;
        root.linksNumber += items;
        updateLinks();
        for (; i < root.linksNumber; i++) {
            view.itemsArray.push(viewerItemDelegate.createObject(swipeView,
                                                               {
//                                                                   index: i,
//                                                                   modelData: Qt.binding(() => Provider.get_real_link(item.hash, i))
                                                               }));
        }
    }

    Component.onCompleted: {
        Provider.linkFixed.connect((hash, index, fixedLink) => {
            if (item.hash === hash) {
//                console.log("Tried to fix link", index, fixedLink)
                swipeView.itemAt(index).mediaSource = fixedLink;
//                console.log("link fixed");
            }
        })
    }
    /*      virtual void show(const IDataBaseItem &item) = 0;
            virtual ViewMode get_view_mode() = 0;
            virtual void set_view_mode(ViewMode mode) = 0;     */

    focus: true
    Keys.enabled: true
    Keys.priority: Keys.BeforeItem
    Keys.onPressed: function (event) {
        if (event.key == Qt.Key_Left || event.key == Qt.Key_J) {
            root.prevPage()
            event.accepted = true;
        }
        else if (event.key == Qt.Key_Right || event.key == Qt.Key_L) {
            root.nextPage()
            event.accepted = true;
        }
        else if (event.key == Qt.Key_Down || event.key == Qt.Key_K) {
            window.safeMode = !window.safeMode;
            event.accepted = true;
        }
//        else if (event.key == Qt.Key_T) { // TEST
//            let i = COMICS.comics.indexOf(item);
//            root.item = COMICS.comics[i > 0 ? i - 1 : 0]
//        }
//        else if (event.key == Qt.Key_Y) { // TEST
//            let i = COMICS.comics.indexOf(item),
//                size = COMICS.comics.length;
//            root.item = COMICS.comics[i < size - 1 ? i + 1 : size - 1]
//        }
    }

    CustomTimer {
        id: slideshowTimer
        interval: timerSlider.value * 1000; running: false; repeat: true
        updateInterval: 100
        onTriggered: {
            if (!reversedBtn.checked) {
                root.nextPage();
            }
            else {
                root.prevPage();
            }
        }
        //TODO: add options for timer
    }
    LittlePopup {
        id: timerOptions

        property int x1: root.width - width - margins
        property int y1: root.height - height - margins - 48// 48 - height of bottombar
        x: x1
        y: y1

        margins: 16

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; /*duration: 900;*/ }
//            NumberAnimation { property: "y"; from: root.height; to: timerOptions.y1; duration: 300; }
        }

        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; /*duration: 300;*/ }
//            NumberAnimation { property: "y"; from: timerOptions.x1; to: root.height; duration: 900; }
        }

        backgroundItem {
            topLeftCorner: 16
            bottomRightCorner: 16
        }
        contentItem: Column {
            spacing: 8
            Row {
                Text {
                    text: qsTr("Slideshow")
                    color: Palettes.current.barFg
                    font.pixelSize: 20
                    width: 144
                }
                Text {
                    text: timerSlider.value + qsTr("s")
                    color: Palettes.current.barFg
                    width: 48
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Row {
//                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 1
                CustomButton {
                    id: reversedBtn
                    text: "Reversed"
                    checkable: true;
                    checked: false;
                    backgroundItem {
                        topLeftCorner: 12
                    }
                    contentItemFont {
                        pixelSize: 16
                    }
                    leftPadding: 16
                    rightPadding: 16
                    height: 48
                    width: 96
                }
                IconButton2 {
                    id: timerPlayBtn
                    side: 48
                    checkable: true
                    icon_ref {
                        iconCode: "play"
                        iconSize: 32
                        layer.samples: 8
                    }
                    onClicked: {
                        slideshowTimer.start();
                        checked = true;
                        timerPauseBtn.checked = false;
                    }
                }
                IconButton2 {
                    id: timerPauseBtn
                    side: 48
                    checkable: true
                    icon_ref {
                        iconCode: "pause"
                        iconSize: 32
                    }
                    backgroundItem {
                        bottomRightCorner: 12
                    }
                    onClicked: {
                        slideshowTimer.stop();
                        checked = true;
                        timerPlayBtn.checked = false;
                    }
                }
            }
            CustomSlider {
                id: timerSlider
                stepSize: 0.5
                from: 1
                value: 5
                to: 20
                width: 192
                height: 36
            }
            CustomProgressBar {
                id: timerProgress
                value: slideshowTimer.currentValue / slideshowTimer.interval
                width: 192
                height: 33
                Component.onCompleted: {
                    slideshowTimer.currentValueUpdated.connect(value => {
                                                                   timerProgress.value = value / slideshowTimer.interval;
//                                                                   console.log(value);
                                                               })
                }
            }
        }
    }

    Item {
        id: view
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 0
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        Keys.forwardTo: root
        property var itemsArray: []
        SwipeView {
            id: swipeView
            anchors.fill: parent
            Keys.forwardTo: root

//            onCurrentIndexChanged: visiblePages.current = Qt.binding(() => swipeView.currentIndex);

//            Repeater {
//                id: repeater
//                delegate: ViewerItemDelegate
//                model: root.links
//            }
        }
    }

    Component {
        id: viewerItemDelegate
        Loader {
            id: itemloader
            property int index: SwipeView.index
            //            active: !toOptimize2
            property bool isActiveNow: index === swipeView.currentIndex && !safeMode && root.isViewerVisible
            property bool toOptimize1: (index < swipeView.currentIndex - 2 || index > swipeView.currentIndex + 2)
            property bool toOptimize2: (index < visiblePages.first || index > visiblePages.last) ||
                         (!root.isViewerVisible && index !== swipeView.currentIndex)
            property bool safeMode: root.safeMode
            active: !toOptimize2

            sourceComponent: ItemViewerItem {
                //            required  property var modelData
//                property int index: parent.SwipeView.index
                //            active: !toOptimize2
                isActiveNow: itemloader.isActiveNow//index === swipeView.currentIndex && !safeMode && root.isViewerVisible
                toOptimize1: itemloader.toOptimize1//(index < swipeView.currentIndex - 2 || index > swipeView.currentIndex + 2)
                toOptimize2: itemloader.toOptimize2/*(index < visiblePages.first || index > visiblePages.last) ||
                             (!root.isViewerVisible && index !== swipeView.currentIndex)*/

                mediaSource: /*modelData*/""
                safeMode: root.safeMode
                Component.onCompleted: {
                    let source = root.links[index];
                    if (source === undefined) {
                        mediaSource = Provider.get_real_link(item.hash, index);
                    }
                    else {
                        mediaSource = source;
                    }
                }
                onReadyChanged: {
                    visiblePages.updateLimit();
                }
                handleMediaError: function(source) {
                    Provider.fix_real_link(root.item.hash, index);
                }
            }
        }

    }

    Component {
        id: bottombar_component
        BottomBar {
            Keys.forwardTo: root
            id: bottombar
            height: 48
            centerbar_ref.items: [
                BarItemWrapper {
                    IconButton2 {
                        id: firstpage_btn
                        corners: bottombar.centerbar_ref.contentCorners
                        side: bottombar.centerbar_ref.availableHeight
                        icon_ref {
                            iconCode: "first"
                            iconSize: 32
                        }
                        onClicked: root.firstPage();
                    }
//                    isVisible: bottombar.centerbar_ref.shown
                },
                BarItemWrapper {
                    IconButton2 {
                        id: prevpage_btn
                        corners: bottombar.centerbar_ref.contentCorners
                        side: bottombar.centerbar_ref.availableHeight
                        icon_ref {
                            iconCode: "prev"
                            iconSize: 32
                        }
                        onClicked: root.prevPage()
                    }
//                    isVisible: bottombar.centerbar_ref.shown
                },
                BarItemWrapper {
                    TextInputButton {
                        id: current_page_num
                        width: /*bottombar.centerbar.extended ? */label1.width + leftPadding + rightPadding/* : height*/
    //                    width: implicitWidth
                        corners: bottombar.centerbar_ref.contentCorners
                        height: bottombar.centerbar_ref.availableHeight
                        rightPadding: 8
                        leftPadding: 8
//                        fgColorPressed: Palettes.current.barBg
                        label1 {
                            text: (root.page + 1) + qsTr(" of ") + root.pages
                            font.pixelSize: 24
                            opacity: bottombar.centerbar_ref.shown && current_page_num.state === "" ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                        }
                        label2 {
                            text: root.page + 1
                            opacity: bottombar.centerbar_ref.shown || current_page_num.state !== "" ? 0 : 1
                            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                        }
                        textInput {
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: root.page + 1
//                            color: Palettes.current.barFg
//                            selectedTextColor: Palettes.current.barBg
//                            selectionColor: Palettes.current.barFg
                            onEditingFinished: {
                                root.page = Math.min(Math.max(Number(current_page_num.textInput.text) - 1, 0), root.lastpage)
                                current_page_num.textInput.text = Qt.binding(() => (root.page + 1))
//                                console.log(root.isViewerVisible);
                            }
                            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                        }

                        function setText(new_text) {
                            textInput.text = new_text;
                        }
                        Component.onCompleted: {
                            //
                        }
    //                    Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.InQuad } }
                    }
    //                isVisible: true
    //                isVisible: bottombar.centerbar.extended
                },
                BarItemWrapper {
                    IconButton2 {
                        id: nextpage_btn
                        corners: bottombar.centerbar_ref.contentCorners
                        side: bottombar.centerbar_ref.availableHeight
                        icon_ref {
                            iconCode: "next"
                            iconSize: 32
                        }
                        onClicked: root.nextPage()
                    }
//                    isVisible: bottombar.centerbar_ref.shown
                },
                BarItemWrapper {
                    IconButton2 {
                        id: lastpage_btn
                        corners: bottombar.centerbar_ref.contentCorners
                        side: bottombar.centerbar_ref.availableHeight
                        icon_ref {
                            iconCode: "last"
                            iconSize: 32
                        }
                        onClicked: root.lastPage()
                    }
//                    isVisible: bottombar.centerbar_ref.shown
                }
            ]
            rightbar_ref.items: [
                BarItemWrapper {
                    IconButton2 {
                        id: edit_btn
                        corners: bottombar.rightbar_ref.contentCorners
                        side: bottombar.rightbar_ref.availableHeight
                        icon_ref {
                            iconCode: "edit"
                            iconSize: 32
                        }
                        onClicked: {}
                    }
//                    isVisible: bottombar.rightbar_ref.shown
                },
                BarItemWrapper {
                    IconButton2 {
                        id: get_source_btn
                        corners: bottombar.rightbar_ref.contentCorners
                        side: bottombar.rightbar_ref.availableHeight
                        icon_ref {
                            iconCode: "source"
                            iconSize: 32
                        }
                        onClicked: {}
                    }
//                    isVisible: bottombar.rightbar_ref.shown
                },
                BarItemWrapper {
                    IconButton2 {
                        id: set_as_cover_btn
                        corners: bottombar.rightbar_ref.contentCorners
                        side: bottombar.rightbar_ref.availableHeight
                        icon_ref {
                            iconCode: "set-as-cover"
                            iconSize: 48
                        }
                        onClicked: set_as_cover()
                    }
//                    isVisible: bottombar.rightbar_ref.shown
                },
                BarItemWrapper {
                    IconButton2 {
                        id: add_to_playlist_btn
                        corners: bottombar.rightbar_ref.contentCorners
                        side: bottombar.rightbar_ref.availableHeight
                        icon_ref {
                            iconCode: "add-to-playlist"
                            iconSize: 48
                        }
                        onClicked: {}
                    }
//                    isVisible: bottombar.rightbar_ref.shown
                },
                BarItemWrapper {
                    IconButton2 {
                        id: favorite_btn
                        corners: bottombar.rightbar_ref.contentCorners
                        side: bottombar.rightbar_ref.availableHeight
                        icon_ref {
                            iconCode: "favorite"
                            iconSize: 32
                        }
                        onClicked: {}
                    }
//                    isVisible: bottombar.rightbar_ref.shown
                },
                BarItemWrapper {
                    IconButton2 {
                        id: slideshow_btn
                        corners: bottombar.rightbar_ref.contentCorners
                        side: bottombar.rightbar_ref.availableHeight
                        icon_ref {
                            iconCode: "play"//TODO: new icon
                            iconSize: 48
                        }
                        onClicked: {
                            if (!timerOptions.opened) {
                                timerOptions.open();
                            }
                        }
                        Component.onCompleted: {
                            //
                        }
                    }
//                    isVisible: bottombar.rightbar_ref.shown || timerOptions.opened
                },
                BarItemWrapper {
                    IconButton2 {
                        id: visibility_btn
                        corners: bottombar.rightbar_ref.contentCorners
                        side: bottombar.rightbar_ref.availableHeight
                        icon_ref {
                            iconCode: window.safeMode ? "visibility-off" : "visibility-on"
                            iconSize: 48
                            layer.samples: 8
                        }
                        onClicked: window.safeMode = !window.safeMode
                    }
    //                isVisible: bottombar.rightbar_ref.extended
                }
            ]
    //        anchors.left: parent.left
    //        anchors.right: parent.right
    //        anchors.bottom: parent.bottom
    //        anchors.leftMargin: 0
    //        anchors.rightMargin: 0
    //        anchors.bottomMargin: 0
        }
    }

}

/*##^##
Designer {
    D{i:0;formeditorZoom:2}
}
##^##*/
