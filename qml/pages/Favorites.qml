import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: root

    property QtObject cityManager: undefined

    PageHeader {
        id: header
        objectName: "pageHeader"
        title: qsTr("Favorites")
    }

    SilicaListView {
        clip: true

        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        model: root.cityManager

        delegate: Row {
            width: ListView.width
            height: Theme.itemSizeSmall

            IconButton {
                id: favoriteButton
                icon.source: favorite ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
                onClicked: favorite = !favorite
            }

            Button {
                id: labelName
                text: cityName
                onClicked: {
                    console.log("select current city", text);
                    root.cityManager.currentCity = text;
                    root.cityManager.loadCurrentCityDataFromFavorite();
                    pageStack.pop();
                }
            }
        }

        Component.onDestruction: {
            root.cityManager.apply()
        }
    }
}
