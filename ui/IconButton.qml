import QtQuick 2.0
import QtQuick.Controls 2.15
//import QtGraphicalEffects 1.15

CustomButton {
    id: button
    property int side: 32
    width: side
    height: side
    property alias source: icon.source

    contentItem: Item {
        width: button.width
        height: button.height
//        implicitWidth: icon.sourceSize.width
//        implicitHeight: icon.sourceSize.height
        Image {
            id: icon
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
        }
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:3;height:480;width:640}
}
##^##*/
