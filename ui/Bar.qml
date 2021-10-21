import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Item {
    id: root

    default property alias items: containerId.children

    property int direction: Qt.Horizontal
    readonly property bool horizontal: direction === Qt.Horizontal
    readonly property bool vertical: direction === Qt.Vertical
    property int movingDirection: horizontal ? Qt.Vertical : Qt.Horizontal
    readonly property bool movingHorizontal: movingDirection === Qt.Horizontal
    readonly property bool movingVertical: movingDirection === Qt.Vertical
    //by default movingDirection is opposite to direction

    transformOrigin: Item.Bottom
    readonly property bool topOrigin: {
        switch (transformOrigin) {
        case Item.TopLeft:
        case Item.Top:
        case Item.TopRight:
            return true;
        default:
            return false;
        }
    }
    readonly property bool leftOrigin: {
        switch (transformOrigin) {
        case Item.TopLeft:
        case Item.Left:
        case Item.BottomLeft:
            return true;
        default:
            return false;
        }
    }
    readonly property bool rightOrigin: {
        switch (transformOrigin) {
        case Item.TopRight:
        case Item.Right:
        case Item.BottomRight:
            return true;
        default:
            return false;
        }
    }
    readonly property bool bottomOrigin: {
        switch (transformOrigin) {
        case Item.BottomLeft:
        case Item.Bottom:
        case Item.BottomRight:
            return true;
        default:
            return false;
        }
    }
    readonly property bool horizontalCenterOrigin: {
        switch (transformOrigin) {
        case Item.Top:
        case Item.Bottom:
        case Item.Center:
            return true;
        default:
            return false;
        }
    }
    readonly property bool verticalCenterOrigin: {
        switch (transformOrigin) {
        case Item.Left:
        case Item.Right:
        case Item.Center:
            return true;
        default:
            return false;
        }
    }
    readonly property bool centerOrigin: transformOrigin === Item.Center

    property int side: 48
    property int maximumLength: horizontal ? Window.window.width : Window.window.height
    readonly property int implicitMinimumLength: {
        if (movingHorizontal) {
            return backgroundId.multiplier * 3/2 * (Math.max(backgroundId.topLeftCorner, backgroundId.topRightCorner) + Math.max(backgroundId.bottomLeftCorner, backgroundId.bottomRightCorner))
        }
        else {
            return backgroundId.multiplier * 3/2 * (Math.max(backgroundId.topLeftCorner, backgroundId.bottomLeftCorner) + Math.max(backgroundId.topRightCorner, backgroundId.bottomRightCorner))
        }
    }
    property int minimumLength: (shown || aBool) ? implicitMinimumLength : implicitMinimumLength / 2

    property bool shown: mouseAreaId.containsMouse
    readonly property int shownWidth: vertical ? side : Math.max(minimumLength, Math.min(maximumLength, containerId.implicitWidth))
    readonly property int shownHeight: horizontal ? side : Math.max(minimumLength, Math.min(maximumLength, containerId.implicitHeight))
    readonly property int hiddenWidth: vertical ? side : (aBool ? Math.max(minimumLength, implicitMinimumLength) : minimumLength)
    readonly property int hiddenHeight: horizontal ? side : (aBool ? Math.max(minimumLength, implicitMinimumLength) : minimumLength)
    readonly property int currentWidth: shown ? shownWidth : hiddenWidth
    readonly property int currentHeight: shown ? shownHeight : hiddenHeight

    property int padding: 0
    property int topPadding: padding
    property int leftPadding: padding
    property int rightPadding: padding
    property int bottomPadding: padding
    readonly property int horizontalPadding: leftPadding + rightPadding
    readonly property int verticalPadding: topPadding + bottomPadding

    property int margin: 0
    property int topMargin: margin
    property int leftMargin: margin
    property int rightMargin: margin
    property int bottomMargin: margin
    readonly property int horizontalMargin: leftMargin + rightMargin
    readonly property int verticalMargin: topMargin + bottomMargin

    property bool includeMargin: false
    property int includedTopMargin: (includeMargin && !vertical && movingVertical ? 0 : topMargin)
    property int includedLeftMargin: (includeMargin && !horizontal && movingHorizontal ? 0 : leftMargin)
    property int includedRightMargin: (includeMargin && !horizontal && movingHorizontal ? 0 : rightMargin)
    property int includedBottomMargin: (includeMargin && !vertical && movingVertical ? 0 : bottomMargin)
    property int includedHorizontalMargin: includedLeftMargin + includedRightMargin
    property int includedVerticalMargin: includedTopMargin + includedBottomMargin

//    property bool includePadding: false
//    property int includedHorizontalPadding: (includeMargin ? 0 : horizontalMargin)
//    property int includedVerticalPadding: (includeMargin ? 0 : verticalMargin)

    readonly property int availableWidth: root.shownWidth + root.includedHorizontalMargin - root.horizontalMargin - root.horizontalPadding//containerId.width
    readonly property int availableHeight: root.shownHeight + root.includedVerticalMargin - root.verticalMargin - root.verticalPadding//containerId.height
    readonly property int availableMinimum: (availableWidth === 0
                                             || availableHeight === 0 ? Math.max : Math.min)(
                                                availableWidth, availableHeight)
    readonly property real contentCorners: backgroundId.corners - padding

    property alias background: backgroundId
    property alias container: containerId
    property alias mouseArea: mouseAreaId

    property bool shrinkOnHiding: false
    width: (shrinkOnHiding ? currentWidth : shownWidth) + includedHorizontalMargin
    height: (shrinkOnHiding ? currentHeight : shownHeight) + includedVerticalMargin

    clip: true

    property int animationDuration: 200
    property int animationEasingType: Easing.OutSine//Easing.OutInQuint //Easing.OutInBack //Easing.OutInElastic

    readonly property int hiddenContainerWidth: root.hiddenWidth + root.includedHorizontalMargin - root.horizontalMargin
    readonly property int hiddenContainerHeight: root.hiddenHeight + root.includedVerticalMargin - root.verticalMargin

    property bool aBool: false

    //TODO: implement adequate animation

    Behavior on width {
        NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
    }
    Behavior on height {
        NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
    }

    SuperellipseShape {
        id: backgroundId
//        corners: 8
        transformOrigin: root.transformOrigin
//        visible: false
        path {
            fillColor: shown ? Palettes.current.barBg : Palettes.current.barHiddenBg
            Behavior on fillColor {
                ColorAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
            }
        }
        anchors {
            top: (root.movingVertical && root.topOrigin && (root.shown || root.aBool)) ? root.top : containerId.top
            topMargin: (root.movingVertical && root.topOrigin && (root.shown || root.aBool)) ? root.topMargin : 0
            Behavior on topMargin {
                NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
            }
            left: (root.movingHorizontal && root.leftOrigin && (root.shown || root.aBool)) ? root.left : containerId.left
            leftMargin: (root.movingHorizontal && root.leftOrigin && (root.shown || root.aBool)) ? root.leftMargin : 0
            Behavior on leftMargin {
                NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
            }
            right: (root.movingHorizontal && root.rightOrigin && (root.shown || root.aBool)) ? root.right : containerId.right
            rightMargin: (root.movingHorizontal && root.rightOrigin && (root.shown || root.aBool)) ? root.rightMargin : 0
            Behavior on rightMargin {
                NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
            }
            bottom: (root.movingVertical && root.bottomOrigin && (root.shown || root.aBool)) ? root.bottom : containerId.bottom
            bottomMargin: (root.movingVertical && root.bottomOrigin && (root.shown || root.aBool)) ? root.bottomMargin : 0
            Behavior on bottomMargin {
                NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
            }
        }
    }

    Grid {
        id: containerId

        topPadding: root.topPadding
        leftPadding: root.leftPadding
        rightPadding: root.rightPadding
        bottomPadding: root.bottomPadding

        transformOrigin: root.transformOrigin

//        width: root.shownWidth + root.includedHorizontalMargin - root.horizontalMargin/* - root.horizontalPadding*/
//        height: root.shownHeight + root.includedVerticalMargin - root.verticalMargin/* - root.verticalPadding*/
/*        anchors {
            top: (root.topOrigin) ? root.top : undefined
            topMargin: {
                if (root.shown) {
                    return root.topMargin;
                }
                else {
                    if (root.horizontal) {
                        if (root.movingHorizontal) return root.topMargin;
                        else
                        if (root.movingVertical) return -containerId.height + root.topMargin + root.hiddenHeight;
                    }
                    else
                    if (root.vertical) {
                        if (root.movingHorizontal) return root.topMargin;
                        else
                        if (root.movingVertical) return -containerId.height + root.topMargin + root.hiddenHeight;
                    }
                }
            }
            Behavior on topMargin {
                NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
            }
            left: (root.leftOrigin) ? root.left : undefined
            leftMargin: {
                if (root.shown) {
                    return root.leftMargin;
                }
                else {
                    if (root.horizontal) {
                        console.log(`Shown: ${root.leftMargin}; Hidden: ${-containerId.width + root.leftMargin + root.hiddenWidth}`);
                        if (root.movingHorizontal) return -containerId.width + root.leftMargin + root.hiddenWidth;
                        else
                        if (root.movingVertical) return root.leftMargin;
                    }
                    else
                    if (root.vertical) {
                        if (root.movingHorizontal) return -containerId.width + root.leftMargin + root.hiddenWidth;
                        else
                        if (root.movingVertical) return root.leftMargin;
                    }
                }
            }
            Behavior on leftMargin {
                NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
            }
            right: (root.rightOrigin) ? root.right : undefined
            rightMargin: {
                if (root.shown) {
                    return root.rightMargin;
                }
                else {
                    if (root.horizontal) {
                        if (root.movingHorizontal) return -containerId.width + root.rightMargin + root.hiddenWidth;
                        else
                        if (root.movingVertical) return root.rightMargin;
                    }
                    else
                    if (root.vertical) {
                        if (root.movingHorizontal) return -containerId.width + root.rightMargin + root.hiddenWidth;
                        else
                        if (root.movingVertical) return root.rightMargin;
                    }
                }
            }
            Behavior on rightMargin {
                NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
            }
            bottom: (root.bottomOrigin) ? root.bottom : undefined
            bottomMargin: {
                if (root.shown) {
                    return root.bottomMargin;
                }
                else {
                    if (root.horizontal) {
                        if (root.movingHorizontal) return root.bottomMargin;
                        else
                        if (root.movingVertical) return -containerId.height + root.bottomMargin + root.hiddenHeight;
                    }
                    else
                    if (root.vertical) {
                        if (root.movingHorizontal) return root.bottomMargin;
                        else
                        if (root.movingVertical) return -containerId.height + root.bottomMargin + root.hiddenHeight;
                    }
                }
            }
            Behavior on bottomMargin {
                NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
            }
            horizontalCenter: (root.horizontalCenterOrigin) ? root.horizontalCenter : undefined
            horizontalCenterOffset: root.leftMargin - root.rightMargin
            Behavior on horizontalCenterOffset {
                NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
            }
            verticalCenter: (root.verticalCenterOrigin) ? root.verticalCenter : undefined
            verticalCenterOffset: root.topMargin - root.bottomMarginm
            Behavior on verticalCenterOffset {
                NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
            }
        }
*/
        property int shownX: root.leftMargin//backgroundId.x/* + root.leftPadding*/
        property int shownY: root.topMargin//backgroundId.y/* + root.topPadding*/
        property int hiddenX: {
            if (root.movingHorizontal) {
                if (root.leftOrigin) {
                    return -containerId.width + (root.aBool ? root.leftMargin + root.hiddenContainerWidth : root.minimumLength);
                }
                if (root.rightOrigin) {
                    return root.width - (root.aBool ? root.rightMargin + root.hiddenContainerWidth : root.minimumLength);
                }
            }
            return shownX;
        }
        property int hiddenY: {
            if (root.movingVertical) {
                if (root.topOrigin) {
                    return -containerId.height + (root.aBool ? root.topMargin + root.hiddenContainerHeight : root.minimumLength);
                }
                if (root.bottomOrigin) {
                    return root.height - (root.aBool ? root.bottomMargin + root.hiddenContainerHeight : root.minimumLength);
                }
            }
            return shownY;
        }

        x: shown ? shownX : hiddenX
        y: shown ? shownY : hiddenY

        clip: true

        rows: +root.horizontal
        columns: +root.vertical

        opacity: +root.shown

        Behavior on opacity {
            NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
        }
        Behavior on x {
            NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
        }
        Behavior on y {
            NumberAnimation { duration: root.animationDuration; easing.type: root.animationEasingType }
        }
    }

    MouseArea {
        id: mouseAreaId
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        preventStealing: false
        transformOrigin: root.transformOrigin

        onPositionChanged: function (mouse) {
            mouse.accepted = false;
        }
        onPressAndHold: function (mouse) {
            mouse.accepted = false;
        }
        onClicked: function(mouse) {
            mouse.accepted = false;
        }
        onDoubleClicked: function(mouse) {
            mouse.accepted = false;
        }
        onPressed: function(mouse) {
            mouse.accepted = false;
        }
        onReleased: function(mouse) {
            mouse.accepted = false;
        }
    }
}
