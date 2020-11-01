import QtQuick 2.0
import Sailfish.Silica 1.0

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
        source: "../pages/basemap.png"
        property real factor: Math.max(parent.height/887, parent.width/471)
        height: 887*factor
        width: 471*factor
        anchors.centerIn: parent
        opacity: 0.3
        Component.onCompleted: console.log(factor, height, width)
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
