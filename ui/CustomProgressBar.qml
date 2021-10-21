import QtQuick 2.15
import QtQuick.Controls 2.15
//import QtGraphicalEffects 1.15
import QtQuick.Shapes 1.0

ProgressBar {
     id: control
     value: 0.5
     padding: 1

     background: QuteShape {
         id: backgroundId
         width: control.availableWidth
         height: control.availableHeight
         topLeftCorner: control.height / 3
         bottomRightCorner: control.height / 3
         path {
            fillColor: Palettes.current.progressbarBg
         }
     }

     contentItem: Item {
         id: itemId
         width: control.availableWidth
         height: control.availableHeight

         QuteShape {
             id: itemShapeId
             topLeftCorner: control.height / 3
             bottomRightCorner: control.height / 3
             implicitWidth: control.visualPosition * parent.width - 2 * control.padding
             width: implicitWidth
             opacity: +(implicitWidth > topLeftCorner)
             height: parent.height - 2 * control.padding
//             Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
//             Behavior on width { NumberAnimation { duration: opacity ? 200 : 0; easing.type: Easing.InOutQuad } }
             path {
                fillColor: Palettes.current.progressbarFg
             }
         }
     }
 }
