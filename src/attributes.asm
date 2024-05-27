; ATTR_PARAM_HB - has HB of VM start
; ATTR_PARAM_LB - has LB of VM start
; ($00), Y has the data.

; this needs to be 2 bytes on the ZP that ideally isn't used.
.define ZP_ADDR_USAGE $50

dd_one_off_update:

  PLA 
  STA STACK_TEMP_STORAGE
  PLA 
  STA STACK_TEMP_STORAGE + 1
  PLA
  STA STACK_TEMP_STORAGE + 2


; original code
  PLA
  STA $1F
  PLA
  STA $1E

  LDA STACK_TEMP_STORAGE + 2
  PHA
  LDA STACK_TEMP_STORAGE + 1
  PHA
  LDA STACK_TEMP_STORAGE
  PHA
  BCC :+
  PHP
  PHX
  PHY
  PHB

  ; our code

  LDY #$07
  LDA ($02), Y
  STA ATTR_NES_VM_ATTR_START + 7

; very ineffecient to redo the whole thing
; but let's see if we get away with it
  LDA #$01
  STA ATTR_NES_HAS_VALUES

  jslb check_and_copy_nes_attribute_buffer_long, $a0

  PLB
  PLY
  PLX
  PLP
:
  rtl

dd_update_row_attributes:
  ; original code from routine @ C784
  ; c7b7
  LDA #$00
  STA $1C

  PHP
  PHA
  PHX
  PHY
  PHB

  LDA $02
  SEC
  SBC #$28
  TAY 

  CMP #$40
  BPL :+
  ; first page of BG calculate LB by adding 80
  CLC
  ADC #$C0
  STA ATTR_NES_VM_ADDR_LB 
  LDA #$23
  STA ATTR_NES_VM_ADDR_HB
  BRA :++

: 
  ; second page of BG calculate LB by adding 40
  CLC
  ADC #$80
  STA ATTR_NES_VM_ADDR_LB
  LDA #$27
  STA ATTR_NES_VM_ADDR_HB

: 
  LDA #$08
  STA ATTR_NES_VM_COUNT

  LDA $0628, Y
  STA ATTR_NES_VM_ATTR_START
  LDA $0629, Y
  STA ATTR_NES_VM_ATTR_START + 1
  LDA $062A, Y
  STA ATTR_NES_VM_ATTR_START + 2
  LDA $062B, Y
  STA ATTR_NES_VM_ATTR_START + 3
  LDA $062C, Y
  STA ATTR_NES_VM_ATTR_START + 4
  LDA $062D, Y
  STA ATTR_NES_VM_ATTR_START + 5
  LDA $062E, Y
  STA ATTR_NES_VM_ATTR_START + 6
  LDA $062F, Y
  STA ATTR_NES_VM_ATTR_START + 7

  LDA #$00
  STA ATTR_NES_VM_ATTR_START + 8

  LDA #$01
  STA ATTR_NES_HAS_VALUES

  jslb check_and_copy_nes_attribute_buffer_long, $a0

  PLB
  PLY
  PLX
  PLA
  PLP
  RTL


dd_update_column_attributes:

  ; original code from C982
  CPX #$1E
  BMI :+
  LDX #$00
  INC $1F
: STX $1E
  DEC $08
  BEQ :+
  RTL

: PHA
  PHX
  PHY

  LDA $1C
  LSR
  LSR
  TAY
  AND #$07
  ORA #$C0
  STA COL_ATTR_VM_LB
  STA COL2_ATTR_VM_LB

  LDA $02
  CMP #$67

  LDA #$23
  STA COL_ATTR_VM_HB

  LDA $0628, Y
  STA COL_ATTR_VM_START
  LDA $0630, Y
  STA COL_ATTR_VM_START + 1
  LDA $0638, Y
  STA COL_ATTR_VM_START + 2
  LDA $0640, Y
  STA COL_ATTR_VM_START + 3
  LDA $0648, Y
  STA COL_ATTR_VM_START + 4
  LDA $0650, Y
  STA COL_ATTR_VM_START + 5
  LDA $0658, Y
  STA COL_ATTR_VM_START + 6
  LDA $0660, Y
  STA COL_ATTR_VM_START + 7

  LDA #$27
  STA COL2_ATTR_VM_HB
  LDA $0668, Y
  STA COL2_ATTR_VM_START
  LDA $0670, Y
  STA COL2_ATTR_VM_START + 1
  LDA $0678, Y
  STA COL2_ATTR_VM_START + 2
  LDA $0680, Y
  STA COL2_ATTR_VM_START + 3
  LDA $0688, Y
  STA COL2_ATTR_VM_START + 4
  LDA $0690, Y
  STA COL2_ATTR_VM_START + 5
  LDA $0698, Y
  STA COL2_ATTR_VM_START + 6
  LDA $06A0, Y
  STA COL2_ATTR_VM_START + 7


  LDA #$01
  STA COL_ATTR_HAS_VALUES
  STA COL2_ATTR_HAS_VALUES

  jslb check_and_copy_column_attributes_to_buffer, $a0

  PLY
  PLX
  PLA
  INC $08
  DEC $08
  RTL



