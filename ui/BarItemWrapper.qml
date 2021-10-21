import QtQuick 2.15

Item {
    id: root
    default property alias content: loader.sourceComponent
    property alias loader_ref: loader
    property bool isVisible: true
    property bool isVertical: false
    property bool disableBehaviors: false
    width: implicitWidth
    height: implicitHeight
    implicitWidth: !isVisible && !isVertical ? 0 : loader.width
    implicitHeight: !isVisible && isVertical ? 0 : loader.height
    opacity: !isVisible ? 0 : 1
//    z: isVisible ? 0 : -1
    clip: true
    Behavior on width { NumberAnimation { duration: !disableBehaviors ? 200 : 0; easing.type: Easing.InOutQuad } }
    Behavior on height { NumberAnimation { duration: !disableBehaviors ? 200 : 0; easing.type: Easing.InOutQuad } }
    Behavior on opacity { NumberAnimation { duration: !disableBehaviors ? 400 : 0; easing.type: Easing.InOutQuad } }
    Loader {
        id: loader
//        width: root.width
        anchors.centerIn: root
    }
}
