// automata login screen: big clock, one password line, that's it.
// Plain QtQuick only, so it doesn't depend on SddmComponents or QtQuick.Controls.
import QtQuick

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.stringValue("bg") || "#0d0611"

    readonly property color accent:     config.stringValue("accent")     || "#64D4F0"
    readonly property color accent2:    config.stringValue("accent2")    || "#9D6A97"
    readonly property color textColor: config.stringValue("text")      || "#c9d4e1"
    readonly property color textDim: config.stringValue("textDim") || "#8c949d"
    readonly property color colorError: config.stringValue("error")      || "#e06c75"
    readonly property string fontUi:    config.stringValue("font")     || "@@FONT_UI@@"
    readonly property string fontMono: "@@FONT_MONO@@"

    property int userIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property bool busy: false

    // invisible repeaters, just so names can be read by index
    Repeater {
        id: users
        model: userModel
        delegate: Item {
            visible: false
            property string user: model.name
            property string displayName: model.realName !== "" ? model.realName : model.name
        }
    }
    Repeater {
        id: sessions
        model: sessionModel
        delegate: Item { visible: false; property string displayName: model.name }
    }
    readonly property var currentUser: users.count > 0 ? users.itemAt(userIndex) : null
    readonly property var currentSession: sessions.count > 0 ? sessions.itemAt(sessionIndex) : null

    function switchUser(step) {
        if (busy || users.count < 2) return
        userIndex = (userIndex + step + users.count) % users.count
        password.text = ""
        message.text = ""
        password.forceActiveFocus()
    }

    function logIn() {
        if (busy || !currentUser) return
        busy = true
        message.text = ""
        sddm.login(currentUser.user, password.text, root.sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.busy = false
            password.text = ""
            message.text = "@@t:wrong_password@@"
            shake.start()
            password.forceActiveFocus()
        }
        function onLoginSucceeded() { message.text = "" }
    }

    // ---------- background ----------
    Image {
        anchors.fill: parent
        source: config.stringValue("image")
        fillMode: Image.PreserveAspectCrop
        visible: source != ""
    }

    // soft glows + faint grid
    Canvas {
        anchors.fill: parent
        visible: config.stringValue("image") === ""
        function glow(ctx, cx, cy, r, c) {
            var g = ctx.createRadialGradient(cx, cy, 0, cx, cy, r)
            g.addColorStop(0, c)
            g.addColorStop(1, "transparent")
            ctx.fillStyle = g
            ctx.fillRect(0, 0, width, height)
        }
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            // glows in the wallpaper accents
            glow(ctx, width * 0.12, height * 1.05, width * 0.55, Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.20))
            glow(ctx, width * 0.92, height * -0.1, width * 0.40, Qt.rgba(root.accent2.r, root.accent2.g, root.accent2.b, 0.12))
            ctx.strokeStyle = Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.05)
            ctx.lineWidth = 1
            var step = 64
            for (var x = 0.5; x < width; x += step) { ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke() }
            for (var y = 0.5; y < height; y += step) { ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke() }
        }
    }

    // corner brackets
    Repeater {
        model: 4
        Item {
            readonly property bool isRight: index % 2 === 1
            readonly property bool isBottom: index >= 2
            width: 28; height: 28
            x: isRight ? root.width - 48 - width : 48
            y: isBottom ? root.height - 48 - height : 48
            Rectangle { width: 28; height: 2; color: root.accent; opacity: 0.5; y: isBottom ? 26 : 0 }
            Rectangle { width: 2; height: 28; color: root.accent; opacity: 0.5; x: isRight ? 26 : 0 }
        }
    }

    // ---------- top: logo + machine name ----------
    // the A from automata's logo, drawn here so it takes the accent color like everything else
    Canvas {
        id: logo
        x: 92; y: 56
        width: 24; height: 24
        property color tint: root.accent
        onTintChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.scale(width / 76, height / 76)
            ctx.translate(-26, -26)
            ctx.lineCap = "square"
            ctx.strokeStyle = tint
            ctx.lineWidth = 9
            ctx.beginPath(); ctx.moveTo(38, 96); ctx.lineTo(64, 32); ctx.lineTo(90, 96); ctx.stroke()
            ctx.globalAlpha = 0.6
            ctx.lineWidth = 7
            ctx.beginPath(); ctx.moveTo(50, 76); ctx.lineTo(78, 76); ctx.stroke()
        }
    }
    Text {
        x: 132; y: 62
        text: (sddm.hostName || "automata").toUpperCase()
        color: root.textDim
        font.family: root.fontMono
        font.pixelSize: 13
        font.letterSpacing: 4
    }

    // ---------- center ----------
    Column {
        id: centerBox
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -40
        spacing: 0

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.textColor
            font.family: root.fontUi
            font.weight: Font.Medium
            font.pixelSize: 150
            font.letterSpacing: -2
        }
        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.accent
            font.family: root.fontMono
            font.pixelSize: 15
            font.letterSpacing: 6
        }

        Item { width: 1; height: 72 }

        // user: the arrows (or ↑ ↓ in the password field) only show up when there's more than one
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 22
            HudButton {
                text: "‹"; font.pixelSize: 21
                visible: users.count > 1
                onActivated: root.switchUser(-1)
            }
            Text {
                text: root.currentUser ? root.currentUser.displayName : ""
                color: root.textColor
                font.family: root.fontUi
                font.weight: Font.Medium
                font.pixelSize: 21
                font.letterSpacing: 1
            }
            HudButton {
                text: "›"; font.pixelSize: 21
                visible: users.count > 1
                onActivated: root.switchUser(1)
            }
        }

        Item { width: 1; height: 22 }

        // password field, just a line
        Item {
            id: field
            width: 340; height: 44
            anchors.horizontalCenter: parent.horizontalCenter

            TextInput {
                id: password
                anchors.fill: parent
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                passwordCharacter: "•"
                color: root.textColor
                selectionColor: root.accent2
                font.family: root.fontMono
                font.pixelSize: 20
                font.letterSpacing: 6
                focus: true
                enabled: !root.busy
                clip: true
                Keys.onReturnPressed: root.logIn()
                Keys.onEnterPressed: root.logIn()
                Keys.onEscapePressed: text = ""
                Keys.onUpPressed: root.switchUser(-1)
                Keys.onDownPressed: root.switchUser(1)
            }
            Text {
                anchors.centerIn: parent
                text: root.busy ? "@@t:logging_in@@" : "@@t:password@@"
                color: root.textDim
                font.family: root.fontMono
                font.pixelSize: 14
                font.letterSpacing: 3
                visible: password.text.length === 0
            }
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: root.textDim; opacity: 0.4
            }
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                height: 2
                width: password.activeFocus ? parent.width : 0
                color: message.text !== "" ? root.colorError : root.accent
                Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
            }
            SequentialAnimation {
                id: shake
                property real base: 0
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -12; duration: 50 }
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 12;  duration: 70 }
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -6;  duration: 60 }
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 0;   duration: 50 }
            }
        }

        Item { width: 1; height: 16 }

        Text {
            id: message
            anchors.horizontalCenter: parent.horizontalCenter
            height: 18
            color: root.colorError
            font.family: root.fontMono
            font.pixelSize: 13
            font.letterSpacing: 2
            text: ""
        }
    }

    // ---------- bottom: session, keyboard, power ----------
    component HudButton: Text {
        id: btn
        signal activated()
        color: area.containsMouse ? root.accent : root.textDim
        font.family: root.fontMono
        font.pixelSize: 13
        font.letterSpacing: 3
        Behavior on color { ColorAnimation { duration: 150 } }
        MouseArea {
            id: area
            anchors.fill: parent
            anchors.margins: -8
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.activated()
        }
    }

    Row {
        x: 92
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 66
        spacing: 36
        HudButton {
            // click cycles through installed sessions
            text: "◆ " + (root.currentSession ? root.currentSession.displayName : "").toUpperCase()
            onActivated: root.sessionIndex = (root.sessionIndex + 1) % Math.max(1, sessions.count)
        }
        Text {
            visible: keyboard.layouts.length > 0
            text: keyboard.layouts.length > 0 ? keyboard.layouts[keyboard.currentLayout].shortName.toUpperCase() : ""
            color: root.textDim
            font.family: root.fontMono
            font.pixelSize: 13
            font.letterSpacing: 3
        }
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 92
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 66
        spacing: 36
        HudButton { text: "@@t:suspend@@".toUpperCase(); visible: sddm.canSuspend; onActivated: sddm.suspend() }
        HudButton { text: "@@t:reboot@@".toUpperCase(); visible: sddm.canReboot;  onActivated: sddm.reboot() }
        HudButton { text: "@@t:poweroff@@".toUpperCase(); visible: sddm.canPowerOff; onActivated: sddm.powerOff() }
    }

    // ---------- clock ----------
    function updateClock() {
        var now = new Date()
        clockText.text = Qt.formatTime(now, "HH:mm")
        dateText.text = now.toLocaleDateString(Qt.locale("@@t:locale@@".split(".")[0]), "dddd  dd · MM · yyyy").toUpperCase()
    }
    Timer { interval: 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.updateClock() }

    // fade in
    opacity: 0
    NumberAnimation on opacity { to: 1; duration: 600; easing.type: Easing.OutCubic }

    Component.onCompleted: password.forceActiveFocus()
}
