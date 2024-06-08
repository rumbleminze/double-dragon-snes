; for the hud we want the HOFFS to be 0 for scan lines after line 199

hud_hdma_setup:
    LDA #$02
    STA DMAP7

    LDA #.lobyte(BG1HOFS)
    STA BBAD7

    LDA #.lobyte(HUD_HOFFS_HDMA_TABLE)
    STA A1T7L

    LDA #.hibyte(HUD_HOFFS_HDMA_TABLE)
    STA A1T7H

    LDA #$A0
    STA A1B7
    
    ; 200 scan lines
    lda #127
    sta HUD_HOFFS_HDMA_TABLE
    lda HOFS_HB
    sta HUD_HOFFS_HDMA_TABLE + 2
    sta HUD_HOFFS_HDMA_TABLE + 5
    lda HOFS_LB
    sta HUD_HOFFS_HDMA_TABLE + 1
    sta HUD_HOFFS_HDMA_TABLE + 4

    lda #73
    sta HUD_HOFFS_HDMA_TABLE + 3

   
    LDA #40
    ; 40 scanlines of 0 HOFFS
    STA HUD_HOFFS_HDMA_TABLE + 6

    STZ HUD_HOFFS_HDMA_TABLE + 7
    STZ HUD_HOFFS_HDMA_TABLE + 8
    
    ; end table
    STZ HUD_HOFFS_HDMA_TABLE + 9

    LDA INIDISP_STATE
    AND #$80
    BNE :+

    LDA HDMA_ENABLED_STATE
    ORA #%10000000
    STA HDMAEN
    STA HDMA_ENABLED_STATE
:
    RTL


hud_hdma_voffs_setup:
    STZ VOFS_HB
    LDA PPU_CONTROL_STATE
    AND #$02
    BEQ :+
    INC VOFS_HB
    :

    LDA #$02
    STA DMAP6

    LDA #.lobyte(BG1VOFS)
    STA BBAD6

    LDA #.lobyte(HUD_VOFFS_HDMA_TABLE)
    STA A1T6L

    LDA #.hibyte(HUD_VOFFS_HDMA_TABLE)
    STA A1T6H

    LDA #$A0
    STA A1B6
    
    ; 200 scan lines
    lda #127
    sta HUD_VOFFS_HDMA_TABLE
    lda VOFS_HB
    sta HUD_VOFFS_HDMA_TABLE + 2
    sta HUD_VOFFS_HDMA_TABLE + 5
    lda VOFS_LB
    sta HUD_VOFFS_HDMA_TABLE + 1
    sta HUD_VOFFS_HDMA_TABLE + 4

    lda #73
    sta HUD_VOFFS_HDMA_TABLE + 3

   
    LDA #40
    ; 40 scanlines of 0 VOFFS
    STA HUD_VOFFS_HDMA_TABLE + 6
    STZ HUD_VOFFS_HDMA_TABLE + 7
    LDA #$01
    STA HUD_VOFFS_HDMA_TABLE + 8
    
    ; end table
    STZ HUD_VOFFS_HDMA_TABLE + 9

    LDA INIDISP_STATE
    AND #$80
    BNE :+

    LDA HDMA_ENABLED_STATE
    ORA #%01000000
    STA HDMAEN
    STA HDMA_ENABLED_STATE
:
    RTL

