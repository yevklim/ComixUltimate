import QtQuick 2.5
import QtQuick.Controls 2.15
//import QtGraphicalEffects 1.15

CustomButton {
    id: root
    padding: 0
    font.pixelSize: 24
//    clip: true
    readonly property alias textInput: textinput
    readonly property alias label1: label1st
    readonly property alias label2: label2nd
    property int widthOnInput: textinput.width
    implicitWidth: Math.max(label1st.width, label2nd.width, textinput.width) + leftPadding + rightPadding

    states: [
        State {
            name: "inputMode"
            PropertyChanges {
                target: textinput
                opacity: 1
                focus: true
            }
            PropertyChanges {
                target: label1st
                opacity: 0
                focus: false
            }
            PropertyChanges {
                target: label2nd
                opacity: 0
                focus: false
            }
        }
    ]
    contentItem: Item {
        anchors.fill: root
        Text {
            id: label1st
            anchors.centerIn: parent
            opacity: 1
            color: root.fgColor
        }
        Text {
            id: label2nd
            anchors.centerIn: parent
            opacity: 0
            color: label1st.color
            font: label1st.font
        }
        TextInput {
            id: textinput
            color: root.fgColor
            selectedTextColor: root.bgColor
            selectionColor: root.fgColor
            font: root.font
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            cursorVisible: true
            opacity: 0
            onEditingFinished: root.state = ""
            onFocusChanged: {
                if (focus === false) {
                    textInput.editingFinished();
                }
            }
        }
    }
    onClicked: root.state = "inputMode"
}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.1}
}
##^##*/