full_attribute_copy_from_0628:
  PHX
  PHY
  PHA
  
  LDA #$40
  STA ATTR_NES_VM_COUNT

  LDA #$23
  STA ATTR_NES_VM_ADDR_HB
  LDA #$C0
  STA ATTR_NES_VM_ADDR_LB
  LDY #$00
: LDA $0628, Y
  STA ATTR_NES_VM_ATTR_START, Y
  INY
  CPY #$40
  BNE :-

  LDA #$01
  STA ATTR_NES_HAS_VALUES
  jslb convert_nes_attributes_and_immediately_dma_them, $a0

  ; do 2nd page
  LDA #$27
  STA ATTR_NES_VM_ADDR_HB
  LDA #$C0
  STA ATTR_NES_VM_ADDR_LB
  LDA #$40
  STA ATTR_NES_VM_COUNT
  LDY #$00
: LDA $0668, Y
  STA ATTR_NES_VM_ATTR_START, Y
  INY
  CPY #$40
  BNE :-
  LDA #$01
  STA ATTR_NES_HAS_VALUES
  jslb convert_nes_attributes_and_immediately_dma_them, $a0

  PLA
  PLY
  PLX

  RTL


attr_18_palette_01s:
.byte $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
.byte $04, $04, $04, $04, $04, $04, $04, $04

set_bottom_3_rows_of_attributes_to_55:
  LDA #$80
  STA VMAIN

  ; fixed A value, increment B
  setAXY16

  LDA #$0009
  sta DMAP0

  LDA #$2660
  STA VMADDL

  LDA #$19
  STA BBAD0

  LDA #$A0
  STA A1B0

  setAXY8
  LDA #>attr_18_palette_01s
  STA A1T0H
  LDA #<attr_18_palette_01s
  STA A1T0L
  setAXY16

  LDA #$300
  STA DAS0L

  setAXY8
  LDA DMA_ENABLED_STATE
  ORA #$01
  STA MDMAEN

  LDA VMAIN_STATE
  STA VMAIN
  RTS

rewrite_c25a:
  STA $16
  TAY
  LDA $C20D,Y
  TAX
  LDA $C226,Y
  STA $04F4
  LDA $C240,Y
  AND #$0F
  INC A
  ORA #$A0
  STA 5, s
;  JSR $FEEE
  CPY #$10
  BNE :+
  LDA #$1E
  JSR $FE76
  BRA :+


; A rewrite of the tile/attribute writing code
; which allows me to split out the attribute writes
; we need to intentionally keep the DB set to where
; we came from so that reads work.
write_tile_and_attribute_rewrite:
  LDA $50
  PHA
  LDA $51
  PHA
:
  LDA $8000,X
  STA $21
  LDA $8001,X
  STA $22
rw_c280:
  LDY #$00
  LDA ($21),Y
  CMP #$00
  BNE rw_c2c8
  INY
  LDA ($21),Y
  CMP #$00
  BNE rw_c2a5
  LDA $16
  CMP #$05
  BMI :+
  CMP #$0D
  BPL :+
  CLC
  ADC #$0C
  JMP rewrite_c25a  
: PLA
  STA $51
  PLA
  STA $50
  RTL


; c2a5
rw_c2a5:
  PHA
  LDA ATTR_NES_HAS_VALUES
  BEQ :+
  PHB
  jslb convert_nes_attributes_and_immediately_dma_them, $a0
  PLB
:
  STZ ATTR_VM_DATA_MAYBE_ATTR
  STZ ATTR_NES_VM_COUNT
  PLA

  jslb store_vmaddh_to_proper_range, $a0 ; STA VMADDH ; PpuAddr_2006
  ; store as ATTR HB in case it's attributes
  STA ATTR_NES_VM_ADDR_HB
  AND #$03
  CMP #$03
  BNE :+
    INC ATTR_VM_DATA_MAYBE_ATTR
: INY
  LDA ($21),Y
  STA VMADDL ; PpuAddr_2006
  STA ATTR_NES_VM_ADDR_LB
  CMP #$BF
  BCC :+
  INC ATTR_VM_DATA_MAYBE_ATTR   
