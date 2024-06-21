augment_input:

    ; origingal code
    LDX $FB
    INX
    STX JOYSER0
    DEX
    STX JOYSER0
    LDX #$08
:   LDA JOYSER0
    LSR
    ROL $F5
    LSR
    ROL $00
    LDA JOYSER1
    LSR
    ROL $F6
    LSR
    ROL $01
    DEX
    BNE :-

    ; we also ready the next bit, which is the SNES "A" button
    ; and if it's on, treat it as if they've hit both Y and B
    lda JOYSER0
    AND #$01
    BEQ :+
    LDA $00
    ORA #$C0
    STA $00

    ; X
    ; lda JOYSER0
    ; lda JOYSER0
    ; AND #$01
    ; BEQ :+


:   
    BRA check_code
    ; debug for testing bank switch stuff
    LDA $F5
    AND #$0F
    BEQ check_code
    CMP #$01
    BEQ handle_right
    CMP #$02
    BEQ handle_left
    CMP #$04
    BEQ handle_up
    CMP #$08
    BEQ handle_down
handle_right:    
    LDA BG_CHR_BANK_CURR
    INC A
    BRA do_bank_switch
handle_left:
    LDA BG_CHR_BANK_CURR
    DEC A
    BRA do_bank_switch
handle_up:
    LDA $05
    INC
    BRA do_obj_bank_switch
handle_down:    
    LDA $05
    DEC A
    BPL :+
    LDA #$00
:   BRA do_obj_bank_switch
do_bank_switch:
    STA BG_CHR_BANK_SWITCH
    jslb check_for_bg_chr_bankswap, $a0
    BRA check_code
do_obj_bank_switch:
    STA $05
    STA CHR_BANK_BANK_TO_LOAD
    jslb bankswitch_obj_chr_data, $a0
    BRA check_code
check_code:
    jsr check_for_code_input_from_ram_values
    RTL