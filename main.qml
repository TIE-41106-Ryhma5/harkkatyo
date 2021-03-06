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

    // Värimäärittelyt
    property string virhevari : "#cb003a"
    property string paavari : "#0098ad"
    property string oikeinvari : "#0c6a27"
    property string tekstivari : "#676767"
    property string alttekstivari : "#ffffff"
    property string taustavari : "#ffffff"
    property string nappulavari : "#ececec"
    property string nappulaaktvari : "#aaaaaa"
    property string sjalkiakttaustavari : "#676767"

    // Fonttimäärittelyt
    property int fonttikoko_teksti : 58
    property int fonttikoko_pieni_teksti  : 25
    property int fonttikoko_otsikko : 90
    property int fonttikoko_nappain : 85

    // Aikamäärittelyt
    property int palautumisaika : 300
    property int lukemisaika : 1500
    property int aukioloaika : 2500
    property int haivytysaika : 130
    property int ilmoitusaika : 2000
    property int pinsyottoaika : 12000
    property int varinaaika : 50
    property int animaatioaika

    // Sormenjäljen lukuun liittyvät muuttujat
    property int sormiToleranssi: 20 // Toleranssi, jonka verran sormi saa liikkua ennen virheilmoitusta
    property real sormiX
    property real sormiY
    property bool epaonnistunut // Jos sormenjäljen lukeminen epäonnistuu

    // Pin-koodin muuttujat
    property string oikeaPIN : "1234"
    property string eiPaasyaPIN : "4321"
    property string pin
    property int pinPituus
    property string piiloPIN
    property bool pinVirhe

    // Kielimuuttujat
    property bool englanniksi : false
    property string string_oviLukossa : englanniksi? qsTr("THE DOOR IS LOCKED") : qsTr("OVI ON LUKOSSA");
    property string string_asetaOpKortti : englanniksi? qsTr("PLACE YOUR ID IN FRONT OF THE SCREEN") : qsTr("ASETA KULKUKORTTI NÄYTÖN ETEEN");
    property string string_lueSormJalki : englanniksi? qsTr("OR SCAN YOUR FINGERPRINT") : qsTr("TAI LUE SORMENJÄLKESI");
    property string string_syotaPin : englanniksi? qsTr("ENTER YOUR PIN") : qsTr("SYÖTÄ PIN-KOODISI");
    property string string_sormenjaljenLuku : englanniksi? qsTr("SCANNING THE FINGERPRINT...") : qsTr("SORMENJÄLKEÄ LUETAAN..");
    property string string_oviAuki : englanniksi? qsTr("THE DOOR IS OPEN") : qsTr("OVI ON AUKI");
    property string string_pinVirhe : englanniksi? qsTr("INVALID PIN") : qsTr("VIRHEELLINEN PIN");
    property string string_kielivalinta : englanniksi? qsTr("SUOMEKSI") : qsTr("IN ENGLISH");
    property string string_eiOikeuksia : englanniksi? qsTr("NO PERMISSION") :  qsTr("EI PÄÄSYOIKEUTTA")
    property string string_sormiVirhe : englanniksi? qsTr("FINGERPRINT NOT RECOGNIZED") : qsTr("SORMENJÄLKEÄ EI TUNNISTETTU")
    property string string_lipunUrl : englanniksi? "images/FILippu.png" : "images/UKLippu.png";

    // Asettelu
    property int ylapohja_aloituskorkeus : 500

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
                timer_pinsyottoajastin.restart()
            }
        }
    }

    Timer {
        id: timer_pinsyottoajastin
        interval: pinsyottoaika

        onTriggered:{
            grid1.visible = false

            rectangle_ylapohja.opacity = 1.0
            rectangle_ylapohja.height = ylapohja_aloituskorkeus
            label_oviLukossa.opacity = 1.0

            label_syotaPIN.opacity = 0.0
            image_opKortti.opacity = 1.0
            label_asetaOpKortti.opacity = 1.0
            label_asetaOpKortti.text = string_asetaOpKortti

            label_piilotettuPIN.opacity = 0.0
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
            label_asetaOpKortti.text = string_asetaOpKortti
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
        z: 2
        fillMode: Image.Tile
        source: "images/Raidat.png"
    }

    Rectangle {
        id: rectangle_erottaja
        x: 50
        y: 1292
        width: 1030
        height: 20
        color: paavari
    }

    Rectangle {
        id: rectangle_ylapohja
        x: 49
        y: 193
        width: 1032
        height: ylapohja_aloituskorkeus
        color: paavari

        Label {
            id: label_oviLukossa
            x: 176
            y: 183
            color: alttekstivari
            text: string_oviLukossa
            font.pixelSize: fonttikoko_teksti
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            Behavior on opacity {
                NumberAnimation { duration : haivytysaika }
            }
        }

    }

    Item {
        id: idkorttiosio
        x: 52
        y: 692
        width: 1028
        height: 614

        Label {
            id: label_asetaOpKortti
            x: 88
            y: 66
            width: 800
            color: tekstivari
            text: string_asetaOpKortti
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: fonttikoko_teksti
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap

            Behavior on opacity {
                NumberAnimation { duration : haivytysaika }
            }
        }

        Image {
            id: image_opKortti
            x: 360
            y: 269
            width: 255
            height: 200
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.Tile
            source: "images/OpKortti.png"
            opacity: 1.0

            Behavior on opacity {
                NumberAnimation { duration: haivytysaika }
            }

        }
    }

    Label {
        id: label_syotaPIN
        x: 271
        y: 230
        color: tekstivari
        text: string_syotaPin
        opacity: 0
        font.pixelSize: fonttikoko_teksti
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
            text: string_pinVirhe
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: fonttikoko_teksti
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

        }

        Behavior on opacity {
            NumberAnimation { duration : haivytysaika }
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
                    color: button_nro7.pressed? nappulaaktvari : nappulavari

                    Behavior on color {
                        ColorAnimation { duration: haivytysaika }
                    }
                }


                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: fonttikoko_nappain
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                timer_pinsyottoajastin.restart()
                pin += "7"
                paivitaPIN()

            }

            onPressedChanged: {
                if (this.pressed === true){
                    Vibrator.vibrate(varinaaika)
                }
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

                    color: button_nro8.pressed? nappulaaktvari : nappulavari;

                    Behavior on color {
                        ColorAnimation { duration: haivytysaika }
                    }
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: fonttikoko_nappain
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                timer_pinsyottoajastin.restart()
                pin += "8"
                paivitaPIN()
            }

            onPressedChanged: {
                if (this.pressed === true){
                    Vibrator.vibrate(varinaaika)
                }
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

                    color: button_nro9.pressed? nappulaaktvari : nappulavari;

                    Behavior on color {
                        ColorAnimation { duration: haivytysaika }
                    }
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: fonttikoko_nappain
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                timer_pinsyottoajastin.restart()
                pin += "9"
                paivitaPIN()
            }

            onPressedChanged: {
                if (this.pressed === true){
                    Vibrator.vibrate(varinaaika)
                }
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

                    color: button_nro4.pressed? nappulaaktvari : nappulavari;

                    Behavior on color {
                        ColorAnimation { duration: haivytysaika }
                    }
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: fonttikoko_nappain
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                timer_pinsyottoajastin.restart()
                pin += "4"
                paivitaPIN()
            }

            onPressedChanged: {
                if (this.pressed === true){
                    Vibrator.vibrate(varinaaika)
                }
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

                    color: button_nro5.pressed? nappulaaktvari : nappulavari;

                    Behavior on color {
                        ColorAnimation { duration: haivytysaika }
                    }
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: fonttikoko_nappain
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                pin += "5"
                timer_pinsyottoajastin.restart()
                paivitaPIN()
            }

            onPressedChanged: {
                if (this.pressed === true){
                    Vibrator.vibrate(varinaaika)
                }
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

                    color: button_nro6.pressed? nappulaaktvari : nappulavari;

                    Behavior on color {
                        ColorAnimation { duration: haivytysaika }
                    }
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: fonttikoko_nappain
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                timer_pinsyottoajastin.restart()
                pin += "6"
                paivitaPIN()
            }
            onPressedChanged: {
                if (this.pressed === true){
                    Vibrator.vibrate(varinaaika)
                }
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

                    color: button_nro1.pressed? nappulaaktvari : nappulavari;

                    Behavior on color {
                        ColorAnimation { duration: haivytysaika }
                    }
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: fonttikoko_nappain
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                timer_pinsyottoajastin.restart()
                pin += "1"
                paivitaPIN()
            }

            onPressedChanged: {
                if (this.pressed === true){
                    Vibrator.vibrate(varinaaika)
                }
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

                    color: button_nro2.pressed? nappulaaktvari : nappulavari;
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: fonttikoko_nappain
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                timer_pinsyottoajastin.restart()
                pin += "2"
                paivitaPIN()
            }

            onPressedChanged: {
                if (this.pressed === true){
                    Vibrator.vibrate(varinaaika)
                }
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

                    color: button_nro3.pressed? nappulaaktvari : nappulavari;
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: fonttikoko_nappain
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                timer_pinsyottoajastin.restart()
                pin += "3"
                paivitaPIN()
            }

            onPressedChanged: {
                if (this.pressed === true){
                    Vibrator.vibrate(varinaaika)
                }
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

                    color: button_backspace.pressed? nappulaaktvari : nappulavari;

                    Behavior on color {
                        ColorAnimation { duration: haivytysaika }
                    }
                }

                label: Image {
                    width: 120
                    height: 90
                    anchors.horizontalCenterOffset: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.Pad
                    source: "images/backspace.png"


                }
            }

            onClicked: {
                soitaNappainaani()
                timer_pinsyottoajastin.restart()
                pin = pin.substring( 0, pin.length-1 );
                paivitaPIN()
            }

            onPressedChanged: {
                if (this.pressed === true){
                    Vibrator.vibrate(varinaaika)
                }
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

                    color: button_nro0.pressed? nappulaaktvari : nappulavari;

                    Behavior on color {
                        ColorAnimation { duration: haivytysaika }
                    }
                }

                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: fonttikoko_nappain
                    color: tekstivari
                    text: control.text
                }
            }

            onClicked: {
                soitaNappainaani()
                timer_pinsyottoajastin.restart()
                pin += "0"
                paivitaPIN()
            }

            onPressedChanged: {
                if (this.pressed === true){
                    Vibrator.vibrate(varinaaika)
                }
            }
        }
    }

    function asetaAloitustilaan() {
        rectangle_clicked.opacity = 0.0
        rectangle_clicked.color = sjalkiakttaustavari
        animaatioaika = (palautumisaika/1028) * rectangle_load.width
        rectangle_load.width = 0

        sormenjalkiajastin.stop()
        sormenjalkiajastin.interval = lukemisaika

        label_lueSormJalki.color = tekstivari
        label_lueSormJalki.text = string_lueSormJalki

        image_sormenjalki.opacity = 1.0
        image_sormenjalki_vaalea.opacity = 0.0
    }

    Rectangle {
        id: rectangle_oviAuki
        x: 0
        y: 190
        width: 1080
        height: 1800
        color: oikeinvari
        z: 3

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
            text: string_oviAuki
            font.pixelSize: fonttikoko_otsikko
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
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
        font.pixelSize: fonttikoko_otsikko
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on opacity {
            NumberAnimation { duration : haivytysaika }
        }

        Behavior on color {
            ColorAnimation { duration : haivytysaika }
        }
    }

    Item {
        id: ylapalkki
        x: 0
        y: 0
        width: 1080
        height: 193

        Image {
            id: rectangle_tty
            x: 48
            y: 47
            width: 597
            height: 100
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.Tile
            source: "images/TTY.png"
        }

        MouseArea {
            id: mouseArea_kielivalinta
            x: 880
            y: 47
            width: 170
            height: 130
            anchors.verticalCenter: parent.verticalCenter
            z: 3

            onClicked:{
                soitaNappainaani()
                if (englanniksi === false){
                    englanniksi = true;
                } else {
                    englanniksi = false;
                }

                label_asetaOpKortti.text = string_asetaOpKortti
                label_PinVirhe.text = string_pinVirhe
                label_oviAuki.text = string_oviAuki
                label_oviLukossa.text = string_oviLukossa
                label_syotaPIN.text = string_syotaPin
                label_lueSormJalki.text = string_lueSormJalki
            }

            onPressed: {
                Vibrator.vibrate(varinaaika)
            }

            Image {
                id: image_lippu
                x: 0
                y: 0
                width: 120
                height: 100
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: string_lipunUrl
            }

            Text {
                id: text_kielivalinta
                x: 0
                y: 100
                text: string_kielivalinta
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: fonttikoko_pieni_teksti
                color: tekstivari
            }
        }
    }

    Item {
        id: sormenjalkiosio
        x: 52
        y: 1306
        width: 1028
        height: 614

        Rectangle {
            id: rectangle_clicked
            color: sjalkiakttaustavari
            opacity: 0.0
            visible: true
            z: -1

            Behavior on opacity {
                NumberAnimation{ duration: haivytysaika }
            }

            Behavior on color {
                ColorAnimation { duration: haivytysaika }
            }
            anchors.fill: parent
        }

        MouseArea {
            id: mouseArea1
            x: 338
            y: 161
            z: 2
            width: 300
            height: 400
            anchors.verticalCenterOffset : 40
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter

            onPressed:{
                Vibrator.vibrate(varinaaika)

                rectangle_clicked.opacity = 1.0
                rectangle_clicked.color = sjalkiakttaustavari

                animaatioaika = lukemisaika
                rectangle_load.width = 1028
                rectangle_load.opacity = 1.0

                sormenjalkiajastin.start()

                label_lueSormJalki.color = alttekstivari
                label_lueSormJalki.text = string_sormenjaljenLuku

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
                    if (!epaonnistunut){
                        soitaEpaOnnistunut()
                    }

                    rectangle_clicked.opacity = 1.0
                    rectangle_clicked.color = virhevari
                    animaatioaika = (palautumisaika/1028) * rectangle_load.width
                    rectangle_load.width = 0
                    rectangle_load.opacity = 0.0

                    sormenjalkiajastin.stop()
                    sormenjalkiajastin.interval = lukemisaika

                    label_lueSormJalki.text = string_sormiVirhe

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

            Image {
                id: image_sormenjalki_vaalea
                x: 17
                y: 27
                z: 1
                width: 265
                height: 345
                anchors.verticalCenter: parent.verticalCenter
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
                id: image_sormenjalki
                x: -9
                y: 27
                z: 1
                width: 265
                height: 345
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenterOffset: 0
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.Tile
                source: "images/Sormenjalki.png"

                opacity: 1

                Behavior on opacity {
                    NumberAnimation { duration: haivytysaika }
                }
            }
        }

        Label {
            id: label_lueSormJalki
            x: 88
            y: 40
            z:1
            width: 800
            color: tekstivari
            text: string_lueSormJalki
            anchors.horizontalCenterOffset: 0
            verticalAlignment: Text.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: fonttikoko_teksti
            wrapMode: Text.WordWrap

            Behavior on color {
                ColorAnimation { duration: haivytysaika }
            }
        }

        Rectangle {
            id: rectangle_load
            x: 0
            y: 0
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
        Vibrator.vibrate(varinaaika)

        rectangle_oviAuki.visible = true
        rectangle_oviAuki.opacity = 1.0
        aukioloajastin.start()

        label_oviLukossa.opacity = 1.0
        rectangle_ylapohja.height = ylapohja_aloituskorkeus

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
            soitaOnnistunut()
        } else if (pin === eiPaasyaPIN){
            pin = "";
            label_PinVirhe.text = string_eiOikeuksia
            naytaPINVirhe(false)

        }else {
            pin = "";
            naytaPINVirhe(true)
        }
    }

    function naytaPINVirhe(resettaaTeksti){
        if (resettaaTeksti){
            label_PinVirhe.text = string_pinVirhe
            label_piilotettuPIN.color = virhevari
        }

        rectangle_pinVirhe.visible = true;
        rectangle_pinVirhe.opacity = 1.0;

        timer_epaonnistumisajastinPIN.start()
        pinVirhe = true;

        soitaEpaOnnistunut()
    }

}

