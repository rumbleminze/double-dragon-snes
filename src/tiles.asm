; This is used for bankswapping CHR Rom banks quickly by putting various banks
; at places in VRAM and changing where the BG tiles are loaded from
bankswap_table:
.byte .lobyte(chrom_bank_0_tileset_0),  .hibyte(chrom_bank_0_tileset_0), $A8
.byte .lobyte(chrom_bank_0_tileset_1),  .hibyte(chrom_bank_0_tileset_1), $A8
.byte .lobyte(chrom_bank_0_tileset_2),  .hibyte(chrom_bank_0_tileset_2), $A8
.byte .lobyte(chrom_bank_0_tileset_3),  .hibyte(chrom_bank_0_tileset_3), $A8

.byte .lobyte(chrom_bank_1_tileset_4),  .hibyte(chrom_bank_1_tileset_4), $A9
.byte .lobyte(chrom_bank_1_tileset_5),  .hibyte(chrom_bank_1_tileset_5), $A9
.byte .lobyte(chrom_bank_1_tileset_6),  .hibyte(chrom_bank_1_tileset_6), $A9
.byte .lobyte(chrom_bank_1_tileset_7),  .hibyte(chrom_bank_1_tileset_7), $A9

.byte .lobyte(chrom_bank_2_tileset_8),  .hibyte(chrom_bank_2_tileset_8), $AA
.byte .lobyte(chrom_bank_2_tileset_9),  .hibyte(chrom_bank_2_tileset_9), $AA
.byte .lobyte(chrom_bank_2_tileset_10), .hibyte(chrom_bank_2_tileset_10), $AA
.byte .lobyte(chrom_bank_2_tileset_11), .hibyte(chrom_bank_2_tileset_11), $AA

.byte .lobyte(chrom_bank_3_tileset_12), .hibyte(chrom_bank_3_tileset_12), $AB
.byte .lobyte(chrom_bank_3_tileset_13), .hibyte(chrom_bank_3_tileset_13), $AB
.byte .lobyte(chrom_bank_3_tileset_14), .hibyte(chrom_bank_3_tileset_14), $AB
.byte .lobyte(chrom_bank_3_tileset_15), .hibyte(chrom_bank_3_tileset_15), $AB

.byte .lobyte(chrom_bank_4_tileset_16), .hibyte(chrom_bank_4_tileset_16), $AC
.byte .lobyte(chrom_bank_4_tileset_17), .hibyte(chrom_bank_4_tileset_17), $AC
.byte .lobyte(chrom_bank_4_tileset_18), .hibyte(chrom_bank_4_tileset_18), $AC
.byte .lobyte(chrom_bank_4_tileset_19), .hibyte(chrom_bank_4_tileset_19), $AC

.byte .lobyte(chrom_bank_5_tileset_20), .hibyte(chrom_bank_5_tileset_20), $AD
.byte .lobyte(chrom_bank_5_tileset_21), .hibyte(chrom_bank_5_tileset_21), $AD
.byte .lobyte(chrom_bank_5_tileset_22), .hibyte(chrom_bank_5_tileset_22), $AD
.byte .lobyte(chrom_bank_5_tileset_23), .hibyte(chrom_bank_5_tileset_23), $AD

.byte .lobyte(chrom_bank_6_tileset_24), .hibyte(chrom_bank_6_tileset_24), $AE
.byte .lobyte(chrom_bank_6_tileset_25), .hibyte(chrom_bank_6_tileset_25), $AE
.byte .lobyte(chrom_bank_6_tileset_26), .hibyte(chrom_bank_6_tileset_26), $AE
.byte .lobyte(chrom_bank_6_tileset_27), .hibyte(chrom_bank_6_tileset_27), $AE

.byte .lobyte(chrom_bank_7_tileset_28), .hibyte(chrom_bank_7_tileset_28), $AF
.byte .lobyte(chrom_bank_7_tileset_29), .hibyte(chrom_bank_7_tileset_29), $AF
.byte .lobyte(chrom_bank_7_tileset_30), .hibyte(chrom_bank_7_tileset_30), $AF
.byte .lobyte(chrom_bank_7_tileset_31), .hibyte(chrom_bank_7_tileset_31), $AF

; bank #$20, my basic intro tiles
.byte <(basic_intro_tiles), >(basic_intro_tiles), $B0


.define WILLIAM       $00
.define ROPER_BARREL  $01
.define LINDA         $02
.define ROPER_BOX     $03
.define CHIN          $04
.define ABOBO         $05
.define SHADOW_BOSS   $06
.define GF_INTRO      $07
.define OBSTACLES     $08

level_tile_initial_loads:
; Intro
.byte WILLIAM, LINDA, ROPER_BARREL, ROPER_BOX, ABOBO, GF_INTRO
; 0 - 0: first part of lvl 1
; 0 - 1: 2nd part of lvl 1 - same as first part
; 1 - 0: All of Level 2 - CHIN instead of GF
.byte WILLIAM, LINDA, ROPER_BARREL, ROPER_BOX, ABOBO, CHIN

