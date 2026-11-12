"""Check the exported stream against its render report and measure the cyclic seam."""

from fractions import Fraction
import json
from math import sqrt
from pathlib import Path
from statistics import mean, median
import subprocess
import sys


def rms(values):
    return sqrt(mean(value ** 2 for value in values))


def verify(video, report):
    streams = json.loads(subprocess.check_output([
        "ffprobe", "-v", "error", "-show_streams", "-of", "json", str(video),
    ]))["streams"]
    if len(streams) != 1:
        raise ValueError("expected one video stream and no other tracks")
    stream = streams[0]
    expected = {
        "codec_name": "h264", "pix_fmt": "yuv420p",
        "width": report["width"], "height": report["height"],
    }
    if any(stream[key] != value for key, value in expected.items()):
        raise ValueError(f"unexpected video stream: {stream}")
    if Fraction(stream["avg_frame_rate"]) != report["fps"]:
        raise ValueError("unexpected frame rate")
    if Fraction(stream["duration_ts"]) * Fraction(stream["time_base"]) != Fraction(
        report["frames"], report["fps"]
    ):
        raise ValueError("unexpected video duration")

    # Downsample luminance for motion measurement, while decoding every original frame.
    frame_size = 160 * 90
    command = [
        "ffmpeg", "-nostdin", "-v", "error", "-xerror", "-err_detect", "explode",
        "-i", str(video), "-vf", "scale=160:90,format=gray",
        "-fps_mode", "passthrough", "-f", "rawvideo", "-",
    ]
    speeds, velocity_changes = [], []
    with subprocess.Popen(command, stdout=subprocess.PIPE) as decoder:
        first = last = decoder.stdout.read(frame_size)
        previous_delta = None
        while frame := decoder.stdout.read(frame_size):
            if len(frame) != frame_size:
                raise ValueError("incomplete decoded frame")
            delta = [right - left for left, right in zip(last, frame)]
            speeds.append(rms(delta))
            if previous_delta is None:
                after = delta
            else:
                velocity_changes.append(rms(a - b for a, b in zip(delta, previous_delta)))
            last, previous_delta = frame, delta
        if decoder.wait():
            raise ValueError("FFmpeg could not decode the video")
    count = len(speeds) + 1
    if len(first) != frame_size or count < 2 or count != report["frames"]:
        raise ValueError("unexpected number of decoded frames")
    seam = [right - left for left, right in zip(last, first)]
    return {
        "decoded_frames": count,
        "bytes": video.stat().st_size,
        "median_frame_delta_rms": median(speeds),
        "max_frame_delta_rms": max(speeds),
        "seam_frame_delta_rms": rms(seam),
        "seam_mean_luma_delta": mean(seam),
        "median_velocity_delta_rms": median(velocity_changes) if velocity_changes else None,
        "max_velocity_delta_rms": max(velocity_changes, default=None),
        "seam_incoming_velocity_delta_rms": rms(a - b for a, b in zip(seam, previous_delta)),
        "seam_outgoing_velocity_delta_rms": rms(a - b for a, b in zip(seam, after)),
    }


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("usage: verify-liquid.py VIDEO.mp4 PARAMETERS.json")
    video_path, report_path = map(Path, sys.argv[1:])
    print(json.dumps(verify(video_path, json.loads(report_path.read_text())), indent=2))
