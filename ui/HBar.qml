import QtQuick 2.15

AbstractBar {
    property alias positioner_ref: positioner
    property alias items: positioner.children

    readonly property int implicitWidth: positioner.width + leftPadding() + rightPadding()
    width: implicitWidth

    positionerWrapperChildren_ref: Row {
        id: positioner
        spacing: 1
        padding: 0
        Behavior on spacing { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        Behavior on padding { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
    }
}