: 
  LDA ATTR_VM_DATA_MAYBE_ATTR
  AND #$02
  BEQ :+
    INC ATTR_NES_HAS_VALUES
    LDA #<ATTR_NES_VM_ATTR_START
    STA $50
    LDA #>ATTR_NES_VM_ATTR_START
    STA $51
:
  INY
  LDA ($21),Y
  ASL A
  ASL A
  STA $15
  
; set VM Write Increment to 1
  jslb set_vram_increment_based_on_a_and_store, $a0
  LDA #$04
  JSR rw_c2ec
  JMP rw_c280

rw_c2c8:
  STA $05
  INY
  LDA ($21),Y
  STA $08
  LDA #$02
  JSR rw_c2ec
: LDY #$00
: LDA ($21),Y

  PHA
  LDA ATTR_VM_DATA_MAYBE_ATTR
  AND #$02
  BEQ :+
  PLA
  jsr store_to_attr_cache 
  BRA :++
: PLA
  STA VMDATAL ; PpuData_2007

: INY
  CPY $08
  BNE :---
  DEC $05
  BNE :----
  LDA $08
  JSR rw_c2ec
  JMP rw_c280
  
rw_c2ec:
  CLC
  ADC $21
  STA $21
  LDA $22
  ADC #$00
  STA $22
  RTS


store_to_attr_cache:
  STA ($50)
  INC ATTR_NES_VM_COUNT
  INC $50
  BNE :+
  INC $51
: PHA
  LDA #$00
  STA ($50)
  PLA
  RTS
 

check_and_copy_attribute_buffer:
  LDA ATTRIBUTE_DMA
  BEQ :+
  JSR copy_prepped_attributes_to_vram
: 
;   LDA ATTRIBUTE2_DMA
;   BEQ :+
;   JSR copy_prepped_attributes2_to_vram
; : 
  LDA COLUMN_1_DMA
  BEQ :+
  JSR dma_column_attributes
: 
  LDA COLUMN_2_DMA
  BEQ :+
  JSR dma_column2_attributes
 : 
  RTS

check_and_copy_dma_buffers_long:
  JSR check_and_copy_attribute_buffer
  RTL

copy_single_prepped_attribute:
  LDA ZP_ADDR_USAGE
  PHA
  LDA ZP_ADDR_USAGE + 1
  PHA

  LDA #$80
  STA VMAIN

  LDA ATTR_DMA_VMADDH
  STA VMADDH
  LDA ATTR_DMA_VMADDL
  STA VMADDL

  LDA ATTR_DMA_SRC_LB
  STA ZP_ADDR_USAGE
  LDA ATTR_DMA_SRC_HB
  STA ZP_ADDR_USAGE + 1

  LDX #$04
: LDY #$00
: LDA (ZP_ADDR_USAGE), y
  STA VMDATAH
  INY
  CPY #$04
  BNE :-

  LDA ZP_ADDR_USAGE
  CLC
  ADC #$20
  STA ZP_ADDR_USAGE

  LDA ATTR_DMA_VMADDL
  CLC
  ADC #$20
  STA ATTR_DMA_VMADDL
  BCC :+
  INC ATTR_DMA_VMADDH
: LDA ATTR_DMA_VMADDH
  STA VMADDH
  LDA ATTR_DMA_VMADDL
  STA VMADDL

  DEX  
  BNE :---

  jslb reset_vmain_to_stored_state, $a0

  PLA
  STA ZP_ADDR_USAGE + 1
  PLA
  STA ZP_ADDR_USAGE

  RTS

copy_prepped_attributes_to_vram:
  STZ ATTRIBUTE_DMA
  ; check for a single value
  LDA ATTR_DMA_SIZE_HB
  BNE :+
  LDA ATTR_DMA_SIZE_LB
  BNE :+
  RTS
; : CMP #$10
;   BNE :+
;   JMP copy_single_prepped_attribute

; : 
: LDA #$80
  STA VMAIN
  STZ DMAP6
  LDA #$19
  STA BBAD6
  ; LDX #$00
  LDA #$7E
  STA A1B6
  LDA ATTR_DMA_SRC_HB ; ,X
  STA A1T6H
  LDA ATTR_DMA_SRC_LB ; ,X
  STA A1T6L
  LDA ATTR_DMA_SIZE_LB ;,X
  ; CMP #$80
  ; BMI handle_partials
  BRA handle_full
handle_partials:
  JSR copy_partial_prepped_attributes_to_vram
  BRA :+
