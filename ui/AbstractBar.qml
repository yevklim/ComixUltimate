import QtQuick 2.15
//import QtPositioning 5.15
//import QtGraphicalEffects 1.12
import Qt5Compat.GraphicalEffects
import QtQuick.Controls 2.15
//import QtQuick.Extras 1.4
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQml.Models 2.15
import QtQuick.Shapes 1.0

Item {
    id: root
    property bool extended: mouseArea.containsMouse
    property int corners: 0
    property alias topLeftCorner: shape.topLeftCorner
    property alias topRightCorner: shape.topRightCorner
    property alias bottomLeftCorner: shape.bottomLeftCorner
    property alias bottomRightCorner: shape.bottomRightCorner

    property bool autoTopPadding: true
    property bool autoLeftPadding: true
    property bool autoRightPadding: true
    property bool autoBottomPadding: true

    width: implicitWidth
    height: implicitHeight

//    clip: false

    property alias mouseArea_ref: mouseArea
    property alias positionerWrapper_ref: positionerWrapper
    property alias positionerWrapperChildren_ref: positionerWrapper.children
    property alias positioner_ref: positionerWrapper
    property alias shadow_ref: shadow
    property alias shape_ref: shape

    property color backgroundColor: Palettes.current.barBg
    property color shadowColor: Palettes.current.barShadow

    function topPadding() : int { return autoTopPadding ? Math.max(topLeftCorner, topRightCorner) : 0 }
    function leftPadding() : int { return autoLeftPadding ? Math.max(topLeftCorner, bottomLeftCorner) : 0 }
    function rightPadding() : int { return autoRightPadding ? Math.max(topRightCorner, bottomRightCorner) : 0 }
    function bottomPadding() : int { return autoBottomPadding ? Math.max(bottomLeftCorner, bottomRightCorner) : 0 }

//    Shape {
//        id: shape
//        anchors.fill: parent
//        visible: true
//        width: root.implicitWidth
//        height: root.implicitHeight

//        ShapePath {
//            id: shapePath
//            strokeWidth: -1
//            strokeColor: "#00000000"
//            fillColor: "#f2f2f2"
//            startX: 0; startY: 0
//            // M0 0        M0 16 L16 0          \   M0 ${topLeftCorner} ${topLeftCorner !== 0 ? "L" +topLeftCorner+ " 0 " : ""}
//            // L256 0      L240 0 256 16        \   L${shape.width - topRightCorner} 0 ${topLeftCorner !== 0 ? shape.width +" "+ topRightCorner : ""}
//            // L256 128    L256 112 240 128     \   L${shape.width} ${shape.height - bottomRightCorner} ${topLeftCorner !== 0 ? shape.width - bottomRightCorner +" "+ shape.height: ""}
//            // L0 128      L16 128 0 112        \   L${bottomLeftCorner} ${shape.height} ${topLeftCorner !== 0 ? "0 "+ (shape.height - bottomLeftCorner) : ""}
//            // L0 0        L0 16                \   L0 ${topLeftCorner}
//            PathSvg {
//                path: `M0 ${topLeftCorner} ${topLeftCorner !== 0 ? "L" +topLeftCorner+ " 0 " : ""}L${shape.width - topRightCorner} 0 ${topRightCorner !== 0 ? shape.width +" "+ topRightCorner : ""}L${shape.width} ${shape.height - bottomRightCorner} ${bottomRightCorner !== 0 ? shape.width - bottomRightCorner +" "+ shape.height: ""}L${bottomLeftCorner} ${shape.height} ${bottomLeftCorner !== 0 ? "0 "+ (shape.height - bottomLeftCorner) : ""}L0 ${topLeftCorner}`
//            }
//        }
//    }

    QuteShape {
        id: shape
        anchors.fill: parent
        corners: root.corners
        width: root.implicitWidth
        height: root.implicitHeight
        path {
            fillColor: root.backgroundColor
        }
//        clip: false
//        visible: false
    }

    DropShadow {
        id: shadow
        anchors.fill: shape
        horizontalOffset: 0
        verticalOffset: 0
        radius: 12
//        samples: 16
        color: root.shadowColor
        source: shape
//        clip: false
        visible: false
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    Item {
        id: positionerWrapper
        anchors.fill: parent
    }

}
