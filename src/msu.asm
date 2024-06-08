.segment "PRGB2"

; Audio Tracks for Double Dragon
; FBE1 - Set/play music track routine
; 0x00 - Silence
; 0x20 - Title Theme 
; 0x21 - Secret Area 2
; 0x22 - Secret Area 1
; 0x23 - Ending
; 0x24 - Mission 2
; 0x25 - Mission 3
; 0x26 - Mission Load
; 0x27 - Mission 4
; 0x28 - Mission 1
; 0x29 - Game Over
; 0x2A - Mission Clear
; 0x2B - Ending (again)

; Read Flags
.DEFINE MSU_STATUS      $2000
.DEFINE MSU_READ        $2001
.DEFINE MSU_ID          $2002   ; 2002 - 2007

; Write flags
.DEFINE MSU_SEEK        $2000
.DEFINE MSU_TRACK       $2004   ; 2004 - 2005
.DEFINE MSU_VOLUME      $2006
.DEFINE MSU_CONTROL     $2007

.DEFINE CURRENT_NSF     $09FF
.DEFINE REMAPPED_NSF    $09FE
.DEFINE LOOP_VALUE      $09FD
.DEFINE MSU_ENABLE      $09FC
.DEFINE MSU_TRIGGER     $09FB

.DEFINE NSF_STOP        #$00
.DEFINE NSF_PAUSE       #$1f
.DEFINE NSF_RESUME      #$ff

.DEFINE NUM_TRACKS      #$0B
.DEFINE TRACKS_AVAILABLE $1ff0

; check_for_all_tracks_present:
;   PHB
;   LDA #$B2
;   PHA
;   PLB
;   LDA MSU_ID		; load first byte of msu-1 identification string
;   CMP #$53		    ; is it "M" present from "MSU-1" string?
;   BEQ :+
;   RTL
; : LDA #$CF
;   STA MSU_VOLUME
;   LDY NUM_TRACKS
;   INY
; : STZ MSU_CONTROL

; msu_status_check:
;   LDA MSU_STATUS
;   AND #$40
;   BNE msu_status_check

;   DEY
;   BMI :+
;   TYA
;   STA MSU_TRACK
;   STZ MSU_TRACK + 1 

;   ; LDA #$FF
;   ; :		; check msu ready status (required for sd2snes hardware compatibility)
;   ;   bit MSU_STATUS
;   ;   bvs :-

;   LDA MSU_STATUS ; load track STAtus
;   AND #$08		; isolate PCM track present byte
;         		; is PCM track present after attempting to play using STA $2004?
;   BNE :-
;   LDA #$01
;   STA TRACKS_AVAILABLE, Y
;   BRA :-
; : PLB
;   RTL

; Checks for MSU track for audio track in Accumulator
msu_check:
  PHB
  PHY
  PHX
  PHA  

  LDA MSU_SELECTED
  BEQ fall_through


  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BNE fall_through  ; No MSU-1 support, fall back to NSF
  
  ; check if we have a track for this value
  PHK
  PLB
  PLA
  PHA
  CMP NSF_STOP
  BEQ stop_msu

  CMP NSF_PAUSE
  BEQ pause_msu

  CMP NSF_RESUME
  BEQ resume_msu

  TAY
  LDA msu_track_lookup, Y
  CMP #$FF
  BEQ fall_through  

  ; TAY
  ; LDA TRACKS_AVAILABLE, Y
  ; BEQ stop_msu
  ; TYA

  ; non-FF value means we have an MSU track
  BRA msu_available

stop_msu:
; is msu playing?  if not, just exit
    LDA MSU_ENABLE
    BEQ fall_through
    STZ MSU_CONTROL
    BRA fall_through

pause_msu:
    LDA MSU_ENABLE
    BEQ fall_through
    STZ MSU_CONTROL
    BRA fall_through

resume_msu:
    LDA MSU_ENABLE
    BEQ fall_through
    LDA REMAPPED_NSF
    TAY
    LDA msu_track_loops, Y
    STA MSU_CONTROL
    BRA fall_through

  ; fall through to default
fall_through:
  PLA
  PLX
  PLY
  PLB

  RTL

  ; if msu is present, process msu routine
