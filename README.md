# GodotVoIP

A minimal VoIP example using no external libraries.

## Networking

The networking for this project follows the standard godot networking example found [here](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html#example-lobby-implementation).

## Audio Bus

In the audio tab I added two Buses, Mic and MicSink. The Mic Bus has a Capture effect on it and is pointing into MicSink which is muted. 

## Node Setup

The only required nodes are AudioStreamPlayers and/or their 2D and 3D counterparts.

### Microphone Node

Every player must have an AudioStreamPlayer for capturing the microphone input. This node's stream must be of type AudioStreamMicrophone, Autoplay should be On and the Bus should point to the Mic Bus.

![Microphone Node Setup](./assets/mic_node_setup.png)

### VoIP Playback Node

In this example only one VoIP playback node exists. In a real use case you would spawn one node per client.

Depending on your use case this node can be an AudioStreamPlayer, AudioStreamPlayer2D or AudioStreamPlayer3D. For this project I used an AudioStreamPlayer. This node's stream must be of type AudioStreamGenerator, Autoplay should be On and the Bus can be left as the default.

![VoIP Node Setup](./assets/voip_node_setup.png)

## VoIP Script

```GDScript
extends AudioStreamPlayer

var effect: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback

@onready var voip: AudioStreamPlayer = $"../VoIP"

func _ready():
    # Get the capture effect we added on the Mic Bus
	var idx = AudioServer.get_bus_index("Mic")
	effect = AudioServer.get_bus_effect(idx, 0)
	
    # Get the playback stream from our voip AudioStreamPlayer
	playback = voip.get_stream_playback()

func _process(_delta):
	var frames: PackedVector2Array
	
	if effect.can_get_buffer(1024):
        # Get 1024 audio frames at a time.
		frames = effect.get_buffer(1024)

        # Send the audio frames over RPC
		playback_voip.rpc(frames)


@rpc("any_peer", "call_remote", "unreliable_ordered", 1)
func playback_voip(frames: PackedVector2Array):
    # Push the frames to the voip audio buffer
	playback.push_buffer(frames)
```

## Notes

Any sound effects such as EQ, Distortion, Noise Gates, Etc, are better added as an audio effect on the buffer than on the VoIP implementation.

## Updates

### February 8th 2024

#### Networking

- Moved the networking setup to be an autoload scene;
- Changed the main menu to call the networking scene;
- Added the option of changing the compression method used by the [ENetConnections](https://docs.godotengine.org/en/stable/classes/class_enetconnection.html) of the multiplayer peers;
- The client will now be kicked back to the main menu when the server disconnects;
- Exported networking configurations;

#### Voip

- Added a stereo_to_mono function. (Sending a mono track is half as expensive);
- Added a mono_to_stereo function. (Godot's buffers are stereo by default so we need to convert the mono track to stereo);
- No RPC calls will now be done if no microphone input is detected;