import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/common.js" as Common

Page {
    id: root

    property var http: {new XMLHttpRequest()}
    property QtObject cityManager: undefined

    signal toggleCity(string name, bool checked)

    PageHeader {
        id: header
        objectName: "pageHeader"
        title: qsTr("Find")
    }

    Timer {
        id: searchTimer
        interval: 700
        onTriggered: {
            console.log("timer triggered");
            const request = "https://geocoding-api.open-meteo.com/v1/search?"
                      + "name=" + searchField.text
                      + "&count=10&language=ru&format=json";
            Common.makeRequest(root.http, "GET", request, function(json) {
                const data = Common.processCity(json);
                listModel.update(data);
            })
        }
    }

    SearchField {
        id: searchField
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
        }
        onTextChanged: {
            searchTimer.running = false;
            if (text.length === 0) {
                listModel.update(null);
            } else {
                console.log("start timer")
                searchTimer.running = true;
            }
        }
        focus: true
    }

    SilicaListView {
        clip: true

        anchors {
            top: searchField.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        model: ListModel {
            id: listModel

            function update(data) {
                clear();
                if (data !== undefined && data !== null) {
                    for (var prop in data) {
                        const v = data[prop];
                        append(v);
                    }
                }
            }
        }

        delegate: Row {
            width: ListView.width
            height: Theme.itemSizeSmall

            IconButton {
                property bool checked: false

                icon.source: checked ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
                onClicked: {
                    checked = !checked;
                    const data = parent.copyProps();
                    cityManager.toggleCity(v_name, checked, data);
                }
            }

            Button {
                text: v_name
                onClicked: {
                    console.log("select current city", text);
                    root.cityManager.currentCity = text;
                    const data = parent.copyProps();
                    root.cityManager.currentCityData = data;
                    pageStack.pop();
                }
            }

            function copyProps() {
                const item = listModel.get(index);
                const data = {};
                for (var prop in item) {
                    data[prop] = item[prop];
                }
                return data;
            }
        }
    }
}