handle_full: 
  STA DAS6L
  LDA ATTR_DMA_SIZE_HB
  STA DAS6H
  LDA ATTR_DMA_VMADDH
  STA VMADDH
  LDA ATTR_DMA_VMADDL
  STA VMADDL
  LDA DMA_ENABLED_STATE
  ORA #$40
  STA MDMAEN
: DEC ATTRIBUTE_DMA + 1
  LDA ATTRIBUTE_DMA + 1
  BPL :-
  LDY #$0F
  LDA #$00
: STA ATTRIBUTE_DMA,Y
  DEY
  BPL :-
  LDA #$FF
  STA ATTRIBUTE_DMA + 1
  
  LDA VMAIN_STATE
  STA VMAIN
  RTS

copy_partial_prepped_attributes_to_vram:

; these are the same for all of them

  LDA #$7E
  STA A1B6

partial_row_loop:
  LDA ATTR_DMA_SIZE_LB
  LSR
  LSR
  STA DAS6L
  LDA #$00
  STA DAS6H
  LDA ATTR_DMA_SRC_LB
  CLC
  ADC ATTR_PARTIAL_CURR_OFFSET
  BCC :+
  ; rollover, bump up HB
  INC ATTR_DMA_SRC_HB
: STA A1T6L
  
  LDA ATTR_DMA_SRC_HB
  STA A1T6H  

  LDA ATTR_DMA_VMADDL
  CLC
  ADC ATTR_PARTIAL_CURR_OFFSET 
  BCC :+
  INC ATTR_DMA_VMADDH
: STA VMADDL

  LDA ATTR_DMA_VMADDH
  STA VMADDH
  
  LDA DMA_ENABLED_STATE
  ORA #$40
  STA MDMAEN

  LDA ATTR_PARTIAL_CURR_OFFSET
  ADC #$20
  STA ATTR_PARTIAL_CURR_OFFSET
  CMP #$80
  BMI partial_row_loop
  STZ ATTR_PARTIAL_CURR_OFFSET
  RTS

disable_attribute_buffer_copy:
  STZ ATTR_NES_VM_ADDR_HB
  STZ ATTR_NES_HAS_VALUES
  ; STZ ATTR_DMA_SIZE_LB
  RTS


attr_lookup_table_1_inf_9450:
.byte $00, $04, $08, $0C, $10, $14, $18, $1C, $80, $84, $88, $8C, $90, $94, $98, $9C

inf_95AE:
.byte $EA, $A1 
inf_95B0:
.byte $00, $D0, $06, $A9, $FF, $8D, $F0, $17, $6B, $4C, $20, $97, $00, $00, $01, $01
attr_lookup_table_2_inf_95C0:
.byte $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02, $00
.byte $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0, $00
.byte $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0, $00

convert_nes_attributes_and_immediately_dma_them:
  PHY
  PHA
  PHX
  LDA ATTR_WORK_BYTE_0
  PHA
  LDA ATTR_WORK_BYTE_1
  PHA
  LDA ATTR_WORK_BYTE_2
  PHA
  LDA ATTR_WORK_BYTE_3 
  PHA
  JSR check_and_copy_nes_attributes_to_buffer
  ; JSR check_and_copy_column_attributes_to_buffer
  JSR check_and_copy_attribute_buffer
  pla
  sta ATTR_WORK_BYTE_3
  pla
  sta ATTR_WORK_BYTE_2
  pla
  sta ATTR_WORK_BYTE_1
  pla 
  sta ATTR_WORK_BYTE_0
  PLX
  PLA
  PLY
  RTL

check_and_copy_nes_attribute_buffer_long:
  PHY
  PHA
  PHX
  LDA ATTR_WORK_BYTE_0
  PHA
  LDA ATTR_WORK_BYTE_1
  PHA
  LDA ATTR_WORK_BYTE_2
  PHA
  LDA ATTR_WORK_BYTE_3 
  PHA
  LDA ATTR_NES_HAS_VALUES
  BEQ :+
  JSR convert_attributes_inf
: pla
  sta ATTR_WORK_BYTE_3
  pla
  sta ATTR_WORK_BYTE_2
  pla
  sta ATTR_WORK_BYTE_1
  pla 
  sta ATTR_WORK_BYTE_0
  PLX
  PLA
  PLY
  RTL

; converts attributes stored at 9A0 - A07 to attribute cache
check_and_copy_nes_attributes_to_buffer:
  LDA ATTR_NES_HAS_VALUES
  BEQ :+
  JSR convert_attributes_inf
: 
  ; LDA ATTR2_NES_HAS_VALUES
  ; BEQ early_rts_from_attribute_copy
  ; JSR convert_attributes2_inf
