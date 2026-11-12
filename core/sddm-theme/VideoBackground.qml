import QtQuick
import QtMultimedia

VideoOutput {
    id: background

    required property url mediaSource

    clip: true
    fillMode: VideoOutput.PreserveAspectCrop
    endOfStreamPolicy: VideoOutput.KeepLastFrame
    visible: sourceRect.width > 0 && player.error === MediaPlayer.NoError

    MediaPlayer {
        id: player

        source: background.mediaSource
        videoOutput: background
        autoPlay: true
        loops: MediaPlayer.Infinite
    }
}
