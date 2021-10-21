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

    readonly property int corners: 16

    readonly property int bar_minwidth: 48
    readonly property int bar_maxwidth: 216
    readonly property int bar_width: bar_minwidth

    property alias bar_ref: bar

    Bar {
        id: bar
        includeMargin: false
        anchors.top: parent.top
        anchors.left: parent.left
        transformOrigin: Item.TopLeft
        direction: Qt.Vertical
//        movingDirection: Qt.Vertical
        side: root.bar_width + leftPadding + rightPadding
//        rightPadding: 1
        padding: 4
        margin: 4
//        bottomPadding: root.corners
//        alwaysVisiblePart: root.corners
        container {
            spacing: 4
            //
        }
        background {
            corners: root.corners
//            bottomRightCorner: root.corners
        }
    }
}
