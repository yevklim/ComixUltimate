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

Popup {
    id: popup
    topPadding: Math.max(shape.topLeftCorner, shape.topRightCorner)
    leftPadding: Math.max(shape.topLeftCorner, shape.bottomLeftCorner)
    rightPadding: Math.max(shape.topRightCorner, shape.bottomRightCorner)
    bottomPadding: Math.max(shape.bottomLeftCorner, shape.bottomRightCorner)
//    modal: true
//    dim: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnReleaseOutside
    property int maximumWidth: 500
    property int maximumHeight: 250

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0 }
    }

    background: SuperellipseShape {
        id: shape
        path.fillColor: Palettes.current.barBg
    }
    readonly property alias backgroundItem: shape
}
