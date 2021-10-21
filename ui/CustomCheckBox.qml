import QtQuick 2.15
import QtQuick.Controls 2.15
//import QtGraphicalEffects 1.15
import QtQuick.Shapes 1.0

CheckBox {
    id: root
    property color bgColorDefault: Palettes.current.checkboxBg
    property color bgColorHover: Palettes.current.checkboxHoverBg
    property color bgColorPressed: Palettes.current.checkboxPressedBg
    property color indicatorColor: Palettes.current.checkboxIndicator
    property int corners: 0
    property alias topLeftCorner: shape.topLeftCorner
    property alias topRightCorner: shape.topRightCorner
    property alias bottomLeftCorner: shape.bottomLeftCorner
    property alias bottomRightCorner: shape.bottomRightCorner
    hoverEnabled: false

    indicator: QuteShape {
        id: shape
        width: height
        height: root.height
        corners: root.corners
        path {
            fillColor: root.bgColorDefault
//            Behavior on fillColor { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
        }

        QuteShape {
                width: height
                height: root.height - 12
                anchors.centerIn: shape
                topLeftCorner: shape.topLeftCorner * height / shape.height
                topRightCorner: shape.topRightCorner * height / shape.height
                bottomLeftCorner: shape.bottomLeftCorner * height / shape.height
                bottomRightCorner: shape.bottomRightCorner * height / shape.height

                path {
                    fillColor: root.checked ? root.indicatorColor : root.bgColorDefault
//                    Behavior on fillColor { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                }
        }
    }
}
