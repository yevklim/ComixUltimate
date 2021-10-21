import QtQuick 2.15
import QtQuick.Controls 2.15
//import QtGraphicalEffects 1.15
import QtQuick.Shapes 1.0

Slider {
    id: control
    value: 0.5

//    property alias backgroundWidth: backgroundId.width
    background: QuteShape {
        id: backgroundId
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: control.availableHeight
        topLeftCorner: control.height / 3
        bottomRightCorner: control.height / 3
        width: control.availableWidth
        height: implicitHeight
        path {
            fillColor: Palettes.current.sliderBg
        }

        QuteShape {
            width: control.visualPosition * parent.width + (control.visualPosition < .5 ? topLeftCorner : 0)
            height: parent.height
            path {
                fillColor: Palettes.current.sliderBg2
            }
            topLeftCorner: control.height / 3
            bottomRightCorner: control.height / 3
        }
    }

    handle: QuteShape {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableHeight + (topLeftCorner + bottomRightCorner) / 2
        height: control.availableHeight
        topLeftCorner: control.height / 3
        bottomRightCorner: control.height / 3
        path {
            fillColor: Palettes.current.sliderFg
        }
//        opacity: .5
    }
}
