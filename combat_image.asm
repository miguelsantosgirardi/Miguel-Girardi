; -----------------------------------------------------------------------------
; combat_image.asm
; Atari 2600 / 6502 static mock-up inspired by Combat (1977)
; Step 1: draw the playfield image (lines + two static tanks)
;
; Assemble (DASM):
;   dasm combat_image.asm -f3 -v0 -ocombat_image.bin
; -----------------------------------------------------------------------------

        processor 6502

; TIA write registers
VSYNC   = $00
VBLANK  = $01
WSYNC   = $02
NUSIZ0  = $04
NUSIZ1  = $05
COLUP0  = $06
COLUP1  = $07
COLUPF  = $08
COLUBK  = $09
CTRLPF  = $0A
PF0     = $0D
PF1     = $0E
PF2     = $0F
RESP0   = $10
RESP1   = $11
GRP0    = $1B
GRP1    = $1C
ENAM0   = $1D
ENAM1   = $1E
HMOVE   = $2A

; RIOT
SWCHA   = $0280

        seg.u   RAM
        org     $80
lineCounter ds 1

        seg     CODE
        org     $F000

Reset:
        sei
        cld
        ldx #$FF
        txs

        lda #0
ClearRam:
        sta $80,x
        dex
        bne ClearRam

        lda #$00
        sta VBLANK
        sta VSYNC
        sta GRP0
        sta GRP1
        sta ENAM0
        sta ENAM1

MainLoop:
; -------------------------
; Vertical sync (3 lines)
; -------------------------
        lda #2
        sta VSYNC
        sta WSYNC
        sta WSYNC
        sta WSYNC
        lda #0
        sta VSYNC

; -------------------------
; Vertical blank + setup
; -------------------------
        lda #2
        sta VBLANK

        lda #$38            ; pink-ish arena surround
        sta COLUBK
        lda #$B8            ; light green playfield walls / accents
        sta COLUPF
        lda #$46            ; red tank
        sta COLUP0
        lda #$84            ; blue tank
        sta COLUP1

        lda #%00000001      ; reflect playfield for symmetric arena
        sta CTRLPF

        lda #0
        sta PF0
        sta PF1
        sta PF2

        ; Player size normal
        lda #0
        sta NUSIZ0
        sta NUSIZ1

        ; Rough horizontal positions for two tanks
        sta WSYNC
        lda #0
        sta RESP0
        lda #0
        sta RESP1

        ldx #37             ; 37 lines vblank
VBlankLoop:
        sta WSYNC
        dex
        bne VBlankLoop

        lda #0
        sta VBLANK

; -------------------------
; Visible kernel (192 lines)
; -------------------------
        ldx #192
VisibleLoop:
        stx lineCounter

        ; Default background is pink border
        lda #$38
        sta COLUBK

        ; Turn on green play area between scanlines ~30..170
        cpx #170
        bcs BorderLine
        cpx #30
        bcc BorderLine

        lda #$B8            ; light green center
        sta COLUBK

        ; Draw thin border line via playfield on top and bottom of arena interior
        cpx #169
        beq DrawWall
        cpx #31
        beq DrawWall

        ; Draw left/right wall slices in middle section
        cpx #166
        bcs DrawWall
        cpx #34
        bcc DrawWall

        ; No wall this scanline
        lda #0
        sta PF0
        sta PF1
        sta PF2
        jmp DrawSprites

BorderLine:
        lda #0
        sta PF0
        sta PF1
        sta PF2
        jmp DrawSprites

DrawWall:
        ; Coarse rectangular wall shape similar to screenshot
        lda #%11110000
        sta PF0
        lda #%00000000
        sta PF1
        lda #%00001111
        sta PF2

DrawSprites:
        ; Tanks: short 3-line glyphs at fixed Y positions
        lda #0
        sta GRP0
        sta GRP1

        ; Red tank near middle-left
        cpx #110
        beq RedTankA
        cpx #109
        beq RedTankB
        cpx #108
        beq RedTankC

BlueCheck:
        ; Blue tank near right-middle
        cpx #120
        beq BlueTankA
        cpx #119
        beq BlueTankB
        cpx #118
        beq BlueTankC
        jmp EndLine

RedTankA:
        lda #%00111000
        sta GRP0
        jmp BlueCheck
RedTankB:
        lda #%01111100
        sta GRP0
        jmp BlueCheck
RedTankC:
        lda #%00101000
        sta GRP0
        jmp BlueCheck

BlueTankA:
        lda #%00011100
        sta GRP1
        jmp EndLine
BlueTankB:
        lda #%00111110
        sta GRP1
        jmp EndLine
BlueTankC:
        lda #%00101010
        sta GRP1

EndLine:
        sta WSYNC
        dex
        bne VisibleLoop

; -------------------------
; Overscan (30 lines)
; -------------------------
        lda #2
        sta VBLANK
        ldx #30
OverscanLoop:
        sta WSYNC
        dex
        bne OverscanLoop

        jmp MainLoop

        org $FFFC
        .word Reset
        .word Reset
