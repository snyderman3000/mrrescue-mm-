import sys, glob, re, os
from PIL import Image
# usage: tile.py out.png [frame indices...]   (frames from $PD or /tmp/pd, shown at 2x)
fs = sorted(glob.glob(os.environ.get('PD', '/tmp/pd') + '/*.ppm'), key=lambda f: int(re.findall(r'\d+', f.split('/')[-1])[0]))
idx = [int(a) for a in sys.argv[2:]] or list(range(len(fs)))
out = sys.argv[1]
first = Image.open(fs[idx[0]]); w, h = first.size[0] * 2, first.size[1] * 2
cols = min(3, len(idx)); rows = (len(idx) + cols - 1) // cols
W = Image.new('RGB', (w * cols + 4 * (cols - 1), h * rows + 4 * (rows - 1)), (60, 60, 60))
for k, i in enumerate(idx):
    W.paste(Image.open(fs[i]).resize((w, h), Image.NEAREST), ((k % cols) * (w + 4), (k // cols) * (h + 4)))
W.save(out)
print(out, [fs[i].split('/')[-1] for i in idx])
