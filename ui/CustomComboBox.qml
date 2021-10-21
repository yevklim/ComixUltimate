import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Shapes 1.0

ComboBox {
    id: control
    property int corners: 8
    property alias topLeftCorner: shape.topLeftCorner
    property alias topRightCorner: shape.topRightCorner
    property alias bottomLeftCorner: shape.bottomLeftCorner
    property alias bottomRightCorner: shape.bottomRightCorner
    model: Object.keys(control)
    leftPadding: 8
    rightPadding: 8
//    height: 32


    delegate: ItemDelegate {
        width: control.width
        height: control.height
        contentItem: Text {
            text: modelData
            color: control.pressed ? Palettes.current.comboboxPressedFg : Palettes.current.comboboxFg
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: SuperellipseShape {
//            height: control.height
//            topLeftCorner: index == 0 ? control.corners : 0
//            bottomRightCorner: index == count - 1 ? control.corners : 0
            corners: control.corners
            path {
                fillColor: pressed ? Palettes.current.comboboxPressedBg : "transparent"
//                Behavior on fillColor { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            }
        }
        highlighted: control.highlightedIndex === index
    }

    indicator: TriangleShape {
        id: indicatorId
        width: 12
        height: 6
        anchors.top: control.top
        anchors.topMargin: (control.height - height) / 2
        anchors.right: control.right
        anchors.rightMargin: anchors.topMargin
        anchors.bottom: control.bottom
        anchors.bottomMargin: anchors.topMargin
        path {
            fillColor: Palettes.current.comboboxIndicator
        }
        z: 100
    }

    contentItem: Text {
        text: control.displayText
        color: control.pressed ? Palettes.current.comboboxPressedFg : Palettes.current.comboboxFg
        font: control.font
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    background: SuperellipseShape {
        id: shape
        implicitWidth: 128
        implicitHeight: 32
//        anchors.fill: parent
//        implicitWidth: control.width
//        implicitHeight: control.height
//        topLeftCorner: control.corners
        corners: control.corners
        bottomLeftCorner: popup.opened ? 0 : control.corners
        bottomRightCorner: popup.opened ? 0 : control.corners
        path {
            fillColor: Palettes.current.comboboxBg
//            Behavior on fillColor { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
        }
    }

    popup: Popup {
        y: control.height
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 0

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

//            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: SuperellipseShape {
            bottomLeftCorner: control.corners
            bottomRightCorner: control.corners
            path {
                fillColor: Palettes.current.comboboxPopupBg
//                Behavior on fillColor { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:3}
}
##^##*/