early_rts_from_attribute_copy:
  RTS
  
convert_attributes_inf:
  PHK
  PLB
  LDX #$00
  JSR disable_attribute_hdma
  LDA #$A1
  STA ATTR_WORK_BYTE_0
  LDA #$09
  STA ATTR_WORK_BYTE_1
  STZ ATTR_DMA_SRC_LB
  STZ ATTR_DMA_SRC_LB + 1
  LDA #$18
  STA ATTR_DMA_SRC_HB
  LDA #$1A
  STA ATTR_DMA_SRC_HB + 1
  LDY #$00  
inf_9497:
  LDA (ATTR_WORK_BYTE_0),Y ; $00.w is $09A1 to start
  ; early rtl  
  STZ ATTR_NES_HAS_VALUES
  BEQ early_rts_from_attribute_copy
  AND #$03
  CMP #$03
  BEQ :+
  JMP inf_9700
: INY
  LDA (ATTR_WORK_BYTE_0),Y
  AND #$F0
  CMP #$C0
  BEQ :+
  CMP #$D0
  BEQ :+
  CMP #$E0
  BEQ :+
  CMP #$F0
  BEQ :+
  JMP inf_9700 + 1
: JSR inc_attribute_hdma_store_to_x

  LDA (ATTR_WORK_BYTE_0),Y
  PHY
  AND #$0F
  TAY
  LDA attr_lookup_table_1_inf_9450,Y
  PLY
  ; AND #$0F
  ; ASL A
  ; ASL a
  ; ASL a
  ; ASL A
  STA ATTR_DMA_VMADDL,X
  LDA (ATTR_WORK_BYTE_0),Y
  AND #$30
  LSR
  LSR
  LSR
  LSR
  ORA #$20
  XBA
  DEY
  LDA (ATTR_WORK_BYTE_0),Y
  CMP #$24
  BMI :+
  LDA #$00
  XBA
  INC
  INC
  INC
  INC
  STA ATTR_DMA_VMADDH,X
  BRA :++
: LDA #$00
  XBA
  STA ATTR_DMA_VMADDH,X
: INY
  INY
  LDA (ATTR_WORK_BYTE_0),Y
  AND #$0F
  ASL
  ASL
  ASL
  ASL
  ; PHX
  ; TAX
  ; LDA attr_lookup_table_2_inf_95C0 + 15,X
  ; PLX  
  STA ATTR_DMA_SIZE_LB,X
  LDA (ATTR_WORK_BYTE_0),Y
  AND #$F0  
  CMP #$0F
  BPL :+
  LDA #$00
  BRA :++
: AND #$F0
  LSR
  LSR
  LSR
  LSR
  ; PHX
  ; TAX
  ; LDA inf_95AE,X
  ; PLX
: STA ATTR_DMA_SIZE_HB,X
  ; LDA #$80
  ; STA ATTR_DMA_SIZE_LB
  ; STZ ATTR_DMA_SIZE_HB
  LDA (ATTR_WORK_BYTE_0),Y
  STA ATTRIBUTE_DMA + 14
  STA ATTRIBUTE_DMA + 15
  LDA ATTRIBUTE_DMA + 2,X
  sta ATTR_WORK_BYTE_3
  LDA ATTRIBUTE_DMA + 4,X
  sta ATTR_WORK_BYTE_2
  INY
  INY
  TYX
  LDA #$A0
  sta ATTR_WORK_BYTE_0
  TYA
  CLC
  ADC ATTR_WORK_BYTE_0
  sta ATTR_WORK_BYTE_0
  BRA :+
inf_952D:  
  INC ATTR_WORK_BYTE_0
: JSR inf_9680
  NOP
  LDA (ATTR_WORK_BYTE_0,X)
  PHA
  AND #$03
  TAX
  LDA attr_lookup_table_1_inf_9450,X
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDY #$20
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDY #$02
  PLA
  PHA
  AND #$0C
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDY #$22
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDY #$40
  PLA
  PHA
  AND #$30
  LSR
  LSR
  LSR
  LSR
  TAX
  LDA attr_lookup_table_1_inf_9450,X
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDY #$60
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDY #$42
  PLA
  AND #$C0
  LSR
  LSR
  LSR
  LSR
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDY #$62
  STA (ATTR_WORK_BYTE_2),Y
  INY
  STA (ATTR_WORK_BYTE_2),Y
  LDA ATTR_WORK_BYTE_2
  CLC
  ADC #$04
  sta ATTR_WORK_BYTE_2
  CMP #$20
  BEQ :+
  CMP #$A0
  BNE :++
