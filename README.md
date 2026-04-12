# Combat-style 6502 Prototype (Step 1)

This repository now contains the first visual step of a Combat-style Atari 2600 project:
a static screen drawn with scanlines and simple sprite shapes.

## File

- `combat_image.asm` – 6502/TIA code that draws:
  - pink outer border,
  - light-green inner arena,
  - rectangular playfield wall lines,
  - one red and one blue static tank-like glyph.

## Build

Using DASM:

```bash
dasm combat_image.asm -f3 -v0 -ocombat_image.bin
```

Then run `combat_image.bin` in an Atari 2600 emulator (e.g., Stella).
