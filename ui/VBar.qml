import QtQuick 2.15

AbstractBar {
    property alias positioner_ref: positioner
    property alias items: positioner.children

    readonly property int implicitHeight: positioner.height + topPadding() + bottomPadding()
    height: implicitHeight

    positionerWrapperChildren_ref: Column {
        id: positioner
        spacing: 1
        padding: 0
        Behavior on spacing { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        Behavior on padding { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
    }
}
