import QtQuick 2.6
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0
import Nemo.Thumbnailer 1.0

Page {
    id: page
    property date now
    property bool initialized: false
    property var radarImages
    property int numRadarImages

    onNowChanged: {
        console.log(now)
        // TODO: reset stuff if day changed

        var xhr = new XMLHttpRequest;
        xhr.onreadystatechange = (function(myxhr) {
            return function() {
                if(myxhr.readyState === 4)
                {
                    console.log("woop", myxhr.responseText)
                    radarImages = JSON.parse(myxhr.responseText).files
                }
            }
        })(xhr);
        xhr.open('GET', "https://opendata-download-radar.smhi.se/api/version/latest/area/sweden/product/comp/"
                        +now.getFullYear()+"/"+(now.getMonth()+1)+"/"+now.getDate()+"?format=png", true);
        xhr.send('');
    }

    onVisibleChanged: refresh()

    function refresh() {
        if(visible)
        {
            now = new Date(new Date() - new Date().getTimezoneOffset()*60000)
        }
    }

    onRadarImagesChanged: {
        numRadarImages = radarImages.length
        radarImage.index = numRadarImages-1
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
            source: "basemap.png"
            property real factor: Math.max(Screen.height/887, Screen.width/471)
            height: 887*factor
            width: 471*factor
            anchors.centerIn: parent
            opacity: 0.3
            Component.onCompleted: console.log(factor, height, width)
        }

        Image {
            id: cities
            source: "cities.png"
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

            onSourceChanged: console.log(source)

            Timer {
                id: timer
                interval: 100
                onTriggered: parent.doUpdate()
                running: false
                repeat: false
            }

            function doUpdate() {
                console.log("unup", index, status)
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
            anchors.right: parent.right
            anchors.rightMargin: Theme.itemSizeSmall
            anchors.bottom: sourceLabel.top
            anchors.bottomMargin: Theme.itemSizeSmall
            onClicked: refresh()
        }


        Label {
            id: sourceLabel
            text: qsTr("Källa: SMHI")
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
                    radarImage.index = numRadarImages-1
                }
                else
                {
                    radarImage.index = Math.floor(((mouseX-Theme.paddingMedium)*numRadarImages)
                                                  /(Screen.width-2*Theme.paddingMedium))
                }
            }

        }

    }
}