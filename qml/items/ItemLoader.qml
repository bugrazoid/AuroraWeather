import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    function show() {
        labelLoader.visible = true;
    }

    function hide() {
        stop();
    }

    function start() {
        console.log("loader start");
        timerLoader.start();
    }

    function stop() {
        console.log("loader stop");
        timerLoader.stop();
        labelLoader.visible = false;
    }


    Timer {
        id: timerLoader
        interval: 1000
        onTriggered: {
            console.log("timerLoader.onTriggered");
            labelLoader.visible = true;
            stop();
        }
    }

    Label {
        id: labelLoader
        text: "Loading"
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        visible: false
    }
}
