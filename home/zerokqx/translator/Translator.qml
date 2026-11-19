pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

FocusScope {
    id: root

    required property bool opened
    property string sourceLanguage: "ru"
    property string targetLanguage: "en"
    property string result
    property string error
    property int revision
    property int requestRevision

    signal back

    readonly property var languages: [
        { code: "ru", name: "Русский" },
        { code: "en", name: "Английский" },
        { code: "ar", name: "Арабский" },
        { code: "be", name: "Белорусский" },
        { code: "vi", name: "Вьетнамский" },
        { code: "el", name: "Греческий" },
        { code: "he", name: "Иврит" },
        { code: "es", name: "Испанский" },
        { code: "it", name: "Итальянский" },
        { code: "zh-CN", name: "Китайский (упр.)" },
        { code: "zh-TW", name: "Китайский (трад.)" },
        { code: "ko", name: "Корейский" },
        { code: "de", name: "Немецкий" },
        { code: "pl", name: "Польский" },
        { code: "pt-BR", name: "Португальский" },
        { code: "tr", name: "Турецкий" },
        { code: "uk", name: "Украинский" },
        { code: "fr", name: "Французский" },
        { code: "hi", name: "Хинди" },
        { code: "cs", name: "Чешский" },
        { code: "ja", name: "Японский" }
    ]

    function schedule(): void {
        ++revision;
        debounce.stop();
        translation.running = false;
        result = "";
        error = "";

        if (opened && source.text.trim()) {
            if (source.text.length > 5000)
                error = "Максимум 5000 символов";
            else if (sourceLanguage === targetLanguage)
                result = source.text;
            else
                debounce.restart();
        }
    }

    function translate(): void {
        if (!opened || debounce.running || translation.running)
            return;

        requestRevision = revision;
        translation.stdinEnabled = true;
        translation.exec([
            "@timeout@", "--kill-after=1s", "15s",
            "@translateShell@", "-no-init", "-engine", "google", "-brief", "-no-ansi",
            "-no-autocorrect", "-no-bidi", "-no-browser", "-no-play", "-no-view",
            "-source", sourceLanguage, "-target", targetLanguage
        ]);
    }

    function swap(): void {
        const previousSource = sourceLanguage;
        const previousResult = result;
        sourceLanguage = targetLanguage;
        targetLanguage = previousSource;
        if (previousResult)
            source.text = previousResult;
        source.forceActiveFocus();
    }

    onSourceLanguageChanged: schedule()
    onTargetLanguageChanged: schedule()
    onOpenedChanged: {
        if (opened) {
            source.forceActiveFocus();
        } else {
            source.clear();
            sourceLanguage = "ru";
            targetLanguage = "en";
            schedule();
        }
    }
    Component.onCompleted: {
        if (opened)
            source.forceActiveFocus();
    }

    Keys.priority: Keys.AfterItem
    Keys.onEscapePressed: root.back()

    Timer {
        id: debounce

        interval: 450
        onTriggered: root.translate()
    }

    Process {
        id: translation

        onStarted: {
            if (root.opened && root.requestRevision === root.revision) {
                // Translate Shell treats lines beginning with https:// as web pages.
                write(source.text.replace(/^https:\/\//gm, " https://") + "\n");
            }
            stdinEnabled = false;
        }
        stdout: StdioCollector {
            id: output
        }
        // Some backend failures produce partial stdout alongside a diagnostic.
        stderr: StdioCollector {
            id: diagnostic
        }

        onExited: code => {
            if (!root.opened)
                return;
            if (root.requestRevision !== root.revision) {
                if (!debounce.running && source.text.trim() && !root.error && root.sourceLanguage !== root.targetLanguage)
                    Qt.callLater(root.translate);
                return;
            }

            if (code === 0 && output.text.trim() && !diagnostic.text)
                root.result = output.text.replace(/\n$/, "");
            else
                root.error = "Не удалось перевести текст";
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.medium

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: "translate"
                color: Colours.palette.m3primary
            }

            StyledText {
                Layout.fillWidth: true
                text: "Переводчик"
                font: Tokens.font.title.medium
                elide: Text.ElideRight
            }

            IconButton {
                icon: "close"
                type: IconButton.Text
                Accessible.name: "Вернуться к быстрым настройкам"
                onClicked: root.back()
            }
        }

        RowLayout {
            id: languagesRow

            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            LanguageSelect {
                objectName: "translatorSourceLanguage"
                Accessible.name: "Язык оригинала"
                currentValue: root.sourceLanguage
                onActivated: root.sourceLanguage = currentValue
            }

            IconButton {
                objectName: "translatorSwap"
                icon: "swap_horiz"
                type: IconButton.Tonal
                Accessible.name: "Поменять языки местами"
                onClicked: root.swap()
            }

            LanguageSelect {
                objectName: "translatorTargetLanguage"
                Accessible.name: "Язык перевода"
                currentValue: root.targetLanguage
                onActivated: root.targetLanguage = currentValue
            }
        }

        TextPane {
            id: sourcePane

            colour: Colours.tPalette.m3surfaceContainer
            border.color: source.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant

            Editor {
                id: source

                objectName: "translatorSource"
                Accessible.name: "Исходный текст"
                placeholderText: "Введите текст"
                onTextChanged: root.schedule()
            }
        }

        TextPane {
            colour: Colours.tPalette.m3surfaceContainerHigh

            Editor {
                objectName: "translatorResult"
                Accessible.name: "Переведённый текст"
                readOnly: true
                text: root.result
                placeholderText: root.error || (debounce.running || translation.running ? "Переводим…" : "Перевод")
                placeholderTextColor: root.error ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
            }
        }
    }

    component LanguageSelect: Controls.ComboBox {
        id: select

        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.preferredWidth: 1

        model: root.languages
        textRole: "name"
        valueRole: "code"
        font: Tokens.font.label.large
        leftPadding: Tokens.padding.medium
        rightPadding: chevron.implicitWidth + Tokens.padding.medium * 2
        implicitHeight: 38

        background: StyledRect {
            radius: Tokens.rounding.medium
            color: Colours.tPalette.m3surfaceContainer
            border.width: 1
            border.color: parent.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant
        }

        indicator: MaterialIcon {
            id: chevron

            x: parent.width - implicitWidth - Tokens.padding.medium
            y: (parent.height - implicitHeight) / 2
            text: "expand_more"
            color: Colours.palette.m3onSurfaceVariant
        }

        contentItem: StyledText {
            text: select.displayText
            font: select.font
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        delegate: Controls.ItemDelegate {
            id: option

            required property int index

            width: select.width - select.popup.leftPadding - select.popup.rightPadding
            text: select.textAt(index)
            highlighted: select.highlightedIndex === index
            contentItem: StyledText {
                text: option.text
                font: select.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            background: StyledRect {
                color: option.highlighted || option.hovered ? Colours.palette.m3surfaceContainerHighest : "transparent"
            }
        }

        popup.popupType: Controls.Popup.Item
        popup.y: height + Tokens.spacing.small
        popup.padding: 4
        popup.height: Math.min(popup.contentItem.implicitHeight + popup.topPadding + popup.bottomPadding,
            Math.max(0, root.height - languagesRow.y - languagesRow.height - Tokens.spacing.small))
        popup.background: StyledRect {
            radius: Tokens.rounding.medium
            color: Colours.palette.m3surfaceContainerHigh
            border.width: 1
            border.color: Colours.palette.m3outlineVariant
        }
    }

    component TextPane: StyledRect {
        property color colour

        default property alias contents: scroll.contentData

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: 150
        Layout.minimumHeight: 0

        radius: Tokens.rounding.large
        color: colour
        border.width: 1
        border.color: "transparent"

        Controls.ScrollView {
            id: scroll

            anchors.fill: parent
            anchors.margins: 1
            clip: true
            contentWidth: availableWidth
            Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
        }
    }

    component Editor: Controls.TextArea {
        padding: Tokens.padding.large
        font: Tokens.font.body.large
        color: Colours.palette.m3onSurface
        placeholderTextColor: Colours.palette.m3onSurfaceVariant
        textFormat: TextEdit.PlainText
        wrapMode: TextEdit.Wrap
        selectByMouse: true
        background: null
    }
}
