import QtQuick 2.15
import QtQuick.Controls 2.15
//import QtGraphicalEffects 1.12
import Qt5Compat.GraphicalEffects
import QtQuick.Shapes 1.0

Item {
    id: root
    readonly property var emptyModel: {
        "type": 0,
        "source": "",
        "title": "",
        "cover": "",
        "added": 0,
        "lastview": 0,
        "tags": [],
        "rate": 0
    }
    property var model: emptyModel
    property var modelHost: {
        if (model == emptyModel) {
            return "";
        }
        else
        if (model.source.indexOf("file:") !== -1) {
            return "local"
        }
        return (new URL(model.source)).host.replace("www.", "")
    }
    property var itemviewer

    property alias labelColor: label.color
    property alias labelFontFamily: label.font.family
    property alias labelFontPixelSize: label.font.pixelSize
    property alias lastviewColor: lastview_label.color
    property alias lastviewFontfamily: lastview_label.font.family
    property alias lastviewFontPixelSize: lastview_label.font.pixelSize
    property bool safeMode: false
    property bool slideShown: itemFocused
    property bool itemFocused: false
    property real ratio: 1.4//1.618 // or 1.4142
    property int corners: width * 0.1
    property alias topLeftCorner: item_shape.topLeftCorner
    property alias topRightCorner: item_shape.topRightCorner
    property alias bottomLeftCorner: item_shape.bottomLeftCorner
    property alias bottomRightCorner: item_shape.bottomRightCorner
    property bool isImageVisible: true
    property var openItemFunction

    property real animationMultiplier: .5
    signal itemFocus()
    width: 162
    height: Math.round(width * ratio)
    property int minWidth: 162
    state: "itemFocused"

    function unfocusItem() { itemFocused = false }

    states: [
        State {
            name: "itemFocused"
            when: itemFocused === true
            PropertyChanges {
                target: item_blur
                radius: 48
            }
            PropertyChanges {
                target: item_opacitymask
                opacity: root.safeMode ? 0 : .5
            }
            PropertyChanges {
                target: label
                visible: true
                opacity: 1
            }
            PropertyChanges {
                target: lastview_label
                visible: true
                opacity: 1
            }
            PropertyChanges {
                target: hostRect
                visible: true
                opacity: 1
            }
        }
    ]

    Item {
        id: item_slide
        width: 32 + root.corners
        height: root.height
        x: root.width - item_slide.width
        opacity: 0
        state: "slideShown"

        Behavior on opacity { NumberAnimation { duration: 400 * animationMultiplier; easing.type: Easing.InOutQuad } }
        Behavior on x { NumberAnimation { duration: 400 * animationMultiplier; easing.type: Easing.InOutQuad } }

        states: [
            State {
                name: "slideShown"
                when: slideShown === true
                PropertyChanges {
                    target: item_slide
                    x: root.width - root.corners
                    opacity: 1
                }
            }
        ]

        SuperellipseShape {
            id: slide_shape
            width: item_slide.width
            height: item_slide.height
            anchors.fill: item_slide
//            corners: root.corners
            topRightCorner: root.corners
            bottomRightCorner: root.corners
            path {
                fillColor: Palettes.current.cardSlideBg
            }
//            visible: false
        }
        DropShadow {
            id: slide_shadow
            anchors.fill: item_slide
            horizontalOffset: 0
            verticalOffset: 0
            radius: 12
//            samples: 16
            color: Palettes.current.cardSlideShadow
            source: slide_shape
            visible: false
        }

        Column {
            id: column
            anchors.fill: parent
            spacing: 1
            anchors.leftMargin: root.corners

            topPadding: root.corners
            bottomPadding: root.corners

            IconButton2 {
                id: read
                bgColorDefault: Palettes.current.cardSlideBtnBg
                bgColorPressed: Palettes.current.cardSlideBtnPressedBg
                fgColorDefault: Palettes.current.cardSlideBtnFg
                fgColorPressed: Palettes.current.cardSlideBtnPressedFg
                icon_ref {
                    iconCode: "open"
                    iconSize: 32
                }
                backgroundRef {
                    topLeftCorner: width / 5
                    bottomLeftCorner: width / 5
                }
                onClicked: {
                    if (model != emptyModel) {
                        openItemFunction(root.model);
                    }
                }
            }

            IconButton2 {
                id: addtoplaylist
                bgColorDefault: Palettes.current.cardSlideBtnBg
                bgColorPressed: Palettes.current.cardSlideBtnPressedBg
                fgColorDefault: Palettes.current.cardSlideBtnFg
                fgColorPressed: Palettes.current.cardSlideBtnPressedFg
                icon_ref {
                    iconCode: "add-to-playlist"
                    iconSize: 32
                }
                backgroundRef {
                    topLeftCorner: width / 5
                    bottomLeftCorner: width / 5
                }
            }

            IconButton2 {
                id: addtoqueue
                bgColorDefault: Palettes.current.cardSlideBtnBg
                bgColorPressed: Palettes.current.cardSlideBtnPressedBg
                fgColorDefault: Palettes.current.cardSlideBtnFg
                fgColorPressed: Palettes.current.cardSlideBtnPressedFg
                icon_ref {
                    iconCode: "add-to-queue"
                    iconSize: 32
                }
                backgroundRef {
                    topLeftCorner: width / 5
                    bottomLeftCorner: width / 5
                }
            }

            IconButton2 {
                id: watchlater
                bgColorDefault: Palettes.current.cardSlideBtnBg
                bgColorPressed: Palettes.current.cardSlideBtnPressedBg
                fgColorDefault: Palettes.current.cardSlideBtnFg
                fgColorPressed: Palettes.current.cardSlideBtnPressedFg
                icon_ref {
                    iconCode: "watch-later"
                    iconSize: 32
                }
                backgroundRef {
                    topLeftCorner: width / 5
                    bottomLeftCorner: width / 5
                }
                onClicked: {
                    if (Date.now() - model.lastview < 10 * 1000) {
                        model.lastview = 0;
                    } else {
                        model.update_lastview();
                    }
//                    model["lastview"] = Date.now();
//                    DataBase.updateItem(model);
                }
            }

            IconButton2 {
                id: favorite
                bgColorDefault: Palettes.current.cardSlideBtnBg
                bgColorPressed: Palettes.current.cardSlideBtnPressedBg
                fgColorDefault: Palettes.current.cardSlideBtnFg
                fgColorPressed: Palettes.current.cardSlideBtnPressedFg
                icon_ref {
                    iconCode: "favorite"
                    iconSize: 32
                }
                backgroundRef {
                    topLeftCorner: width / 5
                    bottomLeftCorner: width / 5
                }
                onClicked: {
                    model["rate"] = 5;
//                    DataBase.updateItem(model);
                }
            }

            IconButton2 {
                id: get_source
                bgColorDefault: Palettes.current.cardSlideBtnBg
                bgColorPressed: Palettes.current.cardSlideBtnPressedBg
                fgColorDefault: Palettes.current.cardSlideBtnFg
                fgColorPressed: Palettes.current.cardSlideBtnPressedFg
                icon_ref {
                    iconCode: "source"
                    iconSize: 32
                }
                backgroundRef {
                    topLeftCorner: width / 5
                    bottomLeftCorner: width / 5
                }
            }

            IconButton2 {
                id: edit
                bgColorDefault: Palettes.current.cardSlideBtnBg
                bgColorPressed: Palettes.current.cardSlideBtnPressedBg
                fgColorDefault: Palettes.current.cardSlideBtnFg
                fgColorPressed: Palettes.current.cardSlideBtnPressedFg
                icon_ref {
                    iconCode: "edit"
                    iconSize: 32
                }
                backgroundRef {
                    topLeftCorner: width / 5
                    bottomLeftCorner: width / 5
                }
                onClicked: {
                    showPopup(Popups.itemEditor, {itemModel: root.model});
//                    popupWrapperSrc = Popups.itemEditor
//                    popupWrapperRef.show(root.model);
                }
            }
        }

    }

    Item {
        id: item_body
        anchors.fill: parent
//        width: slideShown ? root.width - item_slide.width : root.width
//        width: root.width
//        height: root.height
//        visible: false

        SuperellipseShape {
            id: item_shape
            anchors.fill: parent
            corners: root.corners
//            topLeftCorner: root.corners
//            bottomRightCorner: root.corners
            path {
                fillColor: Palettes.current.cardBg
            }
//            visible: false
        }

        DropShadow {
            id: item_shadow
            anchors.fill: image
            horizontalOffset: 0
            verticalOffset: 0
            radius: 12
//            samples: 16
            color: Palettes.current.cardShadow
            source: item_shape
            visible: false
        }
        LoadingSpinner {
            enabled: image.status === Image.Loading;
            opacity: image.status === Image.Loading ? 1 : 0
            diameter: root.width * .5
            width: parent.width; height: parent.height
            anchors.horizontalCenterOffset: 0
            anchors.verticalCenterOffset: 0
            anchors.centerIn: parent
            loaderColor: Palettes.current.cardSpinner
            circles: 8
            loaderStrokeWidth: 4
            loaderSpeed: 12
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }
        Image {
            id: image
            anchors.fill: parent
            source: root.isImageVisible ? model["cover"] : ""
//            height: width * proportion
//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.top: parent.top
//            smooth: true
            mipmap: true
//            antialiasing: true
//            anchors.rightMargin: 0
//            anchors.leftMargin: 0
//            anchors.topMargin: 0
            asynchronous: true
            cache: true
            autoTransform: true
            sourceSize {
                width: root.minWidth * 2
                height: Math.round(root.minWidth * ratio) * 2
            }
//            mirror: false
            fillMode: Image.PreserveAspectCrop

            visible: false
//            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }

        FastBlur {
            id: item_blur
            anchors.fill: image
            source: image
            radius: 0
            visible: false
            Behavior on radius { NumberAnimation { duration: 400 * animationMultiplier; easing.type: Easing.InOutQuad } }
        }

//        ItemVisible {
//            id: itemVisible
//            anchors.fill: parent
//        }
        OpacityMask {
            id: item_opacitymask
            anchors.fill: image
            source: item_blur //image
            maskSource: item_shape

//            opacity: root.safeMode || image.status !== Image.Ready || image.status !== Image.Error ? 0 : 1
            opacity: (image.status === Image.Error || image.status === Image.Ready) && !root.safeMode ? 1 : 0
//            visible: itemVisible.visible
            Behavior on opacity { NumberAnimation { duration: 200 * animationMultiplier; easing.type: Easing.InOutQuad } }
        }

        Image {
            id: error_image
            source: image.status === Image.Error && root.isImageVisible ? "Images/UI Elements/error_2.svg" : ""
            anchors.centerIn: parent
            opacity: image.status === Image.Error && root.isImageVisible ? 1 : 0
        }

        Label {
            id: label
            x: 0
            //        visible: false
            text: qsTr(model["title"])
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            //        anchors.top: image.bottom
            //
            font.family: "Google Sans Medium"
            font.pixelSize: 14
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
            anchors.topMargin: root.corners
            padding: 0
            //        anchors.topMargin: 0
            //
            anchors.rightMargin: root.corners
            anchors.leftMargin: root.corners

            opacity: 0
            visible: true
            color: Palettes.current.cardFg
            Behavior on opacity { NumberAnimation { duration: 200 * animationMultiplier; easing.type: Easing.InOutQuad } }
        }

        Label {
            id: lastview_label
            x: 0
            y: 1010
            //        visible: false
            text: model.lastview !== 0
                  ? qsTr("Last view: ") + "\n" + new Date(model.lastview).toLocaleString()
                  : qsTr("Never viewed")
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: hostRect.top
            anchors.leftMargin: root.corners
            anchors.rightMargin: root.corners
            anchors.bottomMargin: root.corners
            font.pixelSize: 14
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignBottom
            wrapMode: Text.WordWrap
            font.family: "Google Sans Medium"
            padding: 0
            //        anchors.topMargin: 0

            opacity: 0
            visible: true
            color: Palettes.current.cardFg
            Behavior on opacity { NumberAnimation { duration: 200 * animationMultiplier; easing.type: Easing.InOutQuad } }
        }
        Rectangle {
            id: hostRect
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            color: "transparent"
            height: hostLabel.height + root.corners * 2
            clip: true
            opacity: 0
            Behavior on opacity { NumberAnimation { duration: 200 * animationMultiplier; easing.type: Easing.InOutQuad } }

            SuperellipseShape {
                anchors.fill: parent
//                corners: root.corners
                bottomLeftCorner: root.corners
                bottomRightCorner: root.corners
                path {
                    fillColor: Palettes.current.cardFg
                }
                opacity: .618
            }

            Label {
                id: hostLabel
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: root.corners
                anchors.rightMargin: root.corners
                anchors.bottomMargin: root.corners
                text: root.modelHost
                font.pixelSize: 14
                font.family: "Google Sans Medium"
//                font.capitalization: Font.AllUppercase
                padding: 0
                color: Palettes.current.cardBg
            }
        }

        MouseArea {
            id: item_mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.AllButtons
            onClicked: function (mouse) {
                if (mouse.button == Qt.LeftButton) {
                    // Read Item
                }
                else if (mouse.button == Qt.RightButton) {
                    root.itemFocus();
                    root.itemFocused = !root.itemFocused;
                }
            }
        }


    }

}








