import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import QtSensors 5.0
import QtMultimedia 5.5

ApplicationWindow {
    id: applicationWindow1
    visible: true
    width: 1080
    height: 1920
    title: qsTr("Avaax Ovijarjestelma")

    property string virhevari : "#cb003a"
    property string paavari : "#0098ad"
    property string oikeinvari : "#0c6a27"
    property string tekstivari : "#676767"
    property string alttekstivari : "#ffffff"
    property string taustavari : "#ffffff"
    property string nappulavari : "#ececec"
    property string nappulaaktvari : "#676767"

    property int palautumisaika : 300
    property int lukemisaika : 1500
    property int aukioloaika: 2500
    property int haivytysaika: 130
    property int ilmoitusaika: 2000
    property int animaatioaika

    property int sormiToleranssi: 10 // Toleranssi, jonka verran sormi saa liikkua ennen virheilmoitusta
    property real sormiX
    property real sormiY
    property bool epaonnistunut // Jos sormenjäljen lukeminen epäonnistuu

    property string oikeaPIN : "1234"
    property string eiPaasyaPIN : "4321"
    property string pin
    property int pinPituus
    property string piiloPIN
    property bool pinVirhe


    Audio {
        id: sound_painallus
        source: "sounds/klikkaus2.mp3"

        autoLoad: true
        autoPlay: false
        volume: 1.0
    }

    Audio {
        id: sound_onnistunut
        source: "sounds/merkkiaani1.mp3"

        autoLoad: true
        autoPlay: false
        volume: 1.0
    }

    Audio {
        id: sound_epaonnistunut
        source: "sounds/merkkiaani2.mp3"

        autoLoad: true
        autoPlay: false
        volume: 1.0
    }


    ProximitySensor{
        id: proxSensor
        active: true

        onReadingChanged: {
            if (proxSensor.reading.near === true){
                naytaNappaimisto()
                soitaOnnistunut()
            }
        }
    }

    Timer {
        id: timer_epaonnistumisajastinPIN
        interval: ilmoitusaika

        onTriggered:{
            rectangle_pinVirhe.opacity = 0.0;
            label_piilotettuPIN.color = tekstivari;
        }
    }

    Timer {
        id: epaonnistumisajastin
        interval: ilmoitusaika

        onTriggered: {
            epaonnistunut = false
            asetaAloitustilaan()
        }

    }

    Timer {
        id: odotusaika
        interval: haivytysaika

        onTriggered: {
            rectangle_oviAuki.visible = false;
        }

    }

    Timer {
        id: aukioloajastin
        interval: aukioloaika

        onTriggered: {
            rectangle_oviAuki.opacity = 0.0
            grid1.visible = false
            odotusaika.start()

            label_syotaPIN.opacity = 0.0
            image_opKortti.opacity = 1.0
            label_asetaOpKortti.opacity = 1.0
        }
    }

    Timer {
        id: sormenjalkiajastin
        interval: lukemisaika

        onTriggered: {
            oviAukeaa()
        }
    }

    Image {
        id: rectangle_raidat
        x: 0
        y: 168
        width: 52
        height: 1752
        fillMode: Image.Tile
        source: "images/Raidat.png"
    }

    Image {
        id: rectangle_tty
        x: 48
        y: 47
        width: 597
        height: 100
        fillMode: Image.Tile
        source: "images/TTY.png"
    }

    Rectangle {
        id: rectangle_erottaja
        x: 50
        y: 1280
        width: 1030
        height: 20
        color: paavari
    }

    Rectangle {
        id: rectangle_ylapohja
        x: 49
        y: 193
        width: 1032
        height: 499
        color: paavari

        Label {
            id: label_oviLukossa
            x: 176
            y: 183
            color: alttekstivari
            text: qsTr("OVI ON LUKOSSA")
            font.pixelSize: 58
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            Behavior on opacity {
                NumberAnimation { duration : haivytysaika }
            }
        }

        Behavior on height {
            NumberAnimation {duration : haivytysaika }
        }
    }

    Label {
        id: label_syotaPIN
        x: 271
        y: 230
        color: tekstivari
        text: qsTr("SYÖTÄ PIN-KOODISI")
        opacity: 0
        font.pixelSize: 58
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter

        Behavior on opacity {
            NumberAnimation { duration : haivytysaika }
        }
    }


    Rectangle {
        id: rectangle_pinVirhe
        y: 200
        color : virhevari
        opacity: 0
        visible: false
        anchors.horizontalCenter: parent.horizontalCenter
        height: 100
        width : 700
        z : 1

        Label {
            id: label_PinVirhe
            x: 271
            y: 230
            color: alttekstivari
            text: qsTr("VIRHEELLINEN PIN")
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 58
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

        }

        Behavior on opacity {
            NumberAnimation { duration : haivytysaika }
        }
    }

    Label {
        id: label_asetaOpKortti
        x: 165
        y: 788
        width: 800
        color: tekstivari
        text: qsTr("ASETA OPISKELIJAKORTTI NÄYTÖN ETEEN")
        font.pixelSize: 58
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap

        Behavior on opacity {
            NumberAnimation { duration : haivytysaika }
        }
    }

    Label {
        id: label_lueSormJalki
        x: 165
        y: 1360
        z:1
        width: 800
        color: tekstivari
        text: qsTr("TAI LUE SORMENJÄLKESI")
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 58
        wrapMode: Text.WordWrap

        Behavior on color {
            ColorAnimation { duration: haivytysaika }
        }
    }

    Image {
        id: image_opKortti
        x: 433
        y: 961
        width: 255
        height: 200
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.Tile
        source: "images/OpKortti.png"
        opacity: 1.0

        Behavior on opacity {
            NumberAnimation { duration: haivytysaika }
        }

    }

    Grid {
        id: grid1
        x: 248
        y: 361
        width: 560
        height: 800
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        flow: Grid.LeftToRight
        layoutDirection: Qt.LeftToRight
        rows: 4
        columns: 3
        visible: false
        opacity: 0

        Behavior on opacity{
            NumberAnimation { duration: haivytysaika }
        }


        Button {
            id: button_nro7
            width: 180
            height: 180
            text: qsTr("7")
            isDefault: false
            activeFocusOnPress: false

            style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: 180
                    implicitHeight: 180
                    border.width: 0
                    radius : 2

                    color: nappulavari
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 80
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                pin += "7"
                paivitaPIN()
            }
        }

        Button {
            id: button_nro8
            width: 180
            height: 180
            text: qsTr("8")

            style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: 180
                    implicitHeight: 180
                    border.width: 0
                    radius : 2

                    color: nappulavari
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 80
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                pin += "8"
                paivitaPIN()
            }
        }



        Button {
            id: button_nro9
            width: 180
            height: 180
            text: qsTr("9")
            opacity: 1

            style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: 180
                    implicitHeight: 180
                    border.width: 0
                    radius : 2

                    color: nappulavari
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 80
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                pin += "9"
                paivitaPIN()
            }
        }

        Button {
            id: button_nro4
            width: 180
            height: 180
            text: qsTr("4")
            opacity: 1

            style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: 180
                    implicitHeight: 180
                    border.width: 0
                    radius : 2

                    color: nappulavari
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 80
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                pin += "4"
                paivitaPIN()
            }
        }

        Button {
            id: button_nro5
            width: 180
            height: 180
            text: qsTr("5")
            opacity: 1

            style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: 180
                    implicitHeight: 180
                    border.width: 0
                    radius : 2

                    color: nappulavari
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 80
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                pin += "5"
                paivitaPIN()
            }
        }

        Button {
            id: button_nro6
            width: 180
            height: 180
            text: qsTr("6")
            opacity: 1

            style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: 180
                    implicitHeight: 180
                    border.width: 0
                    radius : 2

                    color: nappulavari
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 80
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                pin += "6"
                paivitaPIN()
            }
        }

        Button {
            id: button_nro1
            width: 180
            height: 180
            text: qsTr("1")
            opacity: 1

            style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: 180
                    implicitHeight: 180
                    border.width: 0
                    radius : 2

                    color: nappulavari
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 80
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                pin += "1"
                paivitaPIN()
            }
        }

        Button {
            id: button_nro2
            width: 180
            height: 180
            text: qsTr("2")
            opacity: 1

            style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: 180
                    implicitHeight: 180
                    border.width: 0
                    radius : 2

                    color: nappulavari
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 80
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                pin += "2"
                paivitaPIN()
            }
        }

        Button {
            id: button_nro3
            width: 180
            height: 180
            text: qsTr("3")
            opacity: 1

            style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: 180
                    implicitHeight: 180
                    border.width: 0
                    radius : 2

                    color: nappulavari
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 80
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                pin += "3"
                paivitaPIN()
            }
        }

        Button {
            id: button_backspace
            width: 180
            height: 180
            opacity: 1
            iconSource: "images/backspace.png"

            style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: 180
                    implicitHeight: 180
                    border.width: 0
                    radius : 2

                    color: nappulavari
                }

                label: Image {
                    width: 120
                    height: 90
                    anchors.horizontalCenterOffset: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.Tile
                    source: "images/backspace.png"


                }
            }

            onClicked: {
                soitaNappainaani()
                pin = pin.substring( 0, pin.length-1 );
                paivitaPIN()
            }
        }

        Button {
            id: button_nro0
            width: 180
            height: 180
            text: qsTr("0")
            opacity: 1

            style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: 180
                    implicitHeight: 180
                    border.width: 0
                    radius : 2

                    color: nappulavari
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 80
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                pin += "0"
                paivitaPIN()
            }
        }
    }

    Image {
        id: image_sormenjalki
        x: 515
        y: 1509
        z: 1
        width: 265
        height: 345
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.Tile
        source: "images/Sormenjalki.png"

        opacity: 1

        Behavior on opacity {
            NumberAnimation { duration: haivytysaika }
        }
    }

    Image {
        id: image_sormenjalki_vaalea
        x: 515
        y: 1509
        z: 1
        width: 265
        height: 345
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.Tile
        source: "images/SormenjalkiVaalea.png"

        opacity: 0

        Behavior on opacity {
            NumberAnimation { duration: haivytysaika }
        }
    }

    Image {
        id: image_UK_lippu
        x: 934
        y: 47
        width: 120
        height: 100
        fillMode: Image.PreserveAspectFit
        source: "images/UKLippu.png"

        Text {
            id: text_in_English
            x: -7
            y: 90
            text: qsTr("IN ENGLISH")
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 25
            color: tekstivari
        }
    }

    MouseArea {
        id: mouseArea1
        x: 390
        y: 1482
        z: 2
        width: 300
        height: 400

        onPressed:{

            rectangle_clicked.opacity = 1.0
            rectangle_clicked.color = nappulaaktvari

            animaatioaika = lukemisaika
            rectangle_load.width = 1028
            rectangle_load.opacity = 1.0

            sormenjalkiajastin.start()

            label_lueSormJalki.color = alttekstivari
            label_lueSormJalki.text = qsTr("SORMENJÄLKEÄ LUETAAN...")

            image_sormenjalki.opacity = 0.0
            image_sormenjalki_vaalea.opacity = 1.0

            sormiX = mouseArea1.mouseX
            sormiY = mouseArea1.mouseY

            epaonnistumisajastin.stop()
            epaonnistunut = false

            label_asetaOpKortti.text = proxSensor.reading
        }

        onPositionChanged: {
            if (    ( sormiX > mouseArea1.mouseX + sormiToleranssi)
                    || ( sormiX < mouseArea1.mouseX - sormiToleranssi)
                    || ( sormiY > mouseArea1.mouseY + sormiToleranssi)
                    || ( sormiY < mouseArea1.mouseY - sormiToleranssi)){
                soitaEpaOnnistunut()

                rectangle_clicked.opacity = 1.0
                rectangle_clicked.color = virhevari
                animaatioaika = (palautumisaika/1028) * rectangle_load.width
                rectangle_load.width = 0
                rectangle_load.opacity = 0.0

                sormenjalkiajastin.stop()
                sormenjalkiajastin.interval = lukemisaika

                label_lueSormJalki.text = qsTr("SORMENJÄLKEÄ EI TUNNISTETTU")

                epaonnistunut = true
            }
        }

        onReleased:{
            if (epaonnistunut === false){
                asetaAloitustilaan()
            } else {
                epaonnistumisajastin.start()
            }

        }
    }

    function asetaAloitustilaan() {
        rectangle_clicked.opacity = 0.0
        rectangle_clicked.color = nappulaaktvari
        animaatioaika = (palautumisaika/1028) * rectangle_load.width
        rectangle_load.width = 0

        sormenjalkiajastin.stop()
        sormenjalkiajastin.interval = lukemisaika

        label_lueSormJalki.color = tekstivari
        label_lueSormJalki.text = qsTr("TAI LUE SORMENJÄLKESI")

        image_sormenjalki.opacity = 1.0
        image_sormenjalki_vaalea.opacity = 0.0
    }

    Rectangle {
        id: rectangle_clicked
        x: 52
        y: 1300
        width: 1028
        height: 620
        color: nappulaaktvari
        opacity: 0.0
        visible: true
        z: -1

        Behavior on opacity {
            NumberAnimation{ duration: haivytysaika }
        }

        Behavior on color {
            ColorAnimation { duration: haivytysaika }
        }
    }

    Rectangle {
        id: rectangle_oviAuki
        x: 0
        y: 190
        width: 1080
        height: 1800
        color: oikeinvari
        z: 2

        visible: false
        opacity: 0.0

        Behavior on opacity {
            NumberAnimation{ duration: haivytysaika }
        }

        Label {
            id: label_oviAuki
            x: 165
            y: 788
            width: 800
            color: alttekstivari
            text: qsTr("OVI ON AUKI")
            font.pixelSize: 70
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }

    Rectangle {
        id: rectangle_load
        x: 52
        y: 1300
        width: 0
        height: 620
        color: paavari

        Behavior on width {
            NumberAnimation { duration: animaatioaika }
        }

        Behavior on opacity {
            NumberAnimation { duration: haivytysaika }
        }
    }

    Rectangle {
        id: rectangle_tausta
        x: 0
        y: 0
        width: 1080
        height: 1920
        color: taustavari
        z: -2
    }

    Label {
        id: label_piilotettuPIN
        x: 553
        y: 1179
        color: tekstivari
        text: qsTr("")
        opacity: 0
        font.bold: true
        anchors.horizontalCenterOffset: 0
        font.pixelSize: 70
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on opacity {
            NumberAnimation { duration : haivytysaika }
        }

        Behavior on color {
            ColorAnimation { duration : haivytysaika }
        }
    }



    function naytaNappaimisto(){
        if (rectangle_oviAuki.visible !== true){
            rectangle_ylapohja.height = 0
            label_oviLukossa.opacity = 0.0

            image_opKortti.opacity = 0.0
            label_asetaOpKortti.opacity = 0.0

            grid1.visible = true
            grid1.opacity = 1.0

            label_syotaPIN.opacity = 1.0
            label_piilotettuPIN.opacity = 1.0

            pin = ""
            paivitaPIN()

            rectangle_pinVirhe.opacity = 0.0;
            label_piilotettuPIN.color = tekstivari;
        }
    }

    function oviAukeaa(){
        soitaOnnistunut()

        rectangle_oviAuki.visible = true
        rectangle_oviAuki.opacity = 1.0
        aukioloajastin.start()

        label_oviLukossa.opacity = 1.0
        rectangle_ylapohja.height = 499

        pin = ""
        label_piilotettuPIN.opacity = 0.0

        rectangle_pinVirhe.opacity = 0.0
        rectangle_pinVirhe.visible = false;
    }

    function soitaOnnistunut(){
        sound_onnistunut.play()
    }

    function soitaEpaOnnistunut(){
        sound_epaonnistunut.play()
    }

    function soitaNappainaani(){
        sound_painallus.play()
    }

    function paivitaPIN(){

        if (pinVirhe){
            timer_epaonnistumisajastinPIN.stop()
            label_piilotettuPIN.color = tekstivari;
            rectangle_pinVirhe.opacity = 0.0;
            pinVirhe = false;
        }


        pinPituus = pin.length;
        console.log(pin.length);

        piiloPIN = "";

        for(var i = 0; i < pinPituus; i++){
            piiloPIN += "*";

        }
        console.log(piiloPIN);

        label_piilotettuPIN.text = qsTr(piiloPIN);

        if (pin.length === 4){
            tarkistaPIN()
        }
    }

    function tarkistaPIN(){
        if (pin === oikeaPIN){
            oviAukeaa()
        } else if (pin === eiPaasyaPIN){
            pin = "";
            label_PinVirhe.text = qsTr("EI PÄÄSYOIKEUTTA")

            naytaPINVirhe(false)
        }else {
            pin = "";
            naytaPINVirhe(true)
        }
    }

    function naytaPINVirhe(resettaaTeksti){
        if (resettaaTeksti){
            label_PinVirhe.text = qsTr("VIRHEELLINEN PIN")
        }

        label_piilotettuPIN.color = virhevari
        rectangle_pinVirhe.visible = true;
        rectangle_pinVirhe.opacity = 1.0;

        timer_epaonnistumisajastinPIN.start()
        pinVirhe = true;
    }

}

