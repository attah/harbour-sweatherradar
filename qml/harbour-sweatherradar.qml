import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id: appWin
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.Portrait

    property date now
    property var radarImages
    property int numRadarImages


    function refresh() {
        var tmp = new Date()
        if((numRadarImages == 0) || (tmp.getTime() > (now.getTime()+60*1000)))
        {
            now = tmp
        }

    }

    onNowChanged: {
        // TODO: reset stuff if day changed

        var xhr = new XMLHttpRequest;
        xhr.onreadystatechange = (function(myxhr) {
            return function() {
                if(myxhr.readyState === 4)
                {
                    radarImages = JSON.parse(myxhr.responseText).files
                }
            }
        })(xhr);
        xhr.open('GET', "https://opendata-download-radar.smhi.se/api/version/latest/area/sweden/product/comp/"
                        +now.getUTCFullYear()+"/"+(now.getUTCMonth()+1)+"/"+now.getUTCDate()+"?format=png", true);
        xhr.send('');
    }

    onRadarImagesChanged: {
        numRadarImages = radarImages.length
    }


}
