import QtQuick 2.15
import QtQuick.Shapes 1.0

Item {
    id: root
    width: 128
    height: 128
    property int diameter: Math.min(width, height)
    readonly property int radius: diameter / 2
    property int circles: 10
    property color loaderColor: "#80333333";
    property int loaderSpeed: 8;
    property int minSpeed: 1
    property int maxSpeed: 12
    readonly property int speedStep: (maxSpeed / minSpeed) ** (1 / (circles - 1))
    property int loaderStrokeWidth: 4
//    property int rotation: 0
    layer.enabled: true
    layer.samples: 4
    antialiasing: true

//    RotationAnimation on rotation {
//            loops: Animation.Infinite
//            duration: 500
//            from: 0
//            to: 360
//        }

//    NumberAnimation on rotation { from: 0; to: 360; duration: 500; loops: Animation.Infinite }

    Repeater {
        model: circles;
        Shape {
            width: radius * 2
            height: radius * 2
//            anchors.horizontalCenter: parent.horizontalCenter
//            anchors.verticalCenter: parent.verticalCenter
            anchors.centerIn: parent
//            rotation: root.rotation * (index + 1) / circles
            antialiasing: true
            RotationAnimation on rotation {
                loops: Animation.Infinite
                duration: root.loaderSpeed * 1000/(circles - index) * .618; // NEED a balanced duration
//                duration: minSpeed * speedStep**(circles - index - 1) * 1000
//                duration: minSpeed * speedStep**(index) * 1000
//                duration: minSpeed * (maxSpeed / minSpeed) ** (index / (circles - 1)) * 1000
//                duration: root.loaderSpeed * 1000 * (circles - index) ** Math.log((circles - index))
//                duration: root.loaderSpeed * 100 * (circles - index)
                from: 0
                to: 360
            }

            ShapePath {
                strokeWidth: root.loaderStrokeWidth
                strokeColor: root.loaderColor
                capStyle: ShapePath.RoundCap
                fillColor: "#00000000"
                startX: radius + radius * (circles - index) / circles; startY: radius;
                PathArc {
                    x: radius * index / circles; y: radius
                    radiusX: radius * (circles - index) / circles; radiusY: radiusX
                    useLargeArc: true
                }
            }
        }
    }
//    Shape {
//        width: radius * 2
//        height: radius * 2
//        rotation: 180
//        antialiasing: true

//        ShapePath {
//            strokeWidth: 2
//            strokeColor: "#17a81a"
//            fillColor: "#00000000"
//            startX: radius + radius/ 2; startY: radius
//            PathArc {
//                x: radius/ 2; y: radius
//                radiusX: radius / 2; radiusY: radius / 2
//                useLargeArc: true
//            }
//        }
//    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.25;height:480;width:640}
}
##^##*/
