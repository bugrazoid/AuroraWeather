/*******************************************************************************
**
** Copyright (C) 2022 ru.bugrazoid
**
** This file is part of the Погода где угодно project.
**
** Redistribution and use in source and binary forms,
** with or without modification, are permitted provided
** that the following conditions are met:
**
** * Redistributions of source code must retain the above copyright notice,
**   this list of conditions and the following disclaimer.
** * Redistributions in binary form must reproduce the above copyright notice,
**   this list of conditions and the following disclaimer
**   in the documentation and/or other materials provided with the distribution.
** * Neither the name of the copyright holder nor the names of its contributors
**   may be used to endorse or promote products derived from this software
**   without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
** AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
** THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
** FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
** IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
** FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
** OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
** PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS;
** OR BUSINESS INTERRUPTION)
** HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
** WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE)
** ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
** EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
*******************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import ru.bugrazoid.Types 1.0
import "../js/common.js" as Common

Page {
    id: root
    objectName: "mainPage"

    property var http: {new XMLHttpRequest()}

    signal updateCurrentCityDataAcuired()
    onUpdateCurrentCityDataAcuired: update()

    Component.onCompleted: {
        updateUI(cityManager.currentCityData)
        update()
    }

    allowedOrientations: Orientation.All

    function updateWeather(lat, lon) {
        console.log("updateWeather");
        const request = "https://api.open-meteo.com/v1/forecast?"
                      + "latitude=" + lat
                      + "&longitude=" + lon
                      + "&current_weather=true";
        Common.makeRequest(root.http, "GET", request, function(json) {
            const data = Common.processWeather(json);
            cityManager.currentCityData = data;
            updateTimer.start();
        });
    }

    function updateCurrentCityData() {
        console.log("updateCurrentCityData");

        const request = "https://geocoding-api.open-meteo.com/v1/search?"
                      + "name=" + cityManager.currentCity
                      + "&count=10&language=ru&format=json";
        Common.makeRequest(root.http, "GET", request, function(json) {
            const data = Common.processCity(json)[cityManager.currentCity];
            if (data !== undefined) {
                cityManager.currentCityData = data;
            } else {
                console.error("update city data failed");
            }
            updateCurrentCityDataAcuired();
        });
    }

    function update() {
        console.log("update");
        if (cityManager.currentCityData.v_lat !== undefined && cityManager.currentCityData.v_lon !== undefined) {
            updateWeather(cityManager.currentCityData.v_lat, cityManager.currentCityData.v_lon);
        } else {
            updateCurrentCityData();
        }
    }

    function updateUI(data) {
        console.log("updateUI");
        const cw = data["v_current_weather"];
        labelTemp.text = cw["v_temp"];
        weatherIcon.weatherCode = cw["v_weathercode"];
        labelWind.windspeed = cw["v_windspeed"];
        labelWindDirection.rotation = cw["v_winddirection"];
    }

    CityManager {
        id: cityManager
        onCurrentCityChanged: {
            updateTimer.stop();
            favoriteSwitch.checked = currentCityFavorite;
            update();
        }
        onCurrentCityDataChanged: updateUI(currentCityData)
    }

    Timer {
        id: updateTimer
        interval: 10000
        onTriggered: {
            console.log("timer");
            updateCurrentCityData();
        }
    }


    PageHeader {
        id: header
        objectName: "pageHeader"
        title: qsTr("Weather")
        extraContent.children: [
            IconButton {
                objectName: "aboutButton"
                icon.source: "image://theme/icon-m-about"
                anchors.verticalCenter: parent.verticalCenter

                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        ]
    }

    Item {
        id: itemCity
        height: findButton.height
        width: parent.width
        anchors {
            top: header.bottom
        }

        IconButton {
            id: buttonCleanSettings
            anchors {
                left: parent.left
            }
            icon.source: "image://theme/icon-m-wizard"
            onClicked: cityManager.clean()
        }

        Label {
            id: cityName
            text: cityManager.currentCity
            anchors {
                left: buttonCleanSettings.right
                right: findButton.left
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            height: findButton.height
            color: "white"
        }
        IconButton {
            id: findButton
            icon.source: "image://theme/icon-m-search"
            anchors {
                right: parent.right
            }
            onClicked: pageStack.push(Qt.resolvedUrl("FindCity.qml"), {"cityManager": cityManager})
        }
    }

    Item {
        id: itemWeather
        height: 300
        width: parent.width
        anchors {
            top: itemCity.bottom
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter

            Icon {
                id: weatherIcon
                property int weatherCode: -1

                onWeatherCodeChanged: {
                    console.log("onWeatherCodeChanged:", weatherCode);
                    var v = null;
                    switch (weatherCode) {
                    case 0: v = "icon-l-weather-d000-dark"; break;
                    case 1: v = "icon-l-weather-d100-dark"; break;
                    case 2: v = "icon-l-weather-d200-dark"; break;
                    case 3: v = "icon-m-weather-d400-dark"; break;
                    case 61: v = "icon-l-weather-d410-dark"; break;
                    case 63: v = "icon-l-weather-d420-dark"; break;
                    case 65: v = "icon-l-weather-d430-dark"; break;
                    case 71: v = "icon-l-weather-d412-dark"; break;
                    case 73: v = "icon-l-weather-d422-dark"; break;
                    case 75: v = "icon-l-weather-d432-dark"; break;
                    default: v = "icon-l-attention"; break;
                    };
                    source = "image://theme/" + v;
                }
            }

            Label {
                id: labelTemp
                text: "??"
                font.pixelSize: weatherIcon.height
                horizontalAlignment: Text.horizontalCenter
            }
        }
    }

    Item {
        id: itemWind
        anchors {
            top: itemWeather.bottom
            left: parent.left
            right: parent.right
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter

            Label {
                id: labelWind
                property double windspeed: -1
                text: qsTr("Ветер: ") + windspeed + qsTr("м/с") + " "
            }

            Label {
                id: labelWindDirection
                text: "^"
            }
        }
    }

    Item {
        id: footer
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        IconButton {
            id: favoriteSwitch

            property bool checked: cityManager.currentCityFavorite

            icon.source: checked ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
            onClicked: {
                checked = !checked;
                cityManager.currentCityFavorite = checked;
            }
            anchors {
                left: parent.left
                bottom: parent.bottom
            }
        }
        IconButton {
            id: favoriteButton
            icon.source: "image://theme/icon-m-whereami"
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            onClicked: pageStack.push(Qt.resolvedUrl("Favorites.qml"), {"objectName": "Favorites", "cityManager": cityManager})
        }
    }
}
