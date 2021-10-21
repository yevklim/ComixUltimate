import QtQuick 2.15
import QtQuick.Controls 2.15
//import QtGraphicalEffects 1.15
import QtQuick.Shapes 1.0

Button {
    id: root
    property color bgColorDefault: Palettes.current.btnBg
    property color bgColorHover: Palettes.current.btnHoverBg
    property color bgColorPressed: Palettes.current.btnPressedBg
    readonly property color bgColor: root.down || root.checked ? root.bgColorPressed : root.hovered ? root.bgColorHover : root.bgColorDefault

    property color fgColorDefault: Palettes.current.btnFg
    property color fgColorHover: Palettes.current.btnHoverFg
    property color fgColorPressed: Palettes.current.btnPressedFg
    readonly property color fgColor: root.down || root.checked ? root.fgColorPressed : root.hovered ? root.fgColorHover : root.fgColorDefault

    property int corners: 0
    property alias topLeftCorner: shape.topLeftCorner
    property alias topRightCorner: shape.topRightCorner
    property alias bottomLeftCorner: shape.bottomLeftCorner
    property alias bottomRightCorner: shape.bottomRightCorner

//    topPadding: Math.max(shape.topLeftCorner, shape.topRightCorner)
//    leftPadding: Math.max(shape.topLeftCorner, shape.bottomLeftCorner)
//    rightPadding: Math.max(shape.topRightCorner, shape.bottomRightCorner)
//    bottomPadding: Math.max(shape.bottomLeftCorner, shape.bottomRightCorner)

    property real implicitWidth2: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                                   textItem.implicitWidth + leftPadding + rightPadding)
    property real implicitHeight2: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                                  textItem.implicitHeight + topPadding + bottomPadding)
    width: implicitWidth2
    height: implicitHeight2
    hoverEnabled: false

    property alias backgroundRef: shape
    background: SuperellipseShape {
        id: shape
        anchors.fill: root
        corners: root.corners
//        topLeftCorner: root.corners
//        bottomRightCorner: root.corners
        path {
            fillColor: root.bgColor
//            Behavior on fillColor { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
        }
    }
    readonly property alias backgroundItem: shape
    property alias contentItemFont: textItem.font
    contentItem: Item {
//        width: root.width
//        height: root.height

        Text {
            id: textItem
            text: root.text
            color: root.fgColor
            anchors.centerIn: parent
        }
    }
}
