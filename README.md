# UniversalAudioManager
Class for managing audio recording and playback in Swift.

## Getting Started

Import UniversalAudioManager.swift into your Xcode project.

Request permission to record using:
```
UniversalAudioManager.shared.requestRecordingPermissions { (status) in
//do something
}

```
Start recordings using:
```
UniversalAudioManager.shared.startRecording(recordingName:"test")

```
Stop recordings using:
```
UniversalAudioManager.shared.finishRecording()

```
Playback recorded audio using:
```
UniversalAudioManager.shared.playAudioFromDocuments(filename:"test")

```
Delete audio files using:
```
UniversalAudioManager.shared.deleteAudio(filename:"test");

```
## Authors

* **Ernie Lail** - *Initial work* - [MaranathaTech](https://github.com/MaranathaTech)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