; 2 - 0: lvl 3 Forest
; 2 - 1: lvl 3 Cave 1
; 2 - 2: lvl 3 Cave 2
; 2 - 3: lvl 3 Outside Fortress
; 3 - 0: lvl 4 first part
; 3 - 1: lvl 4 platforming section
.byte WILLIAM, LINDA, OBSTACLES, ROPER_BOX, ABOBO, CHIN

; 3 - 2: lvl 4 gauntlet
.byte WILLIAM, LINDA, SHADOW_BOSS, ROPER_BOX, ABOBO, CHIN
; 3 - 3: lvl 4 ending

check_for_initial_obj_loads:
  LDA $3D
  ASL
  ASL
  ASL
  ASL
  ORA $3E
  CMP CURRENT_LVL_OBJ_LOAD
  BNE :+
  RTL
: STA CURRENT_LVL_OBJ_LOAD
  CMP #$00
  BEQ load_initial
  CMP #$10
  BEQ load_lvl_2
  CMP #$20
  BEQ load_lvl_3
  CMP #$31
  BEQ load_lvl_4_guantlet
  RTL

load_initial:
  LDY #$00
  BRA load_6_obj_banks
load_lvl_2:
  LDY #$06
  BRA load_6_obj_banks
load_lvl_3:
  LDY #$0C
  BRA load_6_obj_banks
load_lvl_4_guantlet:
  LDY #$12
  BRA load_6_obj_banks

load_6_obj_banks:
  PHB
  PHK
  PLB
  STZ NMITIMEN
  LDX #$06
: LDA level_tile_initial_loads, Y
  STA CHR_BANK_BANK_TO_LOAD
  PHY
  jslb bankswitch_obj_chr_data, $a0
  PLY
  INY
  DEX
  BNE :-
: LDA RDNMI
  BPL :-
  LDA RDNMI
  LDA NMITIMEN_STATE
  STA NMITIMEN
  PLB
  RTL

: RTL
check_for_bg_chr_bankswap:
  LDA BG_CHR_BANK_SWITCH
  CMP #$FF
  BEQ :-

;   CMP #$1A
;   BPL swap_data_bg_chr

  CMP BG_CHR_BANK_CURR
  BEQ :-

bankswap_start:
  PHA
  PHY
  PHX 
  LDA NMITIMEN_STATE
  AND #$7F
  STA NMITIMEN
  
  LDA INIDISP_STATE
  ORA #$80
  STA INIDISP

  ; LDA RDNMI
: LDA RDNMI
  AND #$80
  BEQ :-
  
  LDA BG_CHR_BANK_SWITCH
  STA BG_CHR_BANK_CURR

  PHB
  LDA #$A0
  PHA
  PLB

  ; looks like we need to switch CHR Banks
  ; we fake this by DMA'ing tiles from the right tileset
  ; multiply by 3 to get the offset
  LDA BG_CHR_BANK_CURR
  ASL A
  ADC BG_CHR_BANK_CURR
  TAY

  LDA #$80
  STA VMAIN

  LDA #$01
  STA DMAP1

  LDA #$18
  STA BBAD1

  ; source LB
  LDA bankswap_table, Y
  STA A1T1L

  ; source HB
  INY
  LDA bankswap_table, y
  STA A1T1H

  ; source DB
  INY
  LDA bankswap_table, y
  STA A1B1

  ; 0x2000 bytes
  LDA #$20
  STA DAS1H
  STZ DAS1L

  ; page 2 is at $1000, data bank will add 6000 to that
  LDA #$10
  ADC TARGET_BANK_OFFSET
  STA VMADDH
  STZ VMADDL
  STZ TARGET_BANK_OFFSET

  LDA DMA_ENABLED_STATE
  ORA #$02
  STA MDMAEN
  PLB
  LDA VMAIN_STATE
  STA VMAIN

  LDA INIDISP_STATE
  STA INIDISP

  LDA NMITIMEN_STATE
  STA NMITIMEN

  ; LDA #$11
  ; STA TM
  ; LDA INIDISP_STATE
  ; STA INIDISP
  PLX
  PLY
  PLA
  
  RTL

bankswitch_obj_chr_data:
  PHB
  LDA #$A0
  PHA
  PLB

  LDY #$00
: CPY #$01
  BEQ skip_bg_vram
  CPY #$02
  BEQ skip_bg_vram
  LDA CHR_BANK_LOADED_TABLE, y
  CMP CHR_BANK_BANK_TO_LOAD
  BEQ switch_to_y
  CPY #$07
  BEQ new_obj_bank
skip_bg_vram:
  INY
  BRA :-

new_obj_bank:
  LDA INIDISP_STATE
  ORA #$80
  STA INIDISP

  LDA CHR_BANK_BANK_TO_LOAD
  TAY
  LDA target_obj_banks, Y
  STA CHR_BANK_TARGET_BANK
  PHA
  jslb load_chr_table_to_vm, $a0

