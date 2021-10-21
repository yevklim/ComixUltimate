import QtQuick 2.12
import QtQuick.Shapes 1.0

Shape {
    id: shape
    property alias path: shapePath
    width: 12
    height: 6

    layer.enabled: true
    layer.samples: 8

    enum Direction {
        TopBottom,
        BottomTop,
        LeftRight,
        RightLeft
    }
    property int direction: TriangleShape.TopBottom

    QtObject {
        id: points
        property point p1: {
            switch (shape.direction) {
            case TriangleShape.BottomTop:
            case TriangleShape.RightLeft:
                return Qt.point(1, 1);
            case TriangleShape.TopBottom:
            case TriangleShape.LeftRight:
            default:
                return Qt.point(0, 0);
            }
        }
        property point p2: {
            switch (shape.direction) {
            case TriangleShape.RightLeft:
            case TriangleShape.TopBottom:
                return Qt.point(shape.width, 0);
            case TriangleShape.BottomTop:
                return Qt.point(shape.width / 2, 0);
            case TriangleShape.LeftRight:
                return Qt.point(shape.width, shape.height / 2);
            default:
                console.error("WTF???2");
                return Qt.point(0, 0);
            }
        }
        property point p3: {
            switch (shape.direction) {
            case TriangleShape.BottomTop:
            case TriangleShape.LeftRight:
                return Qt.point(0, shape.height);
            case TriangleShape.RightLeft:
                return Qt.point(0, shape.height / 2);
            case TriangleShape.TopBottom:
                return Qt.point(shape.width / 2, shape.height);
            default:
                console.error("WTF???3");
                return Qt.point(0, 0);
            }
        }
    }

    ShapePath {
        id: shapePath
        strokeWidth: -1
        fillColor: "#000"
        startX: points.p1.x; startY: points.p1.y
        PathLine { x: points.p2.x; y: points.p2.y }
        PathLine { x: points.p3.x; y: points.p3.y }
//        PathLine { x: points.p1.x; y: points.p1.y }
    }
}
