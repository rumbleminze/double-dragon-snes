infidelitys_scroll_handling:

  LDA PPU_CONTROL_STATE
  PHA 
  AND #$80
  BNE :+
  LDA #$00
  BRA :++
: LDA #$80
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

; used where we just want to set the scroll to 0,0 and not worry about 
; attributes, because they'll naturally be offscreen
simple_scrolling:
  LDA #$08
  STA BG1VOFS
  LDA #$01
  STA BG1VOFS
  STZ BG1HOFS
  STZ BG1HOFS
  STZ SCROLL_HDMA_START
  STZ SCROLL_HDMA_START + 1
  STZ SCROLL_HDMA_START + 2
  RTL

mode_b_scrolling_update:
  LDA $3E
  AND #$FF
  BNE simple_scrolling

  LDA #$10
  ; STA BG1VOFS
  ; STZ BG1VOFS
  LDA #111
  STA SCROLL_HDMA_START
  LDA #80
  STA SCROLL_HDMA_START + 5
  LDA #48
  STA SCROLL_HDMA_START + 10
  LDA #01
  STA SCROLL_HDMA_START + 15
  ; end
  STZ SCROLL_HDMA_START + 20

  ; h-offset lobytes
  LDA HOFS_LB
  STA SCROLL_HDMA_START + 1  
  STA SCROLL_HDMA_START + 6
  STZ SCROLL_HDMA_START + 11
  ; STA BG1HOFS
  
  ; h-offset hibytes
  LDA HOFS_HB
  STA SCROLL_HDMA_START + 2  
  STA SCROLL_HDMA_START + 7  
  STA SCROLL_HDMA_START + 12
  ; STA BG1HOFS

  ; v-offset lo
  STZ SCROLL_HDMA_START + 3  
  STZ SCROLL_HDMA_START + 8  
  LDA #$10
  STA SCROLL_HDMA_START + 13

  ; v-offset hi
  STZ SCROLL_HDMA_START + 4  
  STZ SCROLL_HDMA_START + 9
  STZ SCROLL_HDMA_START + 14

  ; at line 191 we want to set HOFS to 0 and VOFS to be 16
  STZ SCROLL_HDMA_START + 16
  STZ SCROLL_HDMA_START + 17
  LDA #$10
  STA SCROLL_HDMA_START + 18
  STA SCROLL_HDMA_START + 19

  LDA #$7E
  STA A1B3
  LDA #>(SCROLL_HDMA_START)
  STA A1T3H
  STZ A1T3L

  LDA #<(BG1HOFS)
  STA BBAD3

  ;  Write 4 bytes, B0->$21XX, B1->$21XX B2->$21XX+1 B3->$21XX+1
  LDA #$03
  STA DMAP3

  LDA #%00001000
  ORA HDMA_ENABLED_STATE
  STA HDMAEN
  STA HDMA_ENABLED_STATE

  ; LDA HOFS_LB
  ; STA BG1HOFS
  
  ; LDA HOFS_HB
  ; STA BG1HOFS

  RTL


default_scrolling_hdma_values:
.byte $6F, $00, $92, $00, $C9, $58, $00, $92, $00, $C9, $27, $00, $00, $00, $01, $00

set_scrolling_hdma_defaults:

  LDA $3D
  AND #$04
  BEQ :+
  LDA $3E
  AND #$01
  BEQ :+
  jmp simple_scrolling

: PHY
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
  LDA $3D
  AND #$04
  BEQ :+
  RTL
: LDX VOFS_LB
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
  INY 
  ; for mode B we want to load 0800, 0001
  LDA $3D
  AND #$04
  BEQ :+
  LDA #$08
  BRA :++
: LDA #$00
:
  STA SCROLL_HDMA_START, Y  
  INY
  LDA #$00
  STA SCROLL_HDMA_START, Y
  INY
  STA SCROLL_HDMA_START, Y

  ; this controls if we use 2000 or 2400 for the hud source
  ; we usually use 2400, but if we're scrolling down then we use 2000  
  LDA $0100
  CMP #$40
  BNE :+
  LDA #$01
  BRA :++
: LDA $3B
  AND #$01
  EOR #$01
  
: INY
  STA SCROLL_HDMA_START, Y

  ; end hdma byte
  LDA #$00
  INY
  STA SCROLL_HDMA_START, Y


  RTL

