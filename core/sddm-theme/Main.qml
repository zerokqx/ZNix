import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Page {
    id: screen

    readonly property color backgroundColor: config.stringValue("background")
    readonly property color surfaceColor: config.stringValue("surface")
    readonly property color accentColor: config.stringValue("accent")
    readonly property color secondaryColor: config.stringValue("secondary")
    readonly property real surfaceOpacity: Number(config.stringValue("surfaceOpacity"))
    readonly property real textSize: Number(config.stringValue("fontSize"))
    readonly property string family: config.stringValue("fontFamily")
    property date time: new Date()
    property bool signingIn: false
    property string loginError: ""

    function signIn() {
        const name = account.editText.trim();
        if (signingIn || !name || session.currentIndex < 0)
            return;
        signingIn = true;
        loginError = "";
        sddm.login(name, password.text, session.currentIndex);
        password.clear();
    }

    padding: 0
    font.family: family
    font.pointSize: textSize
    background: Rectangle {
        color: screen.backgroundColor
    }
    palette.window: surfaceColor
    palette.base: config.stringValue("field")
    palette.text: config.stringValue("foreground")
    palette.placeholderText: palette.text
    palette.windowText: palette.text
    palette.button: palette.base
    palette.buttonText: palette.text
    palette.highlight: accentColor
    palette.highlightedText: backgroundColor

    component FieldFrame: Rectangle {
        required property bool focused
        color: screen.palette.base
        radius: 10
        border.color: focused ? screen.accentColor : config.stringValue("border")
    }

    component MenuArrow: Label {
        text: "⌄"
        color: screen.palette.text
        font.pointSize: screen.textSize + 2
    }

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: screen.time = new Date()
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            screen.signingIn = false;
            screen.loginError = qsTr("Не удалось войти. Проверьте данные и попробуйте ещё раз.");
            password.forceActiveFocus();
        }
    }

    Image {
        anchors.fill: parent
        source: config.stringValue("wallpaper")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0
                color: Qt.rgba(screen.backgroundColor.r, screen.backgroundColor.g, screen.backgroundColor.b, 0.94)
            }
            GradientStop {
                position: 1
                color: Qt.rgba(screen.surfaceColor.r, screen.surfaceColor.g, screen.surfaceColor.b, 0.75)
            }
        }
    }

    GridLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 1080)
        columns: width >= 850 ? 2 : 1
        columnSpacing: 80
        rowSpacing: 24

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: Qt.formatTime(screen.time, "HH:mm")
                font.family: screen.family
                font.pixelSize: Math.min(116, screen.height * 0.135)
                font.weight: Font.DemiBold
                color: screen.palette.text
            }
            Label {
                text: screen.time.toLocaleDateString(Qt.locale("ru_RU"), "dddd, d MMMM")
                font.family: screen.family
                font.pointSize: screen.textSize + 4
                color: screen.secondaryColor
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredWidth: 400
            Layout.maximumWidth: 480
            implicitHeight: form.implicitHeight + 48
            radius: 24
            color: Qt.rgba(screen.surfaceColor.r, screen.surfaceColor.g, screen.surfaceColor.b, screen.surfaceOpacity)
            border.color: config.stringValue("border")

            ColumnLayout {
                id: form
                anchors.fill: parent
                anchors.margins: 24
                spacing: 12

                RowLayout {
                    spacing: 16
                    Rectangle {
                        Layout.preferredWidth: 52
                        Layout.preferredHeight: 52
                        radius: 14
                        color: screen.palette.base
                        Image {
                            id: avatar
                            anchors.fill: parent
                            anchors.margins: 5
                            source: account.editText === account.currentText ? (account.currentValue ?? "") : ""
                            fillMode: Image.PreserveAspectFit
                        }
                        Label {
                            anchors.centerIn: parent
                            visible: avatar.status !== Image.Ready
                            text: account.editText.trim().slice(0, 1).toUpperCase()
                            color: screen.accentColor
                            font.pointSize: screen.textSize + 6
                            font.weight: Font.DemiBold
                        }
                    }
                    Label {
                        text: qsTr("Вход в систему")
                        font.pointSize: screen.textSize + 7
                        font.weight: Font.DemiBold
                    }
                }

                ComboBox {
                    id: account
                    Layout.fillWidth: true
                    implicitHeight: 42
                    editable: true
                    flat: true
                    model: userModel
                    textRole: "name"
                    valueRole: "icon"
                    currentIndex: userModel.lastIndex
                    Accessible.name: qsTr("Пользователь")
                    background: FieldFrame { focused: account.activeFocus }
                    indicator: MenuArrow {
                        x: account.width - width - 14
                        y: (account.height - height) / 2
                    }
                }

                TextField {
                    id: password
                    Layout.fillWidth: true
                    implicitHeight: 42
                    placeholderText: qsTr("Пароль")
                    Accessible.name: placeholderText
                    echoMode: TextInput.Password
                    inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                    focus: true
                    background: FieldFrame { focused: password.activeFocus }
                    onAccepted: screen.signIn()
                }

                ComboBox {
                    id: session
                    Layout.fillWidth: true
                    implicitHeight: 42
                    model: sessionModel
                    textRole: "name"
                    currentIndex: sessionModel.lastIndex
                    displayText: currentIndex >= 0 ? currentText : qsTr("Сеанс недоступен")
                    Accessible.name: qsTr("Сеанс")
                    background: FieldFrame { focused: session.activeFocus }
                    indicator: MenuArrow {
                        x: session.width - width - 14
                        y: (session.height - height) / 2
                    }
                }

                Button {
                    id: submit
                    Layout.fillWidth: true
                    implicitHeight: 42
                    text: screen.signingIn ? qsTr("Вход…") : qsTr("Войти")
                    enabled: !screen.signingIn && account.editText.trim().length > 0 && session.currentIndex >= 0
                    background: Rectangle {
                        radius: 10
                        color: !submit.enabled ? screen.palette.base
                              : submit.down ? Qt.darker(screen.accentColor, 1.14) : screen.accentColor
                        border.color: submit.activeFocus ? screen.palette.text : color
                    }
                    contentItem: Label {
                        text: submit.text
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.weight: Font.DemiBold
                        color: submit.enabled ? screen.backgroundColor : screen.palette.text
                    }
                    onClicked: screen.signIn()
                }

                Label {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: screen.loginError
                    wrapMode: Text.Wrap
                    color: config.stringValue("error")
                    Accessible.role: Accessible.AlertMessage
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    Button {
                        text: qsTr("Перезагрузить")
                        flat: true
                        visible: sddm.canReboot
                        onClicked: sddm.reboot()
                    }
                    Button {
                        text: qsTr("Выключить")
                        flat: true
                        visible: sddm.canPowerOff
                        onClicked: sddm.powerOff()
                    }
                }
            }
        }
    }
}
