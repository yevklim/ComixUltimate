import QtQuick 2.15
import QtQuick.Shapes 1.0
import "./icons.js" as IconsJS

Shape {
    id: root
    property color iconColor: Palettes.current.icon
    property string iconCode: ""
    property int iconSize: 32
    property string iconPath: IconsJS.svgIcons[iconSize][iconCode]
    width: iconSize
    height: iconSize
    layer.enabled: true
    antialiasing: true
    layer.smooth: true
    layer.samples: 4
    ShapePath {
        id: iconPath
        strokeWidth: -1
        strokeColor: "#00000000"
        fillColor: root.iconColor
        startX: 0; startY: 0
        PathSvg {
            id: pathSvg
            path: root.iconPath
        }
//        Behavior on fillColor { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    }
}
