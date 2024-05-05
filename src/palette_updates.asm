write_8_palette_entries_from_f1b6:
  LDA $02
  PHA
  LDA $03
  PHA

  LDA #$F1
  STA $03
  LDA #$B6
  STA $02

  LDA #$08
  STA PALETTE_ENTRY_CNT
  JSL write_palette_data

  pla
  STA $03
  pla
  sta $02

  rtl



write_palette_data:
  PHB
  PHX
  PHY
  PHA

  setAXY8
  LDA #$A0
  
  PHA
  PLB
  LDY #$00
  LDA PALETTE_OFFSET
  ASL
  ASL
  ASL
  STA PALETTE_OFFSET
  STA CGADD
  STA CURR_PALETTE_ADDR


  ; DD stores the current palettes at ($02),Y


  ; lookup our 2 byte color from palette_lookup, color * 2
  ; Our palettes are written by writing to CGDATA
palette_entry:
  LDA ($02), Y
  ASL A
  TAX
  LDA palette_lookup, X
  STA CGDATA
  LDA palette_lookup + 1, X
  STA CGDATA
  INY
  ; every 4 we need to write a bunch of empty palette entries
  TYA
  AND #$03
  BNE skip_writing_three_rows

  CLC
  LDA CURR_PALETTE_ADDR
  ADC #$10
  STA CGADD
  STA CURR_PALETTE_ADDR

skip_writing_three_rows:
  TYA
  AND #$0F
  CMP #$00
  BNE skip_writing_four_empties
  ; after 16 entries we write an empty set of palettes
  CLC
  LDA CURR_PALETTE_ADDR
  ADC #$40
  STA CGADD
  STA CURR_PALETTE_ADDR 

skip_writing_four_empties:
  CPY PALETTE_ENTRY_CNT
  BNE palette_entry


  PLA
  PLY  
  PLX
  PLB

  RTL
  



zero_all_palette:
  LDY #$00
  LDX #$02

  STZ CGADD

: STZ CGDATA
  DEY
  BNE :-
  DEX
  BNE :-

  RTS

snes_sprite_palatte:
; .byte $D6, $10, $FF, $7F, $D6, $10, $00, $00, $91, $29, $CE, $39, $5B, $29, $35, $3A
; .byte $77, $46, $B5, $56, $B9, $4E, $FB, $56, $3D, $5F, $7B, $6F, $FC, $7F, $FF, $7F
.byte $1F, $00, $FF, $7F, $53, $08, $00, $00, $91, $29, $CE, $39, $5B, $29, $35, $3A
.byte $77, $46, $B5, $56, $B9, $4E, $FB, $56, $3D, $5F, $7B, $6F, $D7, $18, $FF, $7F
write_default_palettes:
  LDA #$80
  sta CGADD
  LDY #$00
: LDA snes_sprite_palatte, y
  STA CGDATA
  INY
  CMP #$20
  BNE :-
  rts