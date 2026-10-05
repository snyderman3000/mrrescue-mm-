# Third-party notices

The port code in this repository (build scripts, `overlay/`, `mini2d/`,
`dspfix/`, `pkgsrc/`, `tools/`) is MIT licensed, see `LICENSE`.
The release zip also contains the following software and assets, each under
its own license.

| Component | License | Source |
|---|---|---|
| Mr. Rescue by Tangram Games (game code) | zlib (`game/LICENSE`) | https://github.com/SimonLarsen/mrrescue |
| Mr. Rescue (graphics, music, text) | CC BY-SA 3.0 Unported, © 2013 Tangram Games. Sound files are re-encoded for the handheld (mono, lower sample rate); no other asset changes | same |
| slam (bundled with Mr. Rescue) | MIT, © 2011 Matthias Richter | same |
| AnAL (bundled with Mr. Rescue) | MIT-style, © 2009-2010 Bart Bes | same |
| TSerial 1.3 by Taehl (bundled with Mr. Rescue) | no license stated in the file; distributed as part of Mr. Rescue | same |
| LÖVE 11.5 | zlib | https://github.com/love2d/love |
| LuaJIT 2.1 | MIT | https://github.com/LuaJIT/LuaJIT |
| SDL2 (from the Miyoo Mini toolchain) | zlib | https://github.com/steward-fu/sdl2 |
| OpenAL Soft 1.21.1 | LGPL-2.1-or-later, dynamically linked | https://github.com/kcat/openal-soft (source attached to every release as `openal-soft-1.21.1-source.tar.gz`) |
| FreeType | FreeType License (FTL) | https://freetype.org |
| libpng, zlib | libpng / zlib licenses | http://www.libpng.org, https://zlib.net |
| libogg, libvorbis, libtheora | BSD-3-Clause | https://xiph.org |
| libmodplug | public domain | https://github.com/Konstanty/libmodplug |
| bzip2 | bzip2 license (BSD-style) | https://sourceware.org/bzip2 |
| json-c | MIT | https://github.com/json-c/json-c |
| GCC runtime (libgcc_s, libstdc++, libatomic) | GPL-3.0 with the GCC Runtime Library Exception | https://gcc.gnu.org |

The LÖVE runtime and shared libraries are the same builds used by
[panelattack-miyoo](https://github.com/snyderman3000/panelattack-miyoo); the
libraries come unmodified from the Miyoo Mini toolchain sysroot (steward-fu's
`mini_toolchain`). OpenAL Soft is loaded as a separate shared library
(`lib/libopenal.so.1`), so it can be replaced with any compatible build.
