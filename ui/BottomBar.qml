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
//    anchors.left: parent.left
//    anchors.right: parent.right
//    anchors.bottom: parent.bottom
//    anchors.leftMargin: 0
//    anchors.rightMargin: 0
//    anchors.bottomMargin: 0

//    clip: true
    readonly property int corners: 16

    property alias centerbar_ref: centerbar
    property alias rightbar_ref: rightbar

    Bar {
        id: centerbar
        includeMargin: false
        anchors.bottom: parent.bottom
        transformOrigin: Item.Bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: Math.min(0, root.width / 2 - centerbar.width / 2 - rightbar.width/* - 10*/)
        direction: Qt.Horizontal
//        movingDirection: Qt.Horizontal
        side: root.height + topPadding + bottomPadding
        padding: 4
//        topPadding: 1
//        leftPadding: root.corners
//        rightPadding: root.corners
//        bottomMargin: 4
        margin: 4
        background {
            corners: root.corners
//            topLeftCorner: root.corners
//            topRightCorner: root.corners
        }
        container {
            spacing: 4
        }
    }

    Bar {
        id: rightbar
//        shrinkOnHiding: true
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        transformOrigin: Item.BottomRight
        direction: Qt.Horizontal
//        movingDirection: Qt.Horizontal
        side: root.height + topPadding + bottomPadding
        padding: 4
//        topPadding: 1
//        leftPadding: root.corners
        margin: 4
//        rightMargin: 4
//        bottomMargin: 4
        background {
            corners: root.corners
//            topLeftCorner: root.corners
        }
        container {
            spacing: 4
        }
    }
}
