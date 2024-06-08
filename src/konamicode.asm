
; This is a file that can be included to implement the Konami Code in the port
; where in the code the user correctly is
CODE_INDEX  = $0820
JOYPAD1     = $0822
JOYTRIGGER1 = $0824
JOYHELD1    = $0826
buttons     = $0828
KONAMI_CODE_ENABLED = $082A

UP_BUTTON       = $08
DOWN_BUTTON     = $04
LEFT_BUTTON     = $02
RIGHT_BUTTON    = $01

A_BUTTON        = $80
B_BUTTON        = $40
START_BUTTON    = $10
SELECT_BUTTON   = $20

code_values:
.byte UP_BUTTON, UP_BUTTON, DOWN_BUTTON, DOWN_BUTTON
.byte LEFT_BUTTON, RIGHT_BUTTON, LEFT_BUTTON, RIGHT_BUTTON
.byte B_BUTTON, A_BUTTON
.byte $FF



check_for_code_input_l:
    jsr check_for_code_input
    rtl

check_for_code_input:
    PHA
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
    DEX
    BNE :-

    ; we also ready the next bit, which is the SNES "A" button
    ; and if it's on, treat it as if they've hit both Y and B
;     lda JOYSER0
;     AND #$01
;     BEQ :+
;     LDA $00
;     ORA #$C0
;     STA $00
; :
    jsr check_for_code_input_from_ram_values
    PLA
    rts

check_for_code_input_from_ram_values:
    PHA
    PHB
    LDA $F5
    ldy JOYPAD1
    sta JOYPAD1
    tya
    eor JOYPAD1
    and JOYPAD1
    sta JOYTRIGGER1
    BEQ :++
    
    LDA #$A0
    PHA
    PLB

    tya
    and JOYPAD1
    sta JOYHELD1

    lda CODE_INDEX
    tay

    lda code_values, y
    cmp JOYTRIGGER1
    beq :+
    stz CODE_INDEX
    bra :++
    ; correct input
:   INY
    INC CODE_INDEX
    LDA code_values, y
    CMP #$FF
    BNE :+
    jsr code_effect

:   
    PLB
    PLA
    rts


code_effect:
    ; LDA RDNMI
    ; : LDA RDNMI
    ; BEQ :-

    ; AND #$80
    ; STZ CGADD    
    ; LDA #$00
    ; STA CGDATA
    ; STA CGDATA

    ; LDA #$D6
    ; STA CGDATA
    ; LDA #$10
    ; STA CGDATA

    ; INC KONAMI_CODE_ENABLED
    LDA #$3F
    STA $03B4

    LDA #$06
    STA $40

    LDA #$09
    STA $43

    rts