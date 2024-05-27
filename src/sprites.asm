translate_8by8only_nes_sprites_to_oam:
    ; check if we need to do this
    LDA SNES_OAM_TRANSLATE_NEEDED
    BNE :+
    RTL
    ; PHA
    ; PHX
    ; PHY
    ; PHB
    ; we clobber this ZP value, so save it off
:   LDA SPRITE_LOOP_JUNK
    PHA

   setXY16
	LDY #$0000

sprite_loop:	

	; byte 0, Tile Y position
	LDA $200,Y
	STA SNES_OAM_START + 1, y
  CMP #$F8
  beq next_sprite

	; byte 1, Tile index
	LDA $201, Y
	STA SNES_OAM_START + 2, y
	; beq empty_sprite

	; byte 3, Tile X Position
	LDA $203, Y
	STA SNES_OAM_START, y 

	; properties
	LDA $202, Y
	PHA
	AND #$03
	ASL A
	STA SPRITE_LOOP_JUNK
	PLA
	AND #$F0
	EOR #%00110000
	ORA SPRITE_LOOP_JUNK
	; LDA #%00010010

	STA SNES_OAM_START + 3, y
	; bra next_sprite

	next_sprite:
	INY
	INY
	INY
	INY
	CPY #$100
	BNE sprite_loop

  setAXY8
  PLA
  STA SPRITE_LOOP_JUNK
  STZ SNES_OAM_TRANSLATE_NEEDED
	rtl

dma_oam_table_long:
  JSR dma_oam_table
  RTL

dma_oam_table:
  STZ OAMADDL
  STZ OAMADDH
  LDA #<OAMDATA
  STA BBAD2
  LDA #$A0
  STA A1B2

  STZ DMAP2
  LDA #>SNES_OAM_START
  STA A1T2H
  LDA #<SNES_OAM_START
  STA A1T2L
  LDA #$02
  STA DAS2H
  LDA #$20
  STA DAS2L
  LDA DMA_ENABLED_STATE
  ORA #$04
  STA MDMAEN

  INC SNES_OAM_TRANSLATE_NEEDED
  RTS

zero_oam:

  setXY16
  ldx #$0000

: stz SNES_OAM_START, x
  lda #$f0
  STA SNES_OAM_START + 1, x
  STZ SNES_OAM_START + 2, x
  STZ SNES_OAM_START + 3, x
  INX
  INX
  INX
  INX
  CPX #$200
  bne :-
: stz SNES_OAM_START, X
  inx
  CPX #$220
  bne :-
  setAXY8
  RTS
