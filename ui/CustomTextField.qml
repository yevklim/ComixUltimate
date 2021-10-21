import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    id: root
    palette.text: Palettes.current.textFieldFg
    property alias backgroundRef: shape
    implicitWidth: 200
    implicitHeight: 40
    background: SuperellipseShape {
        id: shape
        anchors.fill: root
        corners: 16
        path.fillColor: Palettes.current.textFieldBg
    }
    topInset: shape ? shape.corners : 0
    leftInset: shape ? shape.corners : 0
    rightInset: shape ? shape.corners : 0
    bottomInset: shape ? shape.corners : 0
    placeholderTextColor: Palettes.current.textFieldPlaceholder
}
