pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    required property ScreenState screenState

    property real offsetScale: screenState.clipboard ? 0 : 1

    implicitWidth: Math.min(540, parent.width)
    implicitHeight: Math.min(500, parent.height * 0.8)
    anchors.bottomMargin: (-height - 5) * offsetScale
    visible: offsetScale < 1
    opacity: 1 - offsetScale

    Behavior on offsetScale {
        Anim {}
    }

    Loader {
        anchors.fill: parent
        active: root.screenState.clipboard || root.visible
        sourceComponent: contents
    }

    Component {
        id: contents

        FocusScope {
            id: drawer

            readonly property string backend: "@clipboardBackend@"
            property var entries: []
            property string error: ""

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

            Connections {
                target: root.screenState

                function onClipboardChanged(): void {
                    if (root.screenState.clipboard) {
                        drawer.entries = [];
                        drawer.error = "";
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
                anchors.fill: parent
                anchors.margins: Tokens.padding.large
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
                        text: "Буфер обмена"
                        font: Tokens.font.title.medium
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
                    onAccepted: drawer.copyEntry(cards.model[cards.currentIndex])
                    Keys.onDownPressed: cards.currentIndex = Math.min(cards.count - 1, cards.currentIndex + 1)
                    Keys.onUpPressed: cards.currentIndex = cards.count ? Math.max(0, cards.currentIndex - 1) : -1
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ListView {
                        id: cards

                        anchors.fill: parent
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
                            height: modelData.image ? 112 : 72
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
                                    Layout.fillWidth: true
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
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            StateLayer {
                                radius: card.radius
                                shapeMorph: true
                                onClicked: {
                                    cards.currentIndex = card.index;
                                    drawer.copyEntry(card.modelData);
                                }
                            }
                        }
                    }

                    StyledText {
                        anchors.centerIn: parent
                        visible: !history.running && cards.count === 0 && !drawer.error
                        text: search.text ? "Ничего не найдено" : "История пуста"
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    text: drawer.error || "↑ ↓  Выбор     ↵  Копировать     Esc  Закрыть"
                    font: Tokens.font.label.small
                    color: drawer.error ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
                }
            }
        }
    }
}
