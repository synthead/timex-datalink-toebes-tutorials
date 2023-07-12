;Name: Test Sound
;Version: TESTSND
;Description: This routine tests the various sound capabilities of the datalink.
;by John A. Toebes, VIII
;
;TIP:  Download your watch faster:  Download a WristApp once, then do not send it again.  It stays in the watch!
;HelpFile: watchapp.hlp
;HelpTopic: 106
            INCLUDE "WRISTAPP.I"
;
; (1) Program specific constants
;
CURRENT_VAL        EQU          $61
;
; (2) System entry point vectors
;
START   EQU     *
L0110:  jmp     MAIN    ; The main entry point - WRIST_MAIN
L0113:  rts             ; Called when we are suspended for any reason - WRIST_SUSPEND
        nop
        nop
L0116:  rts             ; Called to handle any timers or time events - WRIST_DOTIC
        nop
        nop
L0119:  rts             ; Called when the COMM app starts and we have timers pending - WRIST_INCOMM
        nop
        nop
L011c:  rts             ; Called when the COMM app loads new data - WRIST_NEWDATA
        nop
        nop

L011f:  lda     STATETAB0,X ; The state table get routine - WRIST_GETSTATE
        rts

L0123:  jmp     DOEVENT0
        db      TABLE0-TABLE0
L0127:  jmp     DOEVENT1
        db      TABLE1-TABLE0
;
; (3) Program strings
S6_SOUND:       timex6  "SOUND "
S6_TEST:        timex6  " TEST "
S8_TOEBES:      timex   "J.TOEBES"
;
; (4) State Table
;
TABLE0:
                db      0
                db      EVT_ENTER,TIM_LONG,0    ; Initial state
                db      EVT_RESUME,TIM_ONCE,0   ; Resume from a nested app
                db      EVT_TIMER2,TIM_ONCE,0   ; 
                db      EVT_DNNEXT,TIM_ONCE,1   ; Next button
                db      EVT_DNPREV,TIM_ONCE,1   ; Prev button
                db      EVT_MODE,TIM_ONCE,$FF   ; Mode button
                db      EVT_DNSET,TIM_ONCE,0    ; Set button
                db      EVT_UPSET,TIM_ONCE,0    ;
                db      EVT_END
        
TABLE1:
                db      1
                db      EVT_UPNEXT,TIM_ONCE,1   ; Releasing the next button
                db      EVT_UPPREV,TIM_ONCE,1   ; Releasing the prev button
                db      EVT_USER0,TIM_ONCE,0    ; Return to the main state table
                db      EVT_END                 ; End of table
;
; (5) State Table 0 Handler
; This is called to process the state events.
; We see ENTER, TIMER2, and RESUME events
;
DOEVENT0:
                bset    1,APP_FLAGS             ; Allow us to be suspended
                lda     BTNSTATE                ; Get the event
                cmp     #EVT_RESUME             ; Did another app get called in the meantime?
                beq     REFRESH                 ; We will refresh the display in this case
                cmp     #EVT_TIMER2             ; Did the initial timer expire?
                beq     REFRESH                 ; Yes, clean up the screen
                cmp     #EVT_ENTER              ; Is this the initial state?
                beq     INITBANNER              ; Yes, put up the banner
                cmp     #EVT_DNSET              ; Did they hit the set button
                beq     PLAYIT
                cmp     #EVT_UPSET
                beq     SILENCE
                rts
;
; (6) Sound playing code.  Note that we go straight to the hardware here for this one
;
PLAYIT:
                lda     #ROW_NOTE               ; Turn on the little note symbol
                sta     DISP_ROW
                bset    COL_NOTE,DISP_COL
                lda     CURRENT_VAL
                sta     $28
                rts

SILENCE:
                lda     #ROW_NOTE               ; Turn off the little note symbol
                sta     DISP_ROW
                bclr    COL_NOTE,DISP_COL
                lda     #15
                sta     $28
                rts

REFRESH:
                jsr     CLEARALL                ; Clear the display
                lda     #S6_SOUND-START         ; Put "SOUND" on the top of the display
                jsr     PUT6TOP
                ldx     CURRENT_VAL
                jsr     FMTX
                jsr     PUTMID34
                bra     JBANNER

INITBANNER:
                jsr     CLEARALL                ; Clear the display
                lda     #S6_SOUND-START         ; Put 'SOUND ' on the top line
                jsr     PUT6TOP
                lda     #S6_TEST-START          ; Put ' TEST ' on the second line
                jsr     PUT6MID
JBANNER
                lda     #S8_TOEBES-START
                jmp     BANNER8
;
; (7) This is the main initialization routine which is called when we first get the app into memory
;
MAIN:
                bset    7,WRISTAPP_FLAGS        ; Tell them that we are a live application
                clr     CURRENT_VAL
                rts
;
; (8) State Table 1 Handler
;
; This is called when we press the prev/next button or when the timer fires during that event
;
DOEVENT1:
                lda     BTNSTATE
                cmp     #EVT_DNPREV
                beq     GO_DOWN
                cmp     #EVT_DNNEXT
                beq     GO_UP
                lda     #EVT_USER0
                jmp     POSTEVENT

GO_DOWN         bclr    0,SYSFLAGS      ; Mark update direction as down
                bra     DOUPDN
GO_UP           bset    0,SYSFLAGS      ; Mark update direction as up
DOUPDN          clra
                jsr     CLEARMID
                sta     UPDATE_MIN
                lda     #99
                sta     UPDATE_MAX
                ldx     #CURRENT_VAL
                lda     #UPD_MID34
                jsr     START_UPDATEP
                bset    4,BTNFLAGS
                rts