: CLC
  ADC #$60
  sta ATTR_WORK_BYTE_2
  BNE :+
  INC ATTR_WORK_BYTE_3
: DEC ATTRIBUTE_DMA + 14
  LDA ATTRIBUTE_DMA + 14
  BEQ :+
  BRA inf_952D
: JSR inf_9690
  NOP
  LDA (ATTR_WORK_BYTE_0,X)
  BNE inf_95b9

  STZ ATTR_NES_HAS_VALUES
  LDA #$FF
  STA ATTRIBUTE_DMA
  RTS

inf_95b9:
  ; i can't find this getting called, and 9720 looks non-sensical to me
  JMP inf_9720

inc_attribute_hdma_store_to_x:
  INC ATTRIBUTE_DMA + 1
  LDX ATTRIBUTE_DMA + 1
  RTS


disable_attribute_hdma:
  LDA #$FF
  STA ATTRIBUTE_DMA + 1
  STA ATTRIBUTE2_DMA + 1
  RTS

inf_9680:
  LDA ATTR_WORK_BYTE_0
  BNE :+
  INC ATTR_WORK_BYTE_1
: LDX #$00
  LDY #$00
  RTS


inf_9690:
  LDA #$FF
  STA ATTRIBUTE_DMA
  INC ATTR_WORK_BYTE_0
  LDX #$00
  RTS

inf_9700:
  INY
  INY
  LDA ATTR_WORK_BYTE_2
  PHA
  STY ATTR_WORK_BYTE_2
  LDA (ATTR_WORK_BYTE_0),Y
  AND #$3F
  CLC
  ADC ATTR_WORK_BYTE_2
  INC
  TAY
  PLA
  sta ATTR_WORK_BYTE_2
  JMP inf_9497

inf_9720:
  LDA ATTR_WORK_BYTE_2
  PHA
  STZ ATTR_WORK_BYTE_2
: LDA ATTR_WORK_BYTE_0
  CMP #$A1
  BEQ :+
  DEC ATTR_WORK_BYTE_0
  INC ATTR_WORK_BYTE_2
  BRA :-
: LDY ATTR_WORK_BYTE_2
  PLA
  sta ATTR_WORK_BYTE_2
  JMP inf_9497


check_and_copy_column_attributes_to_buffer:
  LDA COL_ATTR_HAS_VALUES
  BEQ :+
  JSR convert_column_of_tiles
: LDA COL2_ATTR_HAS_VALUES
  BEQ :+
  JSR convert_column2_of_tiles
: RTL

convert_column_of_tiles:
  LDA COL_ATTR_VM_HB
  ; early rtl
  BNE :+
  RTS
: LDA COL_ATTR_VM_LB
  AND #$F0
  CMP #$C0
  BEQ :+
  CMP #$D0
  BEQ :+
  CMP #$E0
  BEQ :+
  CMP #$F0
  BEQ :+
  RTS
: 
  ; LDA COL_ATTR_VM_LB
  ; PHY
  ; AND #$0F
  ; TAY
  ; LDA attr_lookup_table_1_inf_9450,Y
  ; PLY
  LDA COL_ATTR_VM_LB
  AND #$0F
  ASL A
  ASL a

  ; ASL a
  ; ASL A  
  STA C1_ATTR_DMA_VMADDL
  LDA COL_ATTR_VM_HB
  AND #$24
  STA C1_ATTR_DMA_VMADDH

  LDA #$20
  STA C1_ATTR_DMA_SIZE_LB
  STZ C1_ATTR_DMA_SIZE_HB

  LDY #$00
  LDX #$00
