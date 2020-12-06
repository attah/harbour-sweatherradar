import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

CoverBackground {
    id: cover

    Connections {
        target: appWin
        onNumRadarImagesChanged: {
            coverRadarImage.source = radarImages[numRadarImages-1].formats[0].link
        }
    }


    Image {
        id: coverBg
        source: "../pages/highres.png"
        property real factor: Math.max(parent.height/887, parent.width/471)
        height: 887*factor
        width: 471*factor
        anchors.centerIn: parent
        opacity: 0.3
    }

    Image {
        id: coverCities
        source: "../pages/cities_borders.png"
        anchors.fill: coverBg
    }

    ColorOverlay {
        anchors.fill: coverCities
        source: coverCities
        color: Theme.highlightColor
    }

    Image {
        id: coverRadarImage
        height: coverBg.height
        width: coverBg.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        cache: true
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-sync"
            onTriggered: appWin.refresh()
        }
    }
}