msu_available:
  TAY
  PLA
  PHY                   ; push the MSU-1 track 
  PHA                   ; repush the NSF track

  LDA #$00		        ; clear disable/enable nsf music flag
  STA MSU_ENABLE		; clear disable/enable nsf music flag

  PLA
  STA CURRENT_NSF		; store current nsf track-id for later retrieval

  LDA #$01
  STA MSU_TRIGGER
  LDA #$FF		       
  STA MSU_ENABLE		; set mute NSF flag (writing FF in RAM location)

  pla
  STA REMAPPED_NSF		; store current re-mapped nsf track-id for later retrieval

  jsl msu_nmi_check

  PLX
  PLY
  PLB
  LDA #$EE ; set nsf music to mute since we are playing msu  

  RTL


: RTL

msu_nmi_check:
  LDA MSU_TRIGGER
  BEQ :-
  LDA MSU_STATUS
  AND #$40
  BNE :-

  PHB
  PHK
  PLB
  STZ MSU_TRIGGER

  LDA REMAPPED_NSF ; pull the current MSU-1 Track

  stz MSU_VOLUME		; drop volume to zero; reduce STAtic/noise during track changes in sd2snes
  STA MSU_TRACK		    ; store current valid NSF track-ID
  stz MSU_TRACK + 1	    ; must zero out high byte or current msu-1 track will not play !!!
  BRA play_msu

  LDA #$FF
  msu_status:		; check msu ready status (required for sd2snes hardware compatibility)
    bit MSU_STATUS
    bvs msu_status

  LDA MSU_STATUS ; load track STAtus
  AND #$08		; isolate PCM track present byte
        		; is PCM track present after attempting to play using STA $2004?
  BEQ play_msu
  LDA CURRENT_NSF
  PLB
  RTL
   ; track not available, fall back to NSF

play_msu:
  LDA REMAPPED_NSF
  TAY
  LDA msu_track_loops, Y
  STA MSU_CONTROL		; write current loop value
  LDA msu_track_volume, Y
  STA MSU_VOLUME		; write max volume value
  ; STA MSU_ENABLE		; set mute NSF flag (writing FF in RAM location)

  ; LDA CURRENT_NSF		; restore original nsf track-id
  PLB
  RTL

NSF_TRACK = $F1B
MSU_CURR_1 = $F1C
MSU_CURR_2 = $F1D
MSU_CURR_FRAME_TOGGLE = $F1E
MSU_CURR_VOLUME = $F1F

; infidelity_msu_routine:
  LDA $F1C
  ORA $F1D
  STA $F1C
  BEQ :+       ;F03A, aka, to LDA $F1F, STA                  ;$2006, RTS
  LDA MSU_STATUS
  AND #$40
  BNE :+       ;D033, aka, to LDA $F1F, STA                  ;$2006, RTS
  LDA MSU_CURR_FRAME_TOGGLE
  BNE :+       ;D013, aka, to LDY $F1B, LDA                  ;$B290,Y
  LDY NSF_TRACK    ;use original bgm id, as a y                  ;index for msu1 track
  LDA msu_track_lookup,Y    ;msu1 track table, change                     ;0000 to your liking
  STA MSU_TRACK    ;lo byte msu1 track
  STZ MSU_TRACK + 1    ;hi byte msu1 track
  LDA #$01
  STA MSU_CURR_FRAME_TOGGLE
  BRA :++
: LDY NSF_TRACK    ;use original bgm id, as a y 
  LDA msu_track_loops,Y
  STA MSU_CONTROL 
  LDA msu_track_volume,Y                  
  STA MSU_CURR_VOLUME
  STZ $F1C
  STZ $F1D
  STZ MSU_CURR_FRAME_TOGGLE
: LDA MSU_CURR_VOLUME    ;load stored msu1 volume
  STA MSU_VOLUME    
  RTS

; this 0x100 byte lookup table maps the NSF track to the MSU-1 track
msu_track_lookup:
; 20 - 2b are valid tracks
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

; this 0x100 byte lookup table maps the MSU track to the if it loops ($03) or no ($01)
msu_track_loops:
.byte $00, $03, $03, $03, $01, $03, $03, $03, $03, $03, $03, $01, $01, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

; this 0x100 byte lookup table maps the MSU track to the MSU-1 volume ($FF is max, $4F is half)
msu_track_volume:
; 0 - c all loop
.byte $AF, $AF, $AF, $AF, $AF, $AF, $AF, $AF, $AF, $AF, $AF, $AF, $AF, $AF, $AF, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F


.include "msu_intro_screen.asm"
.include "chrom-tiles-msu-intro.asm"


.if ENABLE_MSU_MOVIE = 1
    .include "msu_video_player.asm"
.endif