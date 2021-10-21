import QtQuick 2.15
import QtQuick.Controls 2.15
//import QtGraphicalEffects 1.12
import Qt5Compat.GraphicalEffects
import QtQuick.Shapes 1.0
import QtQuick.Window 2.15
import QtMultimedia
//import QtMultimedia 5.15

Item {
    id: root
    clip: true

    readonly property real horizontalCenterX: width / 2
    readonly property real verticalCenterY: height / 2

    property string mediaSource: ""
    property bool zoom: false
    property bool inverted: false
    property bool safeMode: false
    readonly property bool ready: mediaStatus == ItemViewerItem.Ready;
    enum Status {
        Unknown,
        Ready,
        Loading,
        Error
    }

    readonly property string sourceExt:{
        let ext = mediaSource.substring(mediaSource.lastIndexOf('.')+1, mediaSource.length) || mediaSource;
        if (ext.indexOf('?') !== -1) ext = ext.substring(0, ext.lastIndexOf('?'));
        return ext.toLowerCase();
    }
    readonly property string type: {
        //TODO: Qt6.2: replace with full list of formats
        let videoExts = "mp4,mkv,webm", //mp4,mkv,webm
            imageExts = "png,jpg,jpe,jpeg,bmp,svg,tif,tiff",//webp
            animaExts = "gif";
        if(imageExts.indexOf(sourceExt) !== -1) return "image";
        else
        if(animaExts.indexOf(sourceExt) !== -1) return "animation";
        else
        if(videoExts.indexOf(sourceExt) !== -1) return "video"; // till Qt 6.2
        else {
            console.error("Unknown format!", sourceExt);
            return "unknown";
        }
    }
    readonly property Component mediaComponent: {
        switch (type) {
        case "image":
            return imageComponent;
        case "animation":
            return animatedImageComponent;
        case "video":
            return videoComponent;
        case "unknown":
            return Item;
        }
    }
    readonly property int mediaStatus: {
        if (mediaLoaderItem) return mediaLoaderItem.mediaStatus;
        return ItemViewerItem.Unknown
    }
    onMediaStatusChanged: {
        if (mediaStatus === ItemViewerItem.Error) {
            handleMediaError();
            console.error("MEDIA ERROR!")
        }
    }

    property bool isActiveNow: true
    property bool toOptimize1: false
    property bool toOptimize2: false
    property var handleMediaError: () => {}

    property int virtualPadding: 100

    property QtObject imageSizes: QtObject {
        id: imageSizes
        property size defaultSize: Qt.size(0, 0)

        readonly property real parentRatio: root.width/root.height
        readonly property real parentRatioInverted: root.height/root.width

        readonly property real imageRatio: widthDefault/heightDefault
        readonly property real imageRatioInverted: heightDefault/widthDefault

        readonly property int width: {
            if (zoom) {
                return widthZoomed;
            }
            else {
                return widthFramed;
            }
        }
        readonly property int widthDefault: defaultSize.width
        readonly property int widthFramed: {
            if (parentRatio > imageRatio && heightDefault > root.height) {
                return root.height * imageRatio;
            }
            if (widthDefault > root.width) {
                return root.width;
            }
            return widthDefault;
        }
        readonly property int widthZoomed: widthDefault

        readonly property int height: {
            if (zoom) {
                return heightZoomed;
            }
            else {
                return heightFramed;
            }
        }
        readonly property int heightDefault: defaultSize.height
        readonly property int heightFramed: {
            if (parentRatioInverted > imageRatioInverted && widthDefault > root.width) {
                return root.width * imageRatioInverted;
            }
            if (heightDefault > root.height) {
                return root.height;
            }
            return heightDefault;
        }
        readonly property int heightZoomed:heightDefault

        /* Math magic behind
            r1 = W/H
            r2 = w/h

            if (r1 > r2 && h > H)  // parent is wider than child
                w1 = h*W/H // H*w/h
                h1 = H
            else
            if (r1 < r2 && w > W)  // parent is higher than child
                w1 = W
                h1 = w*H/W // W*h/w
            else
                if (w > W) // parent is square and is like child
                    w1 = W
                    h1 = H
                else
                    w1 = w
                    h1 = h

            w1 = (r1 > r2 && h > H) ? H*w/h : (w > W) ? W : w
            h1 = (r1 < r2 && w > W) ? W*h/w : (h > H) ? H : h
        */

        function getKAxis(centerAxis, rootDimension, imgDimension) { // Dimensions: Width, Height; Axis: X, Y
            if (rootDimension > imgDimension) return 0;

            let kx = (centerAxis - 2 * root.virtualPadding) / (rootDimension - 2 * root.virtualPadding) - 1,
                sign = (0 < kx) - (kx < 0),
                sign2 = (!root.inverted - root.inverted);
            return Math.min(0.5, kx * sign) * sign * sign2;
        }

        readonly property int x: Math.round((root.width - width) * getKAxis(mouseArea.horizontalCenterX, root.width, width))
        readonly property int y: Math.round((root.height - height) * getKAxis(mouseArea.verticalCenterY, root.height, height))
    }

    states: [
        State {
            name: "zoomed"
            when: zoom && !toOptimize2 && !toOptimize1
            PropertyChanges {
                target: mediaLoader
                anchors.horizontalCenterOffset: imageSizes.x
                anchors.verticalCenterOffset: imageSizes.y
            }
        }
    ]

    onIsActiveNowChanged: {
//        if (type === "video") { // till Qt 6.2
//            if (isActiveNow) mediaLoader.item.play();
//            else mediaLoader.item.pause();
//        }
    }

    DropShadow {
        id: shadow
        anchors.fill: mediaLoader
        radius: 48//12
//        samples: 16
        color: Palettes.current.viewerItemShadow
        source: rect
//        opacity: root.safeMode ? 0 : 1
    }
    Rectangle {
        id: rect
        width: imageSizes.width
        height: imageSizes.height
        anchors.fill: mediaLoader
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: mediaLoader.anchors.horizontalCenterOffset
        anchors.verticalCenterOffset: mediaLoader.anchors.verticalCenterOffset
        color: Palettes.current.viewerItemBg
        visible: false
    }
    LoadingSpinner {
        opacity: toOptimize2 ? 0 : +(mediaStatus == ItemViewerItem.Loading)
        diameter: 320
        width: 360; height: 360
        anchors.horizontalCenterOffset: 0
        anchors.verticalCenterOffset: 0
        anchors.centerIn: parent

        circles: 8
        loaderStrokeWidth: 8
        loaderSpeed: 12
        loaderColor: Palettes.current.viewerItemSpinner
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
    }
//    ItemVisible {
//        id: itemVisible
//        anchors.fill: parent
//    }
    Loader {
        id: mediaLoader
        sourceComponent: mediaComponent
        width: imageSizes.width
        height: imageSizes.height
//        visible: !toOptimize2/* && itemVisible.visible*/
        active: !toOptimize2
        anchors.horizontalCenterOffset: 0
        anchors.verticalCenterOffset: 0
        anchors.centerIn: parent
        opacity: root.safeMode ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
    }
    property alias mediaLoaderItem: mediaLoader.item

/* For visual debug
    Label {
        text: ["Unknown", "Ready", "Loading", "Error"][root.mediaStatus]
        color: Palettes.current.viewerItemFg
        anchors.left: parent.left
        anchors.top: parent.top
    }
    Label {
        text: root.mediaSource
        color: Palettes.current.viewerItemFg
        anchors.left: parent.left
        anchors.bottom: parent.bottom
    }
*/

    MouseArea {
        id: mouseArea
        enabled: {
            let bool = !toOptimize2 && !toOptimize1;
//            console.info(bool);
            return bool;
        }
        visible: +enabled
        anchors.fill: root
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: enabled
        readonly property real horizontalCenterX: mouseX + width / 2
        readonly property real verticalCenterY: mouseY + height / 2
        onClicked: {
            root.zoom = !root.zoom;
        }
    }
    Component {
        id: imageComponent
        Image {
            asynchronous: true
            source: root.mediaSource
            onSourceSizeChanged: {
//                if (imageSizes.defaultSize == Qt.size(0, 0)) {
                    imageSizes.defaultSize = sourceSize;
//                }
            }
            onStatusChanged: {
//                if (status == Image.Error) {
//                    handleMediaError(root.mediaSource);
//                }
            }
            smooth: !toOptimize1
//            mipmap: true
//            cache: false
            readonly property int mediaStatus: {
                switch (status) {
                case Image.Ready:
                    return ItemViewerItem.Ready;
                case Image.Loading:
                    return ItemViewerItem.Loading;
                case Image.Error:
                    return ItemViewerItem.Error;
                case Image.Null:
                default:
                    return ItemViewerItem.Unknown;
                }
            }
        }
    }
    Component {
        id: animatedImageComponent
        AnimatedImage {
            source: root.mediaSource
            playing: root.isActiveNow && root.ready
            onSourceSizeChanged: {
                if (imageSizes.defaultSize == Qt.size(0, 0)) {
                    imageSizes.defaultSize = sourceSize;
                }
            }
            onStatusChanged: {
//                if (status == AnimatedImage.Error) {
//                    handleMediaError(root.mediaSource);
//                }
            }
            cache: root.isActiveNow && root.ready
            readonly property int mediaStatus: {
                switch (status) {
                case AnimatedImage.Ready:
                    return ItemViewerItem.Ready;
                case AnimatedImage.Loading:
                    return ItemViewerItem.Loading;
                case AnimatedImage.Error:
                    return ItemViewerItem.Error;
                case AnimatedImage.Null:
                default:
                    return ItemViewerItem.Unknown;
                }
            }
        }
    }
    Component {
        id: videoComponent
        Item {
            Component.onCompleted: imageSizes.defaultSize = Qt.binding(() => Qt.size(root.width, root.height));
            MediaPlayer {
                id: mediaPlayer
                source: root.mediaSource
                videoOutput: videoOut
//                onErrorOccurred: {}
//                onStatusChanged: {
////                    if (status == Video.Error) handleImageError(root.mediaSource);
//                    imageSizes.defaultSize = Qt.binding(() => metaData.resolution);
//                }
//                autoPlay: root.isActiveNow
//                loops: MediaPlayer.Infinite
            }
            VideoOutput {
                id: videoOut
                anchors.fill: parent;
//                source: mediaPlayer
            }

            readonly property int mediaStatus: {
                if (mediaPlayer.error !== MediaPlayer.NoError) return ItemViewerItem.Error;

                switch (mediaPlayer.status) {
                case MediaPlayer.Loaded:
                    return ItemViewerItem.Ready;
                case MediaPlayer.Loading:
                    return ItemViewerItem.Loading;
                case MediaPlayer.InvalidMedia:
                    return ItemViewerItem.Error;
                case MediaPlayer.NoMedia:
                case MediaPlayer.UnknownStatus:
                default:
                    return ItemViewerItem.Unknown;
                }
            }
        }

    }
    Component {
        id: unknownComponent
        Item {
            Text {
                anchors.centerIn: parent
                text: qsTr("Sorry, I don't know how to interpret this media")
            }
            readonly property int mediaStatus: {
                return ItemViewerItem.Unknown;
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5}
}
##^##*/
