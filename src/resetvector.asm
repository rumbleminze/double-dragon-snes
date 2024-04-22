start:
SEI
CLC
XCE

setXY16
LDX #$01FF
TXS
LDA #$A0
PHA
PLB
JSL $A08000

; this needs to be the NES game's reset vector
JML $A1FFE0
nmi:
    ; we abandon these
    ; PHP
    PHA
    PHX
    PHY
    jslb snes_nmi, $a0


    ; jump to NES NMI
    CLC
    LDA ACTIVE_NES_BANK
    INC
    ADC #$A0
    STA BANK_SWITCH_DB    
    PHA
    PLB
    
    jslb translate_8by8only_nes_sprites_to_oam, $a0
    ; Double Dragon NMI is at FF16
    LDA #$ff
    STA BANK_SWITCH_HB
    LDA #$16
    STA BANK_SWITCH_LB

    PLY
    PLX
    PLA
    JML [BANK_SWITCH_LB]

return_from_nes_nmi:
    ; we likely don't ever end up here
    PLY
    PLX
    PLA
    PLP
    RTI

; this is used by the MSU video player, ignore it if you don't use it.
_rti:
    JML $C7FF14 
    LDA $01B0
    BEQ :+
    LDA $E6
    BEQ :+
    JSR $D000
:   LDA #$A1
    PHA
    PLB
    BRA start

    rti