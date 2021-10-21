import QtQuick 2.15
import QtQuick.Shapes 1.0

//P.S.: My thanks to Mr. Jonathan McAllister for path formula

Shape {
        id: shape
//        width: implicitWidth
//        height: implicitHeight
        property real corners: 0

        property real topLeftCorner: corners
        property real topRightCorner: corners
        property real bottomLeftCorner: corners
        property real bottomRightCorner: corners

        property real padding: 0
        property real topPadding: padding
        property real leftPadding: padding
        property real rightPadding: padding
        property real bottomPadding: padding

//        property real minimumHeight:

        property alias path: shapePath

        readonly property real multiplier: 1.2

        layer.enabled: true
        layer.samples: 8

        QtObject {
            id: points

            readonly property point topRightStart: Qt.point(shape.width - rightPadding - topRightCorner * multiplier, topPadding)
            readonly property point topRightAnchor: Qt.point(shape.width - rightPadding, topPadding)
            readonly property point topRightEnd: Qt.point(shape.width - rightPadding, topPadding + topRightCorner * multiplier)

            readonly property point bottomRightStart: Qt.point(shape.width - rightPadding, shape.height - bottomPadding - bottomRightCorner * multiplier)
            readonly property point bottomRightAnchor: Qt.point(shape.width - rightPadding, shape.height - bottomPadding)
            readonly property point bottomRightEnd: Qt.point(shape.width - rightPadding - bottomRightCorner * multiplier, shape.height - bottomPadding)

            readonly property point bottomLeftStart: Qt.point(leftPadding + bottomLeftCorner * multiplier, shape.height - bottomPadding)
            readonly property point bottomLeftAnchor: Qt.point(leftPadding, shape.height - bottomPadding)
            readonly property point bottomLeftEnd: Qt.point(leftPadding, shape.height - bottomPadding - bottomLeftCorner * multiplier)

            readonly property point topLeftStart: Qt.point(leftPadding, topPadding + topLeftCorner * multiplier)
            readonly property point topLeftAnchor: Qt.point(leftPadding, topPadding)
            readonly property point topLeftEnd: Qt.point(leftPadding + topLeftCorner * multiplier, topPadding)
        }

        ShapePath {
            id: shapePath
            strokeWidth: -1
            strokeColor: "#00000000"
            fillColor: "#17a81a"

            startX: points.topRightStart.x; startY: points.topRightStart.y
            PathQuad { x: points.topRightEnd.x; y: points.topRightEnd.y; controlX: points.topRightAnchor.x; controlY: points.topRightAnchor.y }
            PathLine { x: points.bottomRightStart.x; y: points.bottomRightStart.y }
            PathQuad { x: points.bottomRightEnd.x; y: points.bottomRightEnd.y; controlX: points.bottomRightAnchor.x; controlY: points.bottomRightAnchor.y }
            PathLine { x: points.bottomLeftStart.x; y: points.bottomLeftStart.y }
            PathQuad { x: points.bottomLeftEnd.x; y: points.bottomLeftEnd.y; controlX: points.bottomLeftAnchor.x; controlY: points.bottomLeftAnchor.y }
            PathLine { x: points.topLeftStart.x; y: points.topLeftStart.y }
            PathQuad { x: points.topLeftEnd.x; y: points.topLeftEnd.y; controlX: points.topLeftAnchor.x; controlY: points.topLeftAnchor.y }
            PathLine { x: points.topRightStart.x; y: points.topRightStart.y }
//            Behavior on fillColor { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
        }
    }
