import QtQuick 2.15
//import QtPositioning 5.15
//import QtGraphicalEffects 1.12
import QtQuick.Controls 2.15
//import QtQuick.Extras 1.4
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQml.Models 2.15
import QtQuick.Shapes 1.0

Item {
    id: root
    height: 48

    readonly property int corners: 16

    property alias bar: barId

    readonly property int slide_width: barId.width - corners

    property alias slide: slideId
    property alias slide2: slide2Id

    readonly property bool containsMouse: barId.mouseArea.containsMouse || slideId.mouseArea.containsMouse || slide2Id.mouseArea.containsMouse

    Bar {
        id: barId
        anchors.top: parent.top
        anchors.right: parent.right
        transformOrigin: Item.TopRight
        direction: Qt.Horizontal
        movingDirection: Qt.Horizontal
        shown: mouseArea.containsMouse || slideId.shown
        side: root.height
        topMargin: 4
//        rightMargin: 4
        leftPadding: root.corners
        padding: 4
//        alwaysVisiblePart: root.corners
        z: 1
        background {
//            corners: root.corners
            topLeftCorner: root.corners
            bottomLeftCorner: root.corners
//            path.fillColor: Palettes.current.barBg
        }
        container {
            //
        }
    }
    Bar {
        id: slideId
        shrinkOnHiding: true
        anchors.top: barId.bottom
//        anchors.topMargin: topMargin
        anchors.right: barId.right
        anchors.rightMargin: /*rightMargin */-barId.container.x
//        anchors.horizontalCenter: barId.horizontalCenter
//        anchors.horizontalCenterOffset: barId.container.x
        topMargin: 8
        leftMargin: 8
        rightMargin: 8
        transformOrigin: Item.TopRight
        direction: Qt.Vertical
        movingDirection: Qt.Vertical
        shown: mouseArea.containsMouse || slide2Id.shown
        side: barId.width - barId.implicitMinimumLength
        includeMargin: true
        padding: 4
//        bottomPadding: root.corners
//        alwaysVisiblePart: root.corners
        background {
            corners: root.corners
//            topLeftCorner: root.corners
//            topRightCorner: root.corners
//            bottomLeftCorner: slide2Id.shown ? root.corners : 0
//            bottomRightCorner: slide2Id.shown ? root.corners : 0
//            path {
//                fillColor: shown ? Palettes.current.barBg : Palettes.current.btnFg
//                Behavior on fillColor { ColorAnimation { duration: 200 } }
//            }
        }
        container {
            //
        }
    }
    Bar {
        id: slide2Id
        anchors.top: slideId.bottom
//        anchors.topMargin: slideId.container.y//??????
//        anchors.horizontalCenter: slideId.horizontalCenter
        anchors.right: slideId.right
//        anchors.horizontalCenterOffset: barId.container.x + root.corners / 2
        aBool: true
        margin: 8
        transformOrigin: Item.TopRight
        direction: Qt.Vertical
        movingDirection: Qt.Vertical
        side: barId.width - barId.implicitMinimumLength
        includeMargin: true
        padding: 4
//        bottomPadding: root.corners
//        alwaysVisiblePart: root.corners
        background {
            corners: root.corners
//            path {
//                fillColor: shown ? Palettes.current.barBg : Palettes.current.btnFg
//                Behavior on fillColor { ColorAnimation { duration: 200 } }
//            }
//            path.fillColor: Palettes.current.barSlideBg
        }
        container {
            //
        }
    }
}