: LDA COL_ATTR_VM_START, Y

  ; convert magic!
  ; each attribute value gives us 4 attribute values
  ; in a grid of:
  ; 
  ; A A B B
  ; A A B B
  ; C C D D
  ; C C D D
  ;
  ; we'll store them in 4 batches to be DMA'd
  ; and store them in columns, but as rows, get it?
  ; 
  ; column1:  A A C C
  ; column2:  A A C C
  ; column3:  B B D D
  ; column4:  B B D D

  ; magic convert
  ; NES attribues will be in 1 byte, for the above description in this way:
  ; 0xDDCCBBAA
  ; The only thing we care about with Kid icarus is the palette
  ; 
  ; palattes for SNES are put in bits 4, 8 & 16 of the high byte:
  ; we're only useing 4 palattes, so we'll shift things to byte 4, 8 of the low nibble
  ; ___0 00___

  ; get A (TL)
  AND #$03
  ASL
  ASL
  STA C1_ATTRIBUTE_CACHE, X
  STA C1_ATTRIBUTE_CACHE + 1, X
  ; store in UR and LR row
  STA C1_ATTRIBUTE_CACHE + ATTR_WORK_BYTE_0, X
  STA C1_ATTRIBUTE_CACHE + ATTR_WORK_BYTE_1, X

  ; get B (TR), write them as dma lines 3 and 4.
  LDA COL_ATTR_VM_START, Y
  CLC
  AND #$0C
  STA C1_ATTRIBUTE_CACHE + $40, X
  STA C1_ATTRIBUTE_CACHE + $40 + 1, X
  STA C1_ATTRIBUTE_CACHE + $60, X
  STA C1_ATTRIBUTE_CACHE + $60 + 1, X

  ; get C (BL)
  LDA COL_ATTR_VM_START, Y
  CLC
  AND #$30
  LSR A
  LSR A
  STA C1_ATTRIBUTE_CACHE + 2, X
  STA C1_ATTRIBUTE_CACHE + 3, X
  STA C1_ATTRIBUTE_CACHE + ATTR_WORK_BYTE_2, X
  STA C1_ATTRIBUTE_CACHE + ATTR_WORK_BYTE_3, X

  ; get D (BR)
  LDA COL_ATTR_VM_START, Y
  AND #$C0
  LSR A
  LSR A
  LSR A
  LSR A
  STA C1_ATTRIBUTE_CACHE + $40 + 2, X
  STA C1_ATTRIBUTE_CACHE + $40 + 3, X
  STA C1_ATTRIBUTE_CACHE + $60 + 2, X
  STA C1_ATTRIBUTE_CACHE + $60 + 3, X

  INX
  INX
  INX
  INX

  INY
  CPY #$08
  BNE :-

  INC COLUMN_1_DMA
  STZ COL_ATTR_HAS_VALUES
  RTS

; uses DMA channel 2 to copy a buffer of column attributes
dma_column_attributes:
  STZ COLUMN_1_DMA

  ; write vertically for columns
  LDA #$81
  STA VMAIN

  LDX #$04

  LDA #.hibyte(C1_ATTRIBUTE_CACHE)
  STA C1_ATTR_DMA_SRC_HB
  LDA #.lobyte(C1_ATTRIBUTE_CACHE)
  STA C1_ATTR_DMA_SRC_LB

: STZ DMAP6

  LDA #$19
  STA BBAD6

  LDA #$7E
  STA A1B6

  LDA C1_ATTR_DMA_SRC_HB
  STA A1T6H
  LDA C1_ATTR_DMA_SRC_LB
  STA A1T6L

  LDA C1_ATTR_DMA_SIZE_LB
  STA DAS6L
  LDA C1_ATTR_DMA_SIZE_HB
  STA DAS6H

  LDA C1_ATTR_DMA_VMADDH
  STA VMADDH
  LDA C1_ATTR_DMA_VMADDL
  STA VMADDL

  LDA DMA_ENABLED_STATE
  ORA #$40
  STA MDMAEN

  INC C1_ATTR_DMA_VMADDL
  LDA C1_ATTR_DMA_SRC_LB
  CLC
  ADC #$20
  STA C1_ATTR_DMA_SRC_LB
  DEX
  BNE :-

  LDY #$0F
  LDA #$00
: STA COLUMN_1_DMA,Y
  DEY
  BPL :-
  LDA #$FF
  STA COLUMN_1_DMA + 1

  LDA #$80
  STA VMAIN

  RTS

; I'm very lazily copy/pasting this to support multiple column conversion.
convert_column2_of_tiles:
  LDA COL2_ATTR_VM_HB
  ; early rtl
  BNE :+
  RTS
: LDA COL2_ATTR_VM_LB
  AND #$F0
  CMP #$C0
  BEQ :+
  CMP #$D0
  BEQ :+
  CMP #$E0
  BEQ :+
  CMP #$F0
  BEQ :+
  RTS
: 
  LDA COL2_ATTR_VM_LB
  AND #$0F
  ASL A
  ASL a

  STA C2_ATTR_DMA_VMADDL
  LDA COL2_ATTR_VM_HB
  AND #$24
  STA C2_ATTR_DMA_VMADDH

  LDA #$20
  STA C2_ATTR_DMA_SIZE_LB
  STZ C2_ATTR_DMA_SIZE_HB

  LDY #$00
  LDX #$00
