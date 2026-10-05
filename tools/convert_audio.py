#!/usr/bin/env python3
"""Re-encodes Mr. Rescue's sounds for the Miyoo Mini Plus (one speaker, slow CPU):
music (.ogg, streamed) to mono 32 kHz Vorbis, sound effects (.wav, decoded
into RAM) to mono 22.05 kHz 16-bit. OpenAL resamples to the 48 kHz output.

usage: tools/convert_audio.py SFX_DIR
"""
import os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

def convert(path):
    tmp = path + ".tmp" + os.path.splitext(path)[1]
    if path.endswith(".ogg"):
        args = ["-ac", "1", "-ar", "32000", "-c:a", "libvorbis", "-q:a", "3"]
    else:
        args = ["-ac", "1", "-ar", "22050", "-c:a", "pcm_s16le"]
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", path, *args, tmp], check=True)
    os.replace(tmp, path)

d = sys.argv[1]
files = [os.path.join(d, f) for f in sorted(os.listdir(d)) if f.endswith((".ogg", ".wav"))]
before = sum(os.path.getsize(f) for f in files)
with ThreadPoolExecutor() as ex:
    list(ex.map(convert, files))
after = sum(os.path.getsize(f) for f in files)
print("audio: %d files, %.1f MB -> %.1f MB" % (len(files), before / 1e6, after / 1e6))
