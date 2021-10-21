import QtQuick 2.15
//import QtPositioning 5.15
//import QtGraphicalEffects 1.15
import QtQuick.Controls 2.15
//import QtQuick.Extras 1.4
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQml.Models 2.15
import "./MaterialIcons/MaterialIcons-Regular.js" as MD
//import QtQuick.Dialogs 1.3
//import FilterParams 1.0
//import SorterParams 1.0
//import "."
//import "db.js" as DataBase

Popup {
    id: popup
    width: scrollView.width
    height: scrollView.height
    padding: 0
    anchors.centerIn: parent
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    property int maximumWidth: 500
    property int maximumHeight: 500

    property alias positioner: positioner_loader.sourceComponent

    property var resetPopup: function() {
        popup.close();
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0 }
    }

    background: SuperellipseShape {
        corners: 16
//        topLeftCorner: 16
//        bottomRightCorner: 16
        path.fillColor: Palettes.current.popupBg
    }

    contentItem: ScrollView {
        id: scrollView
        clip: true
        width: Math.min(/*positioner_loader.item.implicitWidth + leftPadding + rightPadding, */popup.maximumWidth)
        height: Math.min(/*positioner_loader.item.implicitHeight + topPadding + bottomPadding, */popup.maximumHeight)
        padding: 16
        Loader {
            id: positioner_loader
            sourceComponent: Column
        }
    }
}
