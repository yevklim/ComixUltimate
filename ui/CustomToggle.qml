import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
    id: root
    width: listViewId.width
    height: listViewId.height
    property alias listview: listViewId
    property alias background: shape
    property alias orientation: listViewId.orientation
    property bool autoWidth: true
    property bool autoHeight: true

    property real padding: 4

    implicitWidth: listViewId.width
    implicitHeight: listViewId.height

    SuperellipseShape {
        id: shape
        anchors.fill: parent
        corners: 8
        path.fillColor: Palettes.current.togglesBg
        visible: listViewId.count > 1
    }

    ListView {
        id: listViewId
        model: 2
    //    interactive: true
        delegate: Text {
            color: listViewId.currentIndex === index ? Palettes.current.togglesHighlightFg : Palettes.current.togglesFg
            text: modelData
            topPadding: 10
            leftPadding: 12
            rightPadding: 12
            bottomPadding: 10
            width: listViewId.orientation == Qt.Horizontal && autoWidth ? implicitWidth : listViewId.width
            height: listViewId.orientation == Qt.Vertical && autoHeight ? implicitHeight : listViewId.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            MouseArea {
                anchors.fill: parent
                hoverEnabled: false
                onClicked: listViewId.currentIndex = index
            }
        }
        highlight: SuperellipseShape {
            width: listViewId.currentItem !== null ? listViewId.currentItem.width : 0
            height: listViewId.currentItem !== null ? listViewId.currentItem.height : 0
    //        topLeftCorner: 8
    //        bottomRightCorner: 8
            corners: shape.corners - root.padding
            padding: root.padding
            path {
                fillColor: Palettes.current.togglesHighlightBg
            }
            visible: listViewId.count > 1
        }
        orientation: Qt.Horizontal
        focus: true
    }
}


/*##^##
Designer {
    D{i:0;formeditorZoom:4}
}
##^##*/
