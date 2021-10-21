import QtQuick 2.15

QtObject {
    id: root

    readonly property int currentValue: Math.max(helpingTimerId.value, mainTimerId.interval)
    property alias updateInterval: helpingTimerId.interval

    property alias interval: mainTimerId.interval
    property alias repeat: mainTimerId.repeat
    property alias running: mainTimerId.running
    property alias triggeredOnStart: mainTimerId.triggeredOnStart

    function start() { mainTimerId.customStart(); started() }
    function stop() { mainTimerId.customStop(); stopped() }
    function restart() { mainTimerId.customRestart(); restarted() }

    onIntervalChanged: {
        if (running) restart();
    }

    signal triggered()
    signal started()
    signal stopped()
    signal restarted()
    signal currentValueUpdated(int value)

    property Timer mainTimer: Timer {
        id: mainTimerId
        readonly property var customStart: function() {
            helpingTimerId.value = 0;
            start();
            helpingTimerId.start();
    //        helpingTimer.start();
        }
        readonly property var customStop: function() {
            stop();
            helpingTimerId.stop();
            helpingTimerId.value = 0;
    //        helpingTimer.stop();
        }
        readonly property var customRestart: function() {
            stop();
            helpingTimerId.stop();
            helpingTimerId.value = 0;
            start();
            helpingTimerId.start();
        }
        onTriggered: {
            root.triggered();
            helpingTimerId.value = 0;
        }
    }
    property Timer helpingTimer: Timer {
        id: helpingTimerId
        property int value: 0
        interval: 100
        repeat: mainTimerId.running
        running: mainTimerId.running
        onTriggered: {
            value += interval;
            root.currentValueUpdated(value);
        }
    }
}
