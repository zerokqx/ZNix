pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Window

Page {
    id: screen

    readonly property color backgroundColor: config.stringValue("background")
    readonly property color surfaceColor: config.stringValue("surface")
    readonly property color fieldColor: config.stringValue("field")
    readonly property color borderColor: config.stringValue("border")
    readonly property color foregroundColor: config.stringValue("foreground")
    readonly property color accentColor: config.stringValue("accent")
    readonly property color secondaryAccentColor: config.stringValue("secondaryAccent")
    readonly property real surfaceOpacity: Number(config.stringValue("surfaceOpacity"))
    readonly property string videoPath: config.stringValue("video")
    readonly property string videoPosterPath: config.stringValue("videoPoster")
    readonly property int controlHeight: 44
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
    font.family: config.stringValue("fontFamily")
    font.pointSize: Number(config.stringValue("fontSize"))
    palette.window: surfaceColor
    palette.base: fieldColor
    palette.text: foregroundColor
    palette.placeholderText: foregroundColor
    palette.windowText: foregroundColor
    palette.button: fieldColor
    palette.buttonText: foregroundColor
    palette.mid: borderColor
    palette.highlight: accentColor
    palette.highlightedText: backgroundColor

    component FieldFrame: Rectangle {
        required property bool focused

        radius: height / 2
        color: screen.fieldColor
        border.width: focused ? 2 : 0
        border.color: screen.accentColor
    }

    component Selector: ComboBox {
        id: selector

        implicitHeight: screen.controlHeight
        textRole: "name"
        flat: true
        palette.light: screen.accentColor
        palette.midlight: Qt.darker(screen.accentColor, 1.15)
        popup.font: screen.font
        background: FieldFrame { focused: selector.activeFocus || selector.popup.visible }
        indicator: Label {
            x: selector.width - width - 16
            y: (selector.height - height) / 2
            text: "▾"
            color: screen.foregroundColor
        }
    }

    component PillButton: Button {
        id: button

        property bool primary: false

        implicitHeight: screen.controlHeight
        leftPadding: 16
        rightPadding: 16
        contentItem: Label {
            text: button.text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font.weight: button.primary ? Font.DemiBold : Font.Normal
            color: button.primary && button.enabled ? screen.backgroundColor : screen.foregroundColor
        }
        background: Rectangle {
            readonly property color fillColor: button.primary && button.enabled ? screen.accentColor : screen.surfaceColor

            radius: height / 2
            color: button.down ? Qt.darker(fillColor, 1.15) : button.hovered ? Qt.lighter(fillColor, 1.10) : fillColor
            border.width: button.activeFocus ? 2 : 0
            border.color: button.primary && button.enabled ? screen.foregroundColor : screen.accentColor
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 60000 - screen.time.getTime() % 60000
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

    background: Rectangle {
        color: screen.backgroundColor

        Image {
            anchors.fill: parent
            sourceSize: Qt.size(Math.ceil(width * Screen.devicePixelRatio), Math.ceil(height * Screen.devicePixelRatio))
            source: sourceSize.width > 0 && sourceSize.height > 0
                ? (screen.videoPosterPath || config.stringValue("wallpaper")) : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: status === Image.Ready

            Rectangle {
                anchors.fill: parent
                color: screen.backgroundColor
                opacity: screen.videoPosterPath ? 0 : 0.66
            }
        }

        Loader {
            anchors.fill: parent
            asynchronous: true

            // Keep the static theme usable without the optional multimedia import.
            Component.onCompleted: {
                if (screen.videoPath)
                    setSource("VideoBackground.qml", {mediaSource: "file://" + screen.videoPath});
            }
        }
    }

    Flickable {
        id: viewport

        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: Math.max(height, content.height + 32)
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {}

        ColumnLayout {
            id: content

            x: (viewport.width - width) / 2
            y: (viewport.contentHeight - height) / 2
            width: Math.min(viewport.width - 32, 384)
            spacing: viewport.height < 540 ? 12 : 20

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Label {
                        text: Qt.formatTime(screen.time, "HH")
                        color: screen.accentColor
                        font.pixelSize: Math.min(84, viewport.height * 0.13)
                        font.weight: Font.DemiBold
                    }

                    Label {
                        text: Qt.formatTime(screen.time, "mm")
                        color: screen.secondaryAccentColor
                        font.pixelSize: Math.min(84, viewport.height * 0.13)
                        font.weight: Font.DemiBold
                    }
                }

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: screen.time.toLocaleDateString(Qt.locale("ru_RU"), "dddd • d MMMM")
                    color: screen.foregroundColor
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: form.implicitHeight + 32
                radius: 28
                color: Qt.rgba(screen.surfaceColor.r, screen.surfaceColor.g, screen.surfaceColor.b, screen.surfaceOpacity)
                border.color: screen.borderColor

                ColumnLayout {
                    id: form

                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: screen.controlHeight
                            Layout.preferredHeight: screen.controlHeight
                            radius: height / 2
                            color: screen.fieldColor

                            Image {
                                id: avatar

                                anchors.fill: parent
                                anchors.margins: 4
                                source: account.editText === account.currentText ? (account.currentValue ?? "") : ""
                                sourceSize: Qt.size(width * Screen.devicePixelRatio, height * Screen.devicePixelRatio)
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                            }

                            Label {
                                anchors.centerIn: parent
                                visible: avatar.status !== Image.Ready
                                text: account.editText.trim().slice(0, 1).toUpperCase()
                                color: screen.accentColor
                                font.pointSize: screen.font.pointSize + 4
                                font.weight: Font.DemiBold
                            }
                        }

                        Selector {
                            id: account

                            Layout.fillWidth: true
                            editable: true
                            model: userModel
                            valueRole: "icon"
                            currentIndex: userModel.lastIndex
                            Accessible.name: qsTr("Пользователь")
                        }
                    }

                    TextField {
                        id: password

                        Layout.fillWidth: true
                        implicitHeight: screen.controlHeight
                        leftPadding: 16
                        rightPadding: 16
                        placeholderText: qsTr("Пароль")
                        Accessible.name: placeholderText
                        echoMode: TextInput.Password
                        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                        background: FieldFrame { focused: password.activeFocus }
                        onAccepted: screen.signIn()
                        Component.onCompleted: forceActiveFocus()
                    }

                    PillButton {
                        Layout.fillWidth: true
                        primary: true
                        text: screen.signingIn ? qsTr("Вход…") : qsTr("Войти")
                        enabled: !screen.signingIn && account.editText.trim().length > 0 && session.currentIndex >= 0
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

                    Selector {
                        id: session

                        Layout.fillWidth: true
                        model: sessionModel
                        currentIndex: sessionModel.lastIndex
                        displayText: currentIndex >= 0 ? currentText : qsTr("Сеанс недоступен")
                        Accessible.name: qsTr("Сеанс")
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                PillButton {
                    text: qsTr("Перезагрузить")
                    visible: sddm.canReboot
                    onClicked: sddm.reboot()
                }

                PillButton {
                    text: qsTr("Выключить")
                    visible: sddm.canPowerOff
                    onClicked: sddm.powerOff()
                }
            }
        }
    }
}
