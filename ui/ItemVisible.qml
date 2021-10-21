import QtQuick 2.0
import QtQuick.Window 2.15

Item {
    id: item
    property int visibilityMargin: 10
    readonly property var abs: mapToGlobal(x, y)
    visible: (abs.x < window.width + visibilityMargin) && (-abs.x < width + visibilityMargin) &&
             (abs.y < window.height + visibilityMargin) && (-abs.y < height + visibilityMargin)
}
