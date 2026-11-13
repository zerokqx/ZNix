pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtMultimedia
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    required property ScreenState screenState

    property real offsetScale: screenState.clipboard ? 0 : 1

    readonly property bool sideBySide: parent.width >= 560
    readonly property real compactWidth: Math.min(540, sideBySide ? parent.width - 280 : parent.width)
    readonly property real previewWidth: sideBySide ? Math.min(360, parent.width - compactWidth) : 0
    property real expandedWidth: loader.item?.previewRequested ? previewWidth : 0
    readonly property real visiblePreviewWidth: Math.max(0, Math.min(previewWidth, expandedWidth))

    x: Math.max(0, Math.min((parent.width - compactWidth) / 2, parent.width - compactWidth - previewWidth))
    implicitWidth: compactWidth + visiblePreviewWidth
    implicitHeight: Math.min(500, parent.height * 0.8)
    anchors.bottomMargin: (-height - 5) * offsetScale
    visible: offsetScale < 1
    opacity: 1 - offsetScale

    Behavior on offsetScale {
        Anim {}
    }

    Behavior on expandedWidth {
        Anim {}
    }

    Loader {
        id: loader

        anchors.fill: parent
        active: root.screenState.clipboard || root.visible
        sourceComponent: contents
    }

    Component {
        id: contents

        FocusScope {
            id: drawer

            readonly property string backend: "@clipboardBackend@"
            readonly property var currentEntry: cards.model[cards.currentIndex]
            readonly property bool previewRequested: selectedIdentifier !== "" && selectedIdentifier === currentEntry?.identifier
            property string selectedIdentifier: ""
            property var entries: []
            property string error: ""

            function select(index): void {
                if (index < 0 || index >= cards.count)
                    return;
                cards.currentIndex = index;
                selectedIdentifier = cards.model[index].identifier;
                cards.positionViewAtIndex(index, ListView.Contain);
            }

            function focusSearch(): void {
                if (root.screenState.clipboard)
                    search.forceActiveFocus();
            }

            function copyEntry(entry): void {
                if (!root.screenState.clipboard || !entry || history.running || copier.running)
                    return;
                error = "";
                copier.exec([backend, "copy", entry.identifier]);
            }

            Keys.priority: Keys.AfterItem
            Keys.onEscapePressed: root.screenState.clipboard = false
            Keys.onDownPressed: drawer.select(Math.min(cards.count - 1, cards.currentIndex + 1))
            Keys.onUpPressed: drawer.select(Math.max(0, cards.currentIndex - 1))
            Keys.onReturnPressed: drawer.copyEntry(drawer.currentEntry)
            Keys.onEnterPressed: drawer.copyEntry(drawer.currentEntry)

            onSelectedIdentifierChanged: detailDelay.restart()

            Timer {
                id: detailDelay

                interval: 75
            }

            Connections {
                target: root.screenState

                function onClipboardChanged(): void {
                    if (root.screenState.clipboard) {
                        drawer.entries = [];
                        drawer.error = "";
                        drawer.selectedIdentifier = "";
                        search.clear();
                        Qt.callLater(drawer.focusSearch);
                        history.running = true;
                    }
                }
            }

            Process {
                id: history

                command: [drawer.backend, "list"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        if (text)
                            drawer.entries = JSON.parse(text);
                    }
                }
                onExited: code => {
                    if (code !== 0)
                        drawer.error = "Не удалось прочитать историю";
                }
            }

            Process {
                id: copier

                onExited: code => {
                    if (code === 0)
                        root.screenState.clipboard = false;
                    else
                        drawer.error = "Запись не удалось скопировать";
                }
            }

            ColumnLayout {
                id: listColumn

                x: Tokens.padding.large
                y: Tokens.padding.large
                width: Math.max(0, root.compactWidth - x * 2)
                height: Math.max(0, parent.height - y * 2)
                spacing: Tokens.spacing.medium

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.medium

                    MaterialIcon {
                        text: "content_paste"
                        color: Colours.palette.m3primary
                    }

                    StyledText {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        text: "Буфер обмена"
                        font: Tokens.font.title.medium
                        elide: Text.ElideRight
                    }

                    IconButton {
                        icon: "close"
                        type: IconButton.Text
                        Accessible.name: "Закрыть"
                        onClicked: root.screenState.clipboard = false
                    }
                }

                SearchBar {
                    id: search

                    Layout.fillWidth: true
                    placeholderText: "Поиск по истории"

                    Component.onCompleted: Qt.callLater(drawer.focusSearch)
                    onAccepted: drawer.copyEntry(drawer.currentEntry)
                    onTextChanged: drawer.selectedIdentifier = ""
                    Keys.onDownPressed: drawer.select(Math.min(cards.count - 1, cards.currentIndex + 1))
                    Keys.onUpPressed: drawer.select(Math.max(0, cards.currentIndex - 1))
                }

                Item {
                    id: listArea

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ListView {
                        id: cards

                        anchors.fill: parent
                        visible: root.sideBySide || !drawer.previewRequested
                        clip: true
                        cacheBuffer: 0
                        spacing: Tokens.spacing.small
                        boundsBehavior: Flickable.StopAtBounds

                        model: {
                            const query = search.text.trim().toLowerCase();
                            return drawer.entries.filter(entry => {
                                const preview = (entry.image ? "изображение " : "") + entry.preview;
                                return preview.toLowerCase().includes(query);
                            });
                        }
                        onModelChanged: currentIndex = model.length ? 0 : -1

                        delegate: StyledRect {
                            id: card

                            required property var modelData
                            required property int index

                            readonly property bool selected: ListView.isCurrentItem
                            readonly property bool inViewport: y < cards.contentY + cards.height && y + height > cards.contentY
                            property bool requested: false

                            function requestPreview(): void {
                                if (modelData.image && inViewport && !requested) {
                                    requested = true;
                                    preview.running = true;
                                }
                            }

                            width: ListView.view.width
                            height: Math.max(modelData.image ? 112 : 76, labels.implicitHeight + Tokens.padding.medium * 2)
                            clip: true
                            radius: selected ? Tokens.rounding.extraLarge : Tokens.rounding.medium
                            color: selected ? Colours.tPalette.m3secondaryContainer : Colours.tPalette.m3surfaceContainer

                            onInViewportChanged: requestPreview()
                            Component.onCompleted: requestPreview()

                            Behavior on radius {
                                Anim {}
                            }

                            Process {
                                id: preview

                                command: [drawer.backend, "preview", card.modelData.identifier]
                                stdout: StdioCollector {
                                    onStreamFinished: thumbnail.source = text.trim()
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Tokens.padding.medium
                                spacing: Tokens.spacing.medium

                                StyledRect {
                                    visible: card.modelData.image
                                    Layout.preferredWidth: Math.min(148, card.width * 0.36)
                                    Layout.fillHeight: true
                                    radius: Tokens.rounding.medium
                                    color: Colours.tPalette.m3surfaceContainerLow

                                    Image {
                                        id: thumbnail

                                        anchors.fill: parent
                                        anchors.margins: Tokens.padding.extraSmall
                                        cache: false
                                        fillMode: Image.PreserveAspectFit
                                        asynchronous: true
                                    }

                                    MaterialIcon {
                                        visible: thumbnail.status !== Image.Ready
                                        anchors.centerIn: parent
                                        text: "image"
                                        color: Colours.palette.m3onSurfaceVariant
                                    }
                                }

                                MaterialIcon {
                                    visible: !card.modelData.image
                                    text: "notes"
                                    color: card.selected ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3primary
                                }

                                ColumnLayout {
                                    id: labels

                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    spacing: Tokens.spacing.extraSmall

                                    StyledText {
                                        text: card.modelData.image ? "Изображение" : "Текст"
                                        font: Tokens.font.label.small
                                        color: card.selected ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                                    }

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: card.modelData.preview
                                        font: Tokens.font.body.medium
                                        color: card.selected ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            StateLayer {
                                radius: card.radius
                                shapeMorph: true
                                onClicked: drawer.select(card.index)
                            }
                        }
                    }

                    StyledText {
                        anchors.centerIn: parent
                        visible: cards.visible && !history.running && cards.count === 0 && !drawer.error
                        text: search.text ? "Ничего не найдено" : "История пуста"
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: drawer.error || "Клик / ↑ ↓  Превью    ↵  Копировать    Esc  Закрыть"
                    font: Tokens.font.label.small
                    color: drawer.error ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
                }
            }

            Item {
                id: previewPane

                x: root.sideBySide ? root.compactWidth : Tokens.padding.large
                y: root.sideBySide ? listColumn.y : listColumn.y + listArea.y
                width: root.sideBySide ? root.visiblePreviewWidth : listColumn.width
                height: root.sideBySide ? listColumn.height : listArea.height
                clip: true
                visible: root.sideBySide ? width > 0 : drawer.previewRequested

                StyledRect {
                    width: root.sideBySide ? root.previewWidth - Tokens.padding.large : parent.width
                    height: parent.height
                    radius: Tokens.rounding.extraLarge
                    color: Colours.tPalette.m3surfaceContainerLow

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Tokens.padding.medium
                        spacing: Tokens.spacing.medium

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            IconButton {
                                icon: "arrow_back"
                                type: IconButton.Text
                                Accessible.name: "Скрыть превью"
                                onClicked: {
                                    drawer.selectedIdentifier = "";
                                    drawer.focusSearch();
                                }
                            }

                            StyledText {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                text: "Превью"
                                font: Tokens.font.title.small
                                elide: Text.ElideRight
                            }

                            IconButton {
                                icon: "content_copy"
                                type: IconButton.Text
                                Accessible.name: "Скопировать запись"
                                disabled: !drawer.previewRequested || copier.running
                                onClicked: drawer.copyEntry(drawer.currentEntry)
                            }
                        }

                        Loader {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            active: root.screenState.clipboard && drawer.previewRequested && !detailDelay.running
                            sourceComponent: detailContent
                        }
                    }
                }
            }

            Component {
                id: detailContent

                Item {
                    id: detail

                    property var payload: null
                    property bool failed: false

                    Process {
                        command: [drawer.backend, "detail", drawer.selectedIdentifier]
                        running: true
                        stdout: StdioCollector {
                            onStreamFinished: {
                                if (text)
                                    detail.payload = JSON.parse(text);
                            }
                        }
                        onExited: code => detail.failed = code !== 0
                    }

                    Flickable {
                        id: detailScroll

                        anchors.fill: parent
                        visible: detail.payload?.kind === "text"
                        clip: true
                        contentWidth: width
                        contentHeight: detailText.height
                        boundsBehavior: Flickable.StopAtBounds

                        Controls.ScrollBar.vertical: StyledScrollBar {
                            flickable: detailScroll
                        }

                        StyledText {
                            id: detailText

                            width: Math.max(0, detailScroll.width - Tokens.padding.small)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: (detail.payload?.text ?? "") + (detail.payload?.truncated ? "\n\nПревью сокращено" : "")
                        }
                    }

                    Image {
                        id: detailImage

                        anchors.fill: parent
                        visible: detail.payload?.kind === "image"
                        source: visible ? detail.payload.source : ""
                        cache: false
                        asynchronous: true
                        fillMode: Image.PreserveAspectFit
                    }

                    Loader {
                        anchors.fill: parent
                        active: detail.payload?.kind === "video"
                        sourceComponent: ColumnLayout {
                            spacing: Tokens.spacing.small

                            VideoOutput {
                                id: videoOutput

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                fillMode: VideoOutput.PreserveAspectFit
                                endOfStreamPolicy: VideoOutput.KeepLastFrame

                                StyledText {
                                    anchors.centerIn: parent
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    visible: videoPlayer.error !== MediaPlayer.NoError || videoOutput.sourceRect.width === 0
                                    text: videoPlayer.error !== MediaPlayer.NoError ? "Видео не удалось открыть" : "Локальное видео"
                                }
                            }

                            MediaPlayer {
                                id: videoPlayer

                                videoOutput: videoOutput
                                audioOutput: AudioOutput { muted: true }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                IconButton {
                                    icon: videoPlayer.playing ? "pause" : "play_arrow"
                                    Accessible.name: videoPlayer.playing ? "Пауза" : "Воспроизвести"
                                    disabled: videoPlayer.error !== MediaPlayer.NoError
                                    onClicked: {
                                        if (videoPlayer.playing) {
                                            videoPlayer.pause();
                                        } else {
                                            if (videoPlayer.mediaStatus === MediaPlayer.NoMedia)
                                                videoPlayer.source = detail.payload.source;
                                            videoPlayer.play();
                                        }
                                    }
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    text: detail.payload.name
                                    elide: Text.ElideMiddle
                                }
                            }
                        }
                    }

                    StyledText {
                        anchors.centerIn: parent
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        visible: !detail.payload || detail.failed || ["unavailable", "unsupported"].includes(detail.payload?.kind) || detailImage.status === Image.Error
                        text: {
                            if (detail.failed || detail.payload?.kind === "unavailable" || detailImage.status === Image.Error)
                                return "Превью недоступно";
                            if (detail.payload?.kind === "unsupported")
                                return "Для этой записи нет превью";
                            return "Загрузка…";
                        }
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }
            }
        }
    }
}