; sometimes there's additional logic.  for Super Dodgeball
; banks 0a - 19 always loaded with 17
;
; this is between 0A and 19, so we load 17 too
;   LDA #$17
;   STA CHR_BANK_BANK_TO_LOAD
;   LDA #$04
;   STA CHR_BANK_TARGET_BANK
;   jsl load_chr_table_to_vm

; : 
  LDA INIDISP_STATE
  STA INIDISP
  PLA
  TAY
  bra switch_to_y

switch_to_y:
  ; our target bank is loaded at #$y000
  ; so just update our obj definition to use that for sprites
  TYA
  STZ OBJ_CHR_HB
  CLC
  LSR ; for updating obsel, we have to halve y.  
  BCC :+
  INC OBJ_CHR_HB
: STA OBSEL
  PLB
  RTL


load_chr_table_to_vm:
  LDA CHR_BANK_TARGET_BANK
  TAY
  LDA CHR_BANK_BANK_TO_LOAD
  STA CHR_BANK_LOADED_TABLE, Y
  
  JSR dma_chr_to_vm

  RTL

dma_chr_to_vm:
  PHB
  LDA #$A0
  PHA
  PLB

  ; looks like we need to switch CHR Banks
  ; we fake this by DMA'ing tiles from the right tileset
  ; multiply by 3 to get the offset
  LDA CHR_BANK_BANK_TO_LOAD
  ASL A
  ADC CHR_BANK_BANK_TO_LOAD
  TAY

  LDA #$80
  STA VMAIN

  LDA #$01
  STA DMAP1

  LDA #$18
  STA BBAD1

  ; source LB
  LDA bankswap_table, Y
  STA A1T1L

  ; source HB
  INY
  LDA bankswap_table, y
  STA A1T1H

  ; source DB
  INY
  LDA bankswap_table, y
  STA A1B1

  ; 0x2000 bytes
  LDA #$20
  STA DAS1H
  STZ DAS1L

  ; 
  LDA CHR_BANK_TARGET_BANK
  ASL
  ASL
  ASL
  ASL
  STA VMADDH
  STZ VMADDL

  LDA DMA_ENABLED_STATE
  ORA #$02
  STA MDMAEN
  PLB
  LDA VMAIN_STATE
  STA VMAIN

  RTS

write_default_tilesets:
    LDA #WILLIAM
    JSR load_bank_to_default_slot    
    LDA #ROPER_BOX
    JSR load_bank_to_default_slot
    LDA #GF_INTRO
    JSR load_bank_to_default_slot
    LDA #LINDA
    JSR load_bank_to_default_slot
    LDA #ABOBO
    JSR load_bank_to_default_slot
    LDA #ROPER_BARREL
    JSR load_bank_to_default_slot
        
    RTS

load_bank_to_default_slot:
    STA CHR_BANK_BANK_TO_LOAD
    TAY
    LDA target_obj_banks, Y
    STA CHR_BANK_TARGET_BANK
    JSL load_chr_table_to_vm
    RTS

; todo update
; which bank we should swap the sprite into, 00 - 0A aren't sprites so we set it to 0
; we only use 00, 10, and 11 for sprite locations, which are 00, 04, and 06
; if they're all the same it'll not save any time when swapping banks.
target_obj_banks:
.byte $00 ; 00 - Sprites William
.byte $07 ; 01 - Sprites Roper w/barrel
.byte $05 ; 02 - Sprites Linda
.byte $03 ; 03 - Sprites Roper w/box
.byte $04 ; 04 - Sprites Chin
.byte $06 ; 05 - Sprites Abobo

.byte $07 ; 06 - Sprites Shadow Boss
.byte $04 ; 07 - Sprites Girlfriend/Intro
.byte $07 ; 08 - Sprites Obstacles

.byte $00 ; 09 - Sprites mode b
.byte $00 ; 0A - Sprites mode b
.byte $00 ; 0B - Sprites
.byte $04 ; 0C - Sprites
.byte $06 ; 0D - Sprites / Letters
.byte $06 ; 0E - Sprites / Letters
.byte $06 ; 0F - Sprites / Letters
.byte $00 ; 10 - BG Tiles
.byte $00 ; 11 - BG Tiles
.byte $00 ; 12 - BG Tiles
.byte $00 ; 13 - BG Tiles
.byte $00 ; 14 - BG Tiles
.byte $00 ; 15 - BG Tiles
.byte $00 ; 16 - BG Tiles
.byte $00 ; 17 - BG Tiles
.byte $00 ; 18 - BG Tiles
.byte $00 ; 19 - BG Tiles
.byte $00 ; 1A - BG Tiles
.byte $00 ; 1B - BG Tiles
.byte $00 ; 1C - BG Tiles
.byte $00 ; 1D - BG Tiles
.byte $00 ; 1E - BG Tiles
.byte $00 ; 1F - BG Tiles
.byte $00 ; 20 - intro bg tiles
.byte $00 ; 21 - fancy intro tiles
.byte $00 ; 22 - more fancy intro tiles


