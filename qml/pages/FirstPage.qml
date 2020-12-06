import QtQuick 2.6
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0
import Nemo.Thumbnailer 1.0

Page {
    id: page

    onVisibleChanged: {
        if (visible)
        {
            appWin.refresh()
        }
    }


    Connections {
        target: appWin
        onNumRadarImagesChanged: {
            radarImage.index = appWin.numRadarImages-1
        }
    }


    allowedOrientations: Orientation.Portrait

    SilicaFlickable {
        id: flick
        anchors.fill: parent


        Label {
            id: dateLabel
            color: Theme.highlightColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingMedium
        }

        Image {
            id: bg
            source: "highres.png"
            property real factor: Math.max(Screen.height/887, Screen.width/471)
            height: 887*factor
            width: 471*factor
            anchors.centerIn: parent
            opacity: 0.3
        }

        Image {
            id: cities
            source: "cities_borders.png"
            anchors.fill: bg
        }

        ColorOverlay {
            anchors.fill: cities
            source: cities
            color: Theme.highlightColor
        }

        Image {
            id: radarImage
            anchors.fill: bg
            cache: true
            opacity: 0

            property int index
            onIndexChanged: {
                doUpdate()
                timer.start()
            }

            Timer {
                id: timer
                interval: 100
                onTriggered: parent.doUpdate()
                running: false
                repeat: false
            }

            function doUpdate() {
                if(!timer.running)
                {
                    if(status == Image.Loading)
                    {
                        timer.restart()
                        return
                    }

                    dateLabel.text = Qt.formatDateTime(new Date(new Date(radarImages[index].valid) - new Date().getTimezoneOffset()*60000), "yyyy-MM-dd hh:mm")
                    source = radarImages[index].formats[0].link
                }
            }

            onStatusChanged: {
                if(status == Image.Ready)
                {
                    actualRadarImage.source = source
                }
            }
        }

        Rectangle
        {
            height: 0.1*Screen.height
            width: bg.width
            anchors.horizontalCenter: bg.horizontalCenter
            anchors.top: parent.top
            color: "#10000000"

        }

        Rectangle
        {
            id: croprect
            height: 0.9*parent.height
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            clip: true
            color: "#00000000"

            Image {
                id: actualRadarImage
                height: bg.height
                width: bg.width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: flick.height*-0.05

                cache: true
            }

        }

        IconButton {
            icon.source: "image://theme/icon-m-sync"
            z: 100
            anchors.right: parent.right
            anchors.rightMargin: Theme.itemSizeSmall
            anchors.bottom: sourceLabel.top
            anchors.bottomMargin: Theme.itemSizeSmall
            onClicked: {
                radarImage.index = appWin.numRadarImages-1
                appWin.refresh()
            }
        }


        Label {
            id: sourceLabel
            text: qsTr("Radar: SMHI")+"\n"+qsTr("Karta: Lantmäteriet")
            color: Theme.highlightBackgroundColor
            font.pixelSize: Theme.fontSizeExtraSmall
            anchors.bottom: parent.bottom
            anchors.right: parent.right
        }


        MouseArea {
            anchors.fill: parent
            onMouseXChanged: {
                if(mouseX < Theme.paddingMedium)
                {
                    radarImage.index = 0
                }
                else if(mouseX > (Screen.width-Theme.paddingMedium))
                {
                    radarImage.index = appWin.numRadarImages-1
                }
                else
                {
                    radarImage.index = Math.floor(((mouseX-Theme.paddingMedium)*appWin.numRadarImages)
                                                  /(Screen.width-2*Theme.paddingMedium))
                }
            }

        }

    }
}
