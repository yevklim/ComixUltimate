pragma Singleton
import QtQuick 2.15
//import QtPositioning 5.15
//import QtGraphicalEffects 1.12
import QtQuick.Controls 2.15
//import QtQuick.Extras 1.4
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQml.Models 2.15
import QtQuick.Shapes 1.0
import ComixUltimate 1.0

Item {
    property Component palettesEditor: Component{
        CustomPopup {
            id: popup
            positioner: Column {
                id: popupColumn
                property int widthOfFirstLabels: 0
                spacing: 4
                CustomComboBox {
                    model: Palettes.paletteNames
                    currentIndex: model.indexOf(Palettes.currentName)
                    height: 32
                    onActivated: {
                        Palettes.currentName = currentValue;
//                        popupColumn.modifiedItemModel["type"] = currentIndex;
//                        console.log(currentIndex, currentText, currentValue);
                    }
                }
                Repeater {
                    model: Palettes.colorNames
                    Row {
                        height: 32
                        spacing: 16
                        Text {
                            text: modelData
                            color: Palettes.current.popupFg
                            Component.onCompleted: {
                                if (popupColumn.widthOfFirstLabels < implicitWidth) popupColumn.widthOfFirstLabels = implicitWidth;
                            }
                            width: popupColumn.widthOfFirstLabels
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        TextInput {
                            width: 64
                            color: Palettes.current.popupFg
                            text: Palettes.current[modelData]
                            onTextEdited: {Palettes.setColor(modelData, text);}
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Rectangle {
                            height: 32
                            width: 32
                            color: Palettes.current[modelData]
                            border {
                                color: Palettes.current.popupFg
                                width: 2
                            }
                        }
                    }
                }
                Text {
                    text: `New color: `
                    color: Palettes.current.popupFg
                    height: 32
                }
                Row {
                    height: 48
                    spacing: 16
                    CustomTextField {
                        id: colorNameId
                        backgroundRef.corners: 8
                        width: (popupColumn.width - popupColumn.leftPadding - popupColumn.rightPadding - 64) / 2 -parent.spacing
                        height: 48
                        color: Palettes.current.popupFg
                        text: ""
                        placeholderText: "color name"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    CustomTextField {
                        id: colorId
                        backgroundRef.corners: 8
                        width: colorNameId.width
                        height: 48
                        color: Palettes.current.popupFg
                        text: ""
                        placeholderText: "color"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    CustomButton {
                        text: "Add"
                        corners: 8
                        width: 64
                        height: 48
                        onClicked: {
                            Palettes.addNewColor(colorNameId.text, colorId.text)
                        }
                    }
                }
                CustomButton {
                    text: "Close"
                    corners: 8
                    width: parent.width - parent.leftPadding - parent.rightPadding
                    height: 48
                    onClicked: {
                        popup.close();
                    }
                }

            }
        }
    }
    property Component itemEditor: Component{
        CustomPopup {
            id: popup
            property var itemModel: ({})
            property var modifiedItemModel: ({})

            positioner: Column {
                id: popupColumn
                // duplicates bc of fucking ComboBox that can't find it from popup
                property var itemModel: popup.itemModel
                property var modifiedItemModel: popup.modifiedItemModel
                property int widthOfFirstLabels: 0
                spacing: 8
                Text {
                    text: `Edit item: ${popup.itemModel.title}\n${popup.itemModel.hash}`
                    color: Palettes.current.popupFg
                    height: 32
                }
                Row {
                    height: 32
                    spacing: 16
                    Text {
                        text: qsTr("type")
                        color: Palettes.current.popupFg
                        Component.onCompleted: {
                            if (popupColumn.widthOfFirstLabels < implicitWidth) popupColumn.widthOfFirstLabels = implicitWidth;
                        }
                        width: popupColumn.widthOfFirstLabels
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    CustomComboBox {
                        model: ["UndefinedType",
                                "ComicBook",
                                "ArtBook",
                                "Video",
                                "VideoCollection"]
                        currentIndex: popupColumn.itemModel["type"]
                        onActivated: {
                            popupColumn.modifiedItemModel["type"] = currentIndex;
                        }
                    }
                }
                Repeater {
                    model: ["title", "source", "cover"]
                    Row {
                        height: 32
                        spacing: 16
                        Text {
                            text: qsTr(modelData)
                            color: Palettes.current.popupFg
                            Component.onCompleted: {
                                if (popupColumn.widthOfFirstLabels < implicitWidth) popupColumn.widthOfFirstLabels = implicitWidth;
                            }
                            width: popupColumn.widthOfFirstLabels
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        TextInput {
                            width: popup.maximumWidth * .5
                            color: Palettes.current.popupFg
                            text: popup.itemModel[modelData]
                            anchors.verticalCenter: parent.verticalCenter
                            onTextChanged: {
                                popup.modifiedItemModel[modelData] = text;
                            }
                            clip:true
                        }
                    }
                }
                Repeater {
                    model: ["added", "lastview"]
                    Row {
                        height: 32
                        spacing: 16
                        Text {
                            text: qsTr(modelData)
                            color: Palettes.current.popupFg
                            Component.onCompleted: {
                                if (popupColumn.widthOfFirstLabels < implicitWidth) popupColumn.widthOfFirstLabels = implicitWidth;
                            }
                            width: popupColumn.widthOfFirstLabels
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            width: popup.maximumWidth * .5
                            color: Palettes.current.popupFg
                            text: new Date(itemModel[modelData]).toLocaleString()
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Row {
                    height: 32
                    spacing: 16
                    Text {
                        text: qsTr("rate")
                        color: Palettes.current.popupFg
                        Component.onCompleted: {
                            if (popupColumn.widthOfFirstLabels < implicitWidth) popupColumn.widthOfFirstLabels = implicitWidth;
                        }
                        width: popupColumn.widthOfFirstLabels
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    TextInput {
                        width: popup.maximumWidth * .5
                        color: Palettes.current.popupFg
                        text: popup.itemModel["rate"]
                        inputMethodHints: Qt.ImhDigitsOnly
                        anchors.verticalCenter: parent.verticalCenter
                        onTextChanged: {
                            popup.modifiedItemModel["rate"] = text;
                        }
                        clip:true
                    }
                }
                Row {
//                    property int minimumHeight: 32
//                    height: Math.min(flow.implicitContentHeight, minimumHeight)
                    spacing: 16
                    Text {
                        text: qsTr("tags")
                        color: Palettes.current.popupFg
                        Component.onCompleted: {
                            if (popupColumn.widthOfFirstLabels < implicitWidth) popupColumn.widthOfFirstLabels = implicitWidth;
                        }
                        width: popupColumn.widthOfFirstLabels
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ScrollView {
                        clip: true
                        width: popup.width - popupColumn.widthOfFirstLabels - popupColumn.leftPadding - popupColumn.rightPadding - parent.spacing
                        height: popup.maximumHeight * .4
                        padding: 0
                        Flow {
                            id: flow
                            width: parent.width - parent.leftPadding - parent.rightPadding//popup.maximumWidth * .5
                            spacing: 4
                            Repeater {
                                model: DataBase.tags
                                CustomButton {
                                    text: (modelData).toUpperCase()
                                    checkable: true
                                    checked: popup.itemModel.has_tag(modelData)
                                    corners: 4
                                    padding: 4
//                                    topLeftCorner: 8
//                                    bottomRightCorner: 8
                                    height: 32
                                    onCheckedChanged: {
                                        if (popup.modifiedItemModel["tags"] == undefined)
                                        {
                                            popup.modifiedItemModel["tags"] = popup.itemModel["tags"].join(";").split(";");
                                        }
                                        if (checked) {
                                            if (popup.modifiedItemModel["tags"].indexOf(modelData) === -1) {
                                                popup.modifiedItemModel["tags"].push(modelData);
                                            }
                                        }
                                        else if (popup.modifiedItemModel["tags"].indexOf(modelData) !== -1) {
                                            popup.modifiedItemModel["tags"].pop(modelData);
                                        }
                                    }
                                }
                            }
                        }
                    }

                }
                Row {
                    height: 48
                    spacing: 16
                    IconButton2 {
                        text: "Save changes"
                        corners: 12
//                        topLeftCorner: 8
//                        bottomRightCorner: 8
    //                    width: parent.width - parent.leftPadding - parent.rightPadding
    //                    height: 32
                        side: 48
                        icon_ref {
                            iconCode: "okay"
                            iconSize: 32
                            layer.samples: 8
                        }
                        onClicked: {
    //                        console.log(Object.keys(popup.itemModelChanged))
    //                        console.log(Object.values(popup.itemModelChanged))
                            for (let prop of Object.keys(popup.modifiedItemModel)) {
                                popup.itemModel[prop] = popup.modifiedItemModel[prop];
                            }
                        }
                    }
                    IconButton2 {
                        text: "Close"
                        corners: 12
//                        topLeftCorner: 8
//                        bottomRightCorner: 8
    //                    width: parent.width - parent.leftPadding - parent.rightPadding
    //                    height: 32
                        side: 48
                        icon_ref {
                            iconCode: "close"
                            iconSize: 32
                            layer.samples: 8
                        }
                        onClicked: {
                            popup.close();
                        }
                    }
                    IconButton2 {
                        text: "Delete"
                        corners: 12
//                        topLeftCorner: 8
//                        bottomRightCorner: 8
                        bgColorDefault: "#761d1e"
                        bgColorHover: "#761d1e"
                        bgColorPressed: "#d43437"
                        fgColorDefault: "#110404"
                        fgColorHover: "#110404"
                        fgColorPressed: "#110404"
    //                    width: parent.width - parent.leftPadding - parent.rightPadding
    //                    height: 32
                        side: 48
                        icon_ref {
                            iconCode: "delete2"
                            iconColor: fgColor
                            iconSize: 32
                            layer.samples: 8
                        }
                        property bool sureDelete: false
                        onClicked: {
                            if (!sureDelete) {
                                text = "PERMANENTLY DELETE"
                                sureDelete = true;
                            }
                            else {
                                let source = popup.itemModel.source;
                                popup.resetPopup();
                                DataBase.remove_item(source);
                            }
                        }
                    }
                }

            }
        }
    }
    property Component itemCreator: Component{
        CustomPopup { //A FATAL BUG
            id: popup
            property var dataBase
            property DBItem itemModel: dataBase.get_new_item()
            property var modifiedItemModel: ({})

            positioner: Column {
                id: popupColumn
                // duplicates bc of fucking ComboBox that can't find it from popup
                property var itemModel: popup.itemModel
                property var modifiedItemModel: popup.modifiedItemModel
                property int widthOfFirstLabels: 0
                spacing: 8
                Text {
                    text: `Add item: ${popup.itemModel.title}`
                    color: Palettes.current.popupFg
                    height: 32
                }
                Row {
                    height: 32
                    spacing: 16
                    Text {
                        text: qsTr("type")
                        color: Palettes.current.popupFg
                        Component.onCompleted: {
                            if (popupColumn.widthOfFirstLabels < implicitWidth) popupColumn.widthOfFirstLabels = implicitWidth;
                        }
                        width: popupColumn.widthOfFirstLabels
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    CustomComboBox {
                        model: ["UndefinedType",
                                "ComicBook",
                                "ArtBook",
                                "Video",
                                "VideoCollection"]
                        currentIndex: popupColumn.itemModel["type"]
                        onActivated: {
                            popupColumn.modifiedItemModel["type"] = currentIndex;
                        }
                    }
                }
                Repeater {
                    model: ["title", "source", "cover"]
                    Row {
                        height: 32
                        spacing: 16
                        Text {
                            text: qsTr(modelData)
                            color: Palettes.current.popupFg
                            Component.onCompleted: {
                                if (popupColumn.widthOfFirstLabels < implicitWidth) popupColumn.widthOfFirstLabels = implicitWidth;
                            }
                            width: popupColumn.widthOfFirstLabels
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        TextInput {
                            width: popup.maximumWidth * .5
                            color: Palettes.current.popupFg
                            text: popup.itemModel[modelData]
                            anchors.verticalCenter: parent.verticalCenter
                            onTextChanged: {
                                popup.modifiedItemModel[modelData] = text;
                            }
                            clip:true
                        }
                    }
                }
                Repeater {
                    model: ["added", "lastview"]
                    Row {
                        height: 32
                        spacing: 16
                        Text {
                            text: qsTr(modelData)
                            color: Palettes.current.popupFg
                            Component.onCompleted: {
                                if (popupColumn.widthOfFirstLabels < implicitWidth) popupColumn.widthOfFirstLabels = implicitWidth;
                            }
                            width: popupColumn.widthOfFirstLabels
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            width: popup.maximumWidth * .5
                            color: Palettes.current.popupFg
                            text: modelData == "added" ? new Date(Date.now()).toLocaleString() : "Never"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Row {
                    height: 32
                    spacing: 16
                    Text {
                        text: qsTr("rate")
                        color: Palettes.current.popupFg
                        Component.onCompleted: {
                            if (popupColumn.widthOfFirstLabels < implicitWidth) popupColumn.widthOfFirstLabels = implicitWidth;
                        }
                        width: popupColumn.widthOfFirstLabels
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    TextInput {
                        width: popup.maximumWidth * .5
                        color: Palettes.current.popupFg
                        text: popup.itemModel["rate"]
                        validator: IntValidator{bottom: 0; top: 5;}
                        inputMethodHints: Qt.ImhDigitsOnly
                        anchors.verticalCenter: parent.verticalCenter
                        onTextChanged: {
                            popup.modifiedItemModel["rate"] = text;
                        }
                        clip:true
                    }
                }
                Row {
                    property int minimumHeight: 32
                    height: Math.min(flow.implicitContentHeight, minimumHeight)
                    spacing: 16
                    Text {
                        text: qsTr("tags")
                        color: Palettes.current.popupFg
                        Component.onCompleted: {
                            if (popupColumn.widthOfFirstLabels < implicitWidth) popupColumn.widthOfFirstLabels = implicitWidth;
                        }
                        width: popupColumn.widthOfFirstLabels
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ScrollView {
                        clip: true
                        width: flow.implicitWidth
                        height: popup.maximumHeight * .4
                        padding: 0
                        Flow {
                            id: flow
                            width: popup.maximumWidth * .5
                            spacing: 4
                            Repeater {
                                model: DataBase.tags
                                CustomButton {
                                    text: (modelData).toUpperCase()
                                    checkable: true
                                    checked: popup.itemModel.has_tag(modelData)
                                    topLeftCorner: 8
                                    bottomRightCorner: 8
                                    height: 32
                                    onCheckedChanged: {
                                        if (popup.modifiedItemModel["tags"] == undefined)
                                        {
                                            popup.modifiedItemModel["tags"] = popup.itemModel["tags"].join(";").split(";");
                                        }
                                        if (checked) {
                                            if (popup.modifiedItemModel["tags"].indexOf(modelData) === -1) {
                                                popup.modifiedItemModel["tags"].push(modelData);
                                            }
                                        }
                                        else if (popup.modifiedItemModel["tags"].indexOf(modelData) !== -1) {
                                            popup.modifiedItemModel["tags"].pop(modelData);
                                        }
                                    }
                                }
                            }
                        }
                    }

                }
                Row {
                    height: 48
                    spacing: 16
                    IconButton2 {
                        text: "Save changes"
                        topLeftCorner: 8
                        bottomRightCorner: 8
    //                    width: parent.width - parent.leftPadding - parent.rightPadding
    //                    height: 32
                        side: 48
                        icon_ref {
                            iconCode: "okay"
                            iconSize: 32
                            layer.samples: 8
                        }
                        onClicked: {
    //                        console.log(Object.keys(popup.itemModelChanged))
    //                        console.log(Object.values(popup.itemModelChanged))
                            for (let prop of Object.keys(popup.modifiedItemModel)) {
                                popup.itemModel[prop] = popup.modifiedItemModel[prop];
                            }
                            popup.itemModel.added = Date.now();
                            popup.dataBase.add_new_item();
                            popup.close();
                        }
                    }
                    IconButton2 {
                        text: "Close"
                        topLeftCorner: 8
                        bottomRightCorner: 8
    //                    width: parent.width - parent.leftPadding - parent.rightPadding
    //                    height: 32
                        side: 48
                        icon_ref {
                            iconCode: "close"
                            iconSize: 32
                            layer.samples: 8
                        }
                        onClicked: {
                            popup.close();
                        }
                    }
                }

            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.9;height:480;width:640}
}
##^##*/
