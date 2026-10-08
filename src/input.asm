augment_input:

;     ; origingal code
;     LDX $FB
;     INX
;     STX JOYSER0
;     DEX
;     STX JOYSER0
;     LDX #$08
; :   LDA JOYSER0
;     LSR
;     ROL $F5
;     LSR
;     ROL $00
;     LDA JOYSER1
;     LSR
;     ROL $F6
;     LSR
;     ROL $01
;     DEX
;     BNE :-

    LDA JOY1H
    STA $F5
    STZ $00
    LDA JOY2H
    STA $F6
    STZ $01
    
    ; treat A as Y+B
    LDA JOY1L
    AND #$80 ; check for A
    BEQ :+
        LDA $F5
        ORA #$C0
        STA $F5
    :

    LDA JOY2L
    AND #$80
    BEQ :+
        LDA $F6
        ORA #$C0
        STA $F6
    :

    ; X
    ; lda JOYSER0
    ; lda JOYSER0
    ; AND #$01
    ; BEQ :+

check_code:
    jsr check_for_code_input_from_ram_values
    RTL