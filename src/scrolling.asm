reset_to_stored_screen_offsets:
  LDA STORED_OFFSETS_SET
  BEQ :+
  LDA UNPAUSE_BG1_HOFS_LB
  STA HOFS_LB
  LDA UNPAUSE_BG1_HOFS_HB
  STA HOFS_HB
  LDA UNPAUSE_BG1_VOFS_LB
  STA VOFS_LB
  LDA UNPAUSE_BG1_VOFS_HB
  ; STA VOFS_HB

  STZ STORED_OFFSETS_SET
: RTL

no_scroll_screen_enable:
  LDA HOFS_LB
  STA UNPAUSE_BG1_HOFS_LB
  LDA HOFS_HB
  STA UNPAUSE_BG1_HOFS_HB
  LDA VOFS_LB
  STA UNPAUSE_BG1_VOFS_LB
  LDA VOFS_HB
  STA UNPAUSE_BG1_VOFS_HB

  STZ HOFS_LB 
  STZ HOFS_HB 
  STZ VOFS_LB
  STZ VOFS_HB
  INC STORED_OFFSETS_SET
   
  lda PPU_CONTROL_STATE
  AND #$FC                 
  STA PPU_CONTROL_STATE
  RTL 

infidelitys_scroll_handling:
  LDA PPU_CONTROL_STATE
  PHA 
  AND #$80
  BNE :+
  LDA #$01
  BRA :++
: LDA #$81
: STA NMITIMEN
  PLA        
  PHA 
  AND #$04
  ; A now has the BG table address
  BNE :+
  LDA #$00
  BRA :++
: LDA #$01   
: STA VMAIN 
  PLA 
  AND #$03
  BEQ :+
  CMP #$01
  BEQ :++
  CMP #$02
  BEQ :+++
  CMP #$03
  BEQ :++++
: STZ HOFS_HB
  STZ VOFS_HB
  BRA :++++   ; RTL
: LDA #$01
  STA HOFS_HB
  STZ VOFS_HB
  BRA :+++    ; RTL
: STZ HOFS_HB
  LDA #$01
  ; STA VOFS_HB
  BRA :++     ; RTL
: LDA #$01
  STA HOFS_HB
  ; STA VOFS_HB
: RTL 

default_scrolling_hdma_values:
.byte $6F, $00, $92, $00, $C9, $58, $00, $92, $00, $C9, $27, $00, $00, $00, $01, $00

set_scrolling_hdma_defaults:
  PHY
  PHB
  LDA #$A0
  PHA
  PLB
  LDY #$00
: LDA default_scrolling_hdma_values, Y
  CPY #$0f
  BEQ :+
  STA SCROLL_HDMA_START, Y
  INY
  BRA :-

: PLB
  PLY
  RTL

setup_hdma:
  LDX VOFS_LB
  LDA $A0A080,X
  STA SCROLL_HDMA_START + 0
  LDA $A0A170,X
  STA SCROLL_HDMA_START + 3
  LDA $A0A260,X
  STA SCROLL_HDMA_START + 5
  LDA $A0A350,X
  STA SCROLL_HDMA_START + 8
    
  LDA $A0A440,X
  STA SCROLL_HDMA_START + 10
  LDA $A0A520,X
  STA SCROLL_HDMA_START + 13

  LDA HOFS_LB
  STA SCROLL_HDMA_START + 1
  STA SCROLL_HDMA_START + 6
  STA SCROLL_HDMA_START + 11
  LDA PPU_CONTROL_STATE
  STA SCROLL_HDMA_START + 2
  STA SCROLL_HDMA_START + 7
  STA SCROLL_HDMA_START + 12
  LDX PPU_CONTROL_STATE
  LDA $A0A610,X
  STA SCROLL_HDMA_START + 4
  STA SCROLL_HDMA_START + 9
  STA SCROLL_HDMA_START + 14


  LDY #$0A
  LDA SCROLL_HDMA_START
  STA HDMA_LINE_CNT
  
  LDA SCROLL_HDMA_START + 5
  CLC
  ADC HDMA_LINE_CNT
  STA HDMA_LINE_CNT
  SEC
  SBC #199

  BMI :+
    ; hit the end on 2nd one, back it up
    STA HDMA_LINE_CNT
    LDA SCROLL_HDMA_START + 5
    SEC
    SBC HDMA_LINE_CNT
    STA SCROLL_HDMA_START + 5
    BRA write_hud_values
  :

  LDY #$0F
  LDA SCROLL_HDMA_START + 10
  CLC
  ADC HDMA_LINE_CNT
  STA HDMA_LINE_CNT
  SEC
  SBC #199
  BMI :+
    ; hit the end on the 3rd one, back it up
    STA HDMA_LINE_CNT
    LDA SCROLL_HDMA_START + 10
    SEC
    SBC HDMA_LINE_CNT
    STA SCROLL_HDMA_START + 10
    BRA write_hud_values
  :
    ; didn't get to enough lines, we actually have to bump up the last one
    LDA #199
    SBC HDMA_LINE_CNT
    ADC SCROLL_HDMA_START + 10
    STA SCROLL_HDMA_START + 10

write_hud_values:
  LDA #39 ; 40 lines of 0000, 0100
  STA SCROLL_HDMA_START, Y

  LDA #$00
  INY
  STA SCROLL_HDMA_START, Y
  INY
  STA SCROLL_HDMA_START, Y

  INY
  STA SCROLL_HDMA_START, Y

  ; this controls if we use 2000 or 2400 for the hud source
  ; we usually use 2400, but if we're scrolling down then we use 2000  
  LDA $3B
  AND #$01
  EOR #$01
  
  INY
  STA SCROLL_HDMA_START, Y

  LDA #$00
  INY
  STA SCROLL_HDMA_START, Y


  RTL

; copy of 02:AC47
horizontal_attribute_scroll_handle:
  JSR nes_02_ada9_copy
  LDY #$00
  STZ COL_ATTR_VM_COUNT
  STZ COL_ATTR_LB_SET

: INC COL_ATTR_VM_COUNT
  TYA
  ASL A
  ASL A
  ASL A
  CLC
  ADC $00
  STA $03
  CLC
  ADC #$C0
  PHA
  LDA $1B
  EOR #$01
  AND #$01
  ASL A
  ASL A
  ORA #$23  
  PHA
  LDA COL_ATTR_LB_SET
  BNE :+
  PLA
  STA COL_ATTR_VM_HB
  PLA  
  STA COL_ATTR_VM_LB  
  INC COL_ATTR_LB_SET
  BRA :++
: PLA  
  PLA
: LDX $03
  LDA $03B0,X
  STA COL_ATTR_VM_START, Y
  INY
  CPY #$08
  BCC :---
  LDA #$00

  STA COL_ATTR_VM_START, Y
  INC COL_ATTR_HAS_VALUES
  ; would normall do this during screen but for now just do it in line
  JSR convert_column_of_tiles

  RTL

nes_02_ada9_copy:
  LDA #$00
  STA $00
  LDA $FE
  AND #$E0
  ASL A
  ROL $00
  ASL A
  ROL $00
  ASL A
  ROL $00
  RTS