: LDA COL2_ATTR_VM_START, Y
  AND #$03
  ASL
  ASL
  STA C2_ATTRIBUTE_CACHE, X
  STA C2_ATTRIBUTE_CACHE + 1, X
  ; store in UR and LR row
  STA C2_ATTRIBUTE_CACHE + ATTR_WORK_BYTE_0, X
  STA C2_ATTRIBUTE_CACHE + ATTR_WORK_BYTE_1, X

  ; get B (TR), write them as dma lines 3 and 4.
  LDA COL2_ATTR_VM_START, Y
  CLC
  AND #$0C
  STA C2_ATTRIBUTE_CACHE + $40, X
  STA C2_ATTRIBUTE_CACHE + $40 + 1, X
  STA C2_ATTRIBUTE_CACHE + $60, X
  STA C2_ATTRIBUTE_CACHE + $60 + 1, X

  ; get C (BL)
  LDA COL2_ATTR_VM_START, Y
  CLC
  AND #$30
  LSR A
  LSR A
  STA C2_ATTRIBUTE_CACHE + 2, X
  STA C2_ATTRIBUTE_CACHE + 3, X
  STA C2_ATTRIBUTE_CACHE + ATTR_WORK_BYTE_2, X
  STA C2_ATTRIBUTE_CACHE + ATTR_WORK_BYTE_3, X

  ; get D (BR)
  LDA COL2_ATTR_VM_START, Y
  AND #$C0
  LSR A
  LSR A
  LSR A
  LSR A
  STA C2_ATTRIBUTE_CACHE + $40 + 2, X
  STA C2_ATTRIBUTE_CACHE + $40 + 3, X
  STA C2_ATTRIBUTE_CACHE + $60 + 2, X
  STA C2_ATTRIBUTE_CACHE + $60 + 3, X

  INX
  INX
  INX
  INX

  INY
  CPY #$08
  BNE :-

  INC COLUMN_2_DMA
  STZ COL2_ATTR_HAS_VALUES
  RTS

dma_column2_attributes:
  STZ COLUMN_2_DMA

  ; write vertically for columns
  LDA #$81
  STA VMAIN

  LDX #$04

  LDA #.hibyte(C2_ATTRIBUTE_CACHE)
  STA C2_ATTR_DMA_SRC_HB
  LDA #.lobyte(C2_ATTRIBUTE_CACHE)
  STA C2_ATTR_DMA_SRC_LB

: STZ DMAP6

  LDA #$19
  STA BBAD6

  LDA #$7E
  STA A1B6

  LDA C2_ATTR_DMA_SRC_HB
  STA A1T6H
  LDA C2_ATTR_DMA_SRC_LB
  STA A1T6L

  LDA C2_ATTR_DMA_SIZE_LB
  STA DAS6L
  LDA C2_ATTR_DMA_SIZE_HB
  STA DAS6H

  LDA C2_ATTR_DMA_VMADDH
  STA VMADDH
  LDA C2_ATTR_DMA_VMADDL
  STA VMADDL

  LDA DMA_ENABLED_STATE
  ORA #$40
  STA MDMAEN

  INC C2_ATTR_DMA_VMADDL
  LDA C2_ATTR_DMA_SRC_LB
  CLC
  ADC #$20
  STA C2_ATTR_DMA_SRC_LB
  DEX
  BNE :-

  LDY #$0F
  LDA #$00
: STA COLUMN_2_DMA,Y
  DEY
  BPL :-
  LDA #$FF
  STA COLUMN_2_DMA + 1

  LDA #$80
  STA VMAIN

  RTS


; X should contain VMADDH
; Y should contain VMADDL
; A should contain VMDATAL
add_extra_vram_update:
  STY VRAM_UPDATE_ADDR_LB
  STX VRAM_UPDATE_ADDR_HB
  STA VRAM_UPDATE_DATA

  LDA EXTRA_VRAM_UPDATE
  ASL A
  ADC EXTRA_VRAM_UPDATE
  INC A
  TAY

  LDA VRAM_UPDATE_ADDR_LB
  STA EXTRA_VRAM_UPDATE, Y

  LDA VRAM_UPDATE_ADDR_HB
  STA EXTRA_VRAM_UPDATE + 1, Y

  LDA VRAM_UPDATE_DATA
  STA EXTRA_VRAM_UPDATE + 2, Y

  INC EXTRA_VRAM_UPDATE
  RTL

write_one_off_vrams:
  
  LDX EXTRA_VRAM_UPDATE
  BEQ :++
  LDY #$00
: LDA EXTRA_VRAM_UPDATE+1, Y
  STA VMADDL  
  INY

  LDA EXTRA_VRAM_UPDATE+1, Y
  STA VMADDH
  INY

  LDA EXTRA_VRAM_UPDATE+1, Y
  STA VMDATAL
  INY

  DEX
  BNE :-  

: STZ EXTRA_VRAM_UPDATE
  RTS


