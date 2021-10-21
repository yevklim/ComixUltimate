import QtQuick 2.15
import QtQuick.Shapes 1.0

Shape {
        id: shape
        property int corners: 0
        property int topLeftCorner: 0
        property int topRightCorner: 0
        property int bottomLeftCorner: 0
        property int bottomRightCorner: 0

        property alias path: shapePath
        antialiasing: true

        ShapePath {
            id: shapePath
            strokeWidth: -1
            strokeColor: "#00000000"
            fillColor: "#17a81a"
            startX: 0; startY: 0
            // M0 0        M0 16 L16 0          \   M0 ${topLeftCorner} ${topLeftCorner !== 0 ? "L" +topLeftCorner+ " 0 " : ""}
            // L256 0      L240 0 256 16        \   L${shape.width - topRightCorner} 0 ${topLeftCorner !== 0 ? shape.width +" "+ topRightCorner : ""}
            // L256 128    L256 112 240 128     \   L${shape.width} ${shape.height - bottomRightCorner} ${topLeftCorner !== 0 ? shape.width - bottomRightCorner +" "+ shape.height: ""}
            // L0 128      L16 128 0 112        \   L${bottomLeftCorner} ${shape.height} ${topLeftCorner !== 0 ? "0 "+ (shape.height - bottomLeftCorner) : ""}
            // L0 0        L0 16                \   L0 ${topLeftCorner}
            PathSvg {
                path: `M0 ${topLeftCorner} ${topLeftCorner !== 0 ? "L" +topLeftCorner+ " 0 " : ""}L${shape.width - topRightCorner} 0 ${topRightCorner !== 0 ? shape.width +" "+ topRightCorner : ""}L${shape.width} ${shape.height - bottomRightCorner} ${bottomRightCorner !== 0 ? shape.width - bottomRightCorner +" "+ shape.height: ""}L${bottomLeftCorner} ${shape.height} ${bottomLeftCorner !== 0 ? "0 "+ (shape.height - bottomLeftCorner) : ""}L0 ${topLeftCorner}`
            }
//            Behavior on fillColor { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
        }
    }
