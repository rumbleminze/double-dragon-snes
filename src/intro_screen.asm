intro_screen_data:
.byte $e2, $20, $29, $28, $2b, $2d, $1e, $1d, $00                       ; Ported 
.byte $1b, $32, $00                                                     ; by 
.byte $2b, $2e, $26, $1b, $25, $1e, $26, $22, $27, $33, $1e, $00        ; Rumbleminze, 
.byte $12, $10, $12, $14, $ff                                           ; 2024

.byte $E1, $22, $12, $1a, $10, $13, $00                                 ; 2A03
.byte $2c, $28, $2e, $27, $1d, $00                                      ; SOUND 
.byte $1e, $26, $2e, $25, $1a, $2d, $28, $2b, $ff                       ; EMULATOR
.byte $27, $23, $1b, $32, $00                                           ; BY
.byte $26, $1e, $26, $1b, $25, $1e, $2b, $2c, $ff                       ; MEMBLERS

.byte $78, $23, $2b, $1e, $2f, $1C, $ff ; Version (REVB)
.byte $ff, $ff

write_simple_intro_palette:
    STZ CGADD    
    LDA #$00
    STA CGDATA
    STA CGDATA

    LDA #$FF
    STA CGDATA
    STA CGDATA

    LDA #$B5
    STA CGDATA
    LDA #$56
    STA CGDATA
    
    LDA #$29
    STA CGDATA
    LDA #$25
    STA CGDATA

; sprite default colors
    LDA #$80
    STA CGADD
    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$b5
    STA CGDATA
    LDA #$56
    STA CGDATA

    LDA #$d0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$00
    STA CGDATA
    LDA #$00
    STA CGDATA

    
    LDA #$90
    STA CGADD
    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$00
    STA CGDATA
    LDA #$00
    STA CGDATA

    LDA #$d6
    STA CGDATA
    LDA #$10
    STA CGDATA
    
    LDA #$41
    STA CGDATA
    LDA #$02
    STA CGDATA

    
    LDA #$A0
    STA CGADD
    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$00
    STA CGDATA
    LDA #$00
    STA CGDATA

    LDA #$33
    STA CGDATA
    LDA #$01
    STA CGDATA

    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA

    
    LDA #$B0
    STA CGADD
    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$33
    STA CGDATA
    LDA #$01
    STA CGDATA

    LDA #$33
    STA CGDATA
    LDA #$01
    STA CGDATA
    
    LDA #$6a
    STA CGDATA
    LDA #$00
    STA CGDATA

    RTS


write_simple_intro_tiles:
    LDY #$00

:
    ; get starting address
    LDA intro_screen_data, Y
    CMP #$FF
    BEQ :++

    PHA
    INY    
    LDA intro_screen_data, Y
    STA VMADDH
    PLA
    STA VMADDL
    INY

:
    LDA intro_screen_data, Y
    INY

    CMP #$FF
    BEQ :--

    STA VMDATAL
    BRA :-

:
    RTS

do_simple_intro:
    JSR load_simple_intro_tilesets
    JSR write_simple_intro_palette
    JSR write_default_palettes
    JSR write_simple_intro_tiles

    LDA #$0F
    STA INIDISP
    LDX #$FF

    LDA #240
    STA $10
:
:   LDA RDNMI
    BPL :-
    DEC $10
    BNE :--

    LDA INIDISP_STATE
    ORA #$8F
    STA INIDISP_STATE
    STA INIDISP

    RTS


; loads up the tileset that has the tiles for the intro
load_simple_intro_tilesets:
    lda #$00
    sta NMITIMEN
    LDA VMAIN_STATE
    AND #$0F
    STA VMAIN
    LDA #$8F
    STA INIDISP
    STA INIDISP_STATE

    ; load index 20 bank into both sets of tiles
    ; 20 is our custom intro screen tiles
    LDA #$20
    STA CHR_BANK_BANK_TO_LOAD
    LDA #$01
    STA CHR_BANK_TARGET_BANK
    JSL load_chr_table_to_vm

    rts