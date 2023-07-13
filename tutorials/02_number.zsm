;Name: Numbers
;Version: NUMBER
;Description: This is a simple number count program
;by John A. Toebes, VIII
;
;TIP:  Download your watch faster:  Download a WristApp once, then do not send it again.  It stays in the watch!
;HelpFile: watchapp.hlp
;HelpTopic: 106
            INCLUDE "WRISTAPP.I"
;
; (1) Program specific constants
;
FLAGBYTE        EQU     $61
;   Bit 0 indicates that we want to show the segments instead of the message
;
CURVAL      EQU   $62   ; The current value we are displaying
START           EQU   *
;
; (2) System entry point vectors
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

L011f:  lda     STATETAB,X ; The state table get routine - WRIST_GETSTATE
        rts

L0123:  jmp HANDLE_STATE0
        db  STATETAB-STATETAB
;
; (3) Program strings
S6_NUMBER:      timex6  "NUMBER"
S6_COUNT:   timex6  "COUNT "
;
; (4) State Table
STATETAB:
        db      0
        db      EVT_ENTER,TIM2_8TIC,0   ; Initial state
        db      EVT_TIMER2,TIM_ONCE,0   ; The timer from the enter event
        db      EVT_RESUME,TIM_ONCE,0   ; Resume from a nested app
        db      EVT_DNNEXT,TIM_ONCE,0   ; Next button
        db      EVT_DNPREV,TIM_ONCE,0   ; Prev button
        db      EVT_DNSET,TIM_ONCE,0    ; Set button
        db      EVT_MODE,TIM_ONCE,$FF   ; Mode button
        db      EVT_END
;
; (5) State Table 0 Handler
; This is called to process the state events.  We will see ENTER, RESUME, DNNEXT, DNPREV, DNSET, and TIMER2
;
HANDLE_STATE0:
        bset    1,APP_FLAGS             ; Indicate that we can be suspended
        lda     BTNSTATE                ; Get the event
        cmp     #EVT_DNNEXT             ; Did they press the next button?
        beq     DO_NEXT                 ; Yes, increment the counter
        cmp     #EVT_DNPREV             ; How about the PREV button
        beq     DO_PREV                 ; handle it
        cmp     #EVT_DNSET              ; Maybe the set button?
        beq     DO_SET                  ; Deal with it!
        cmp     #EVT_ENTER              ; Is this our initial entry?
        bne     REFRESH
;
; This is the initial event for starting us
;
DO_ENTER    
        bclr    1,FLAGBYTE              ; Indicate that we need to clear the display
        jsr     CLEARSYM                        ; Clear the display
        lda     #S6_NUMBER-START
        jsr     PUT6TOP
        lda     #S6_COUNT-START
        jsr     PUT6MID
        lda     #SYS8_MODE
        jmp     PUTMSGBOT
;
; (6) Our only real working code...
DO_NEXT
        inc     CURVAL
        lda     CURVAL
        cmp     #100
        bne     SHOWVAL
DO_SET
        clr     CURVAL
SHOWVAL
        brset   1,FLAGBYTE,NOCLEAR
REFRESH
        jsr     CLEARALL
        bset    1,FLAGBYTE
NOCLEAR
        ldx     CURVAL
        jsr     FMTXLEAD0
        jmp     PUTMID34
DO_PREV
        lda     CURVAL
        beq     WRAPUP
        dec     CURVAL
        bra     SHOWVAL
WRAPUP
        lda     #99
        sta     CURVAL
        bra     SHOWVAL
;
; (7) This is the main initialization routine which is called when we first get the app into memory
;
MAIN:
        lda     #$c0                            ; We want button beeps and to indicate that we have been loaded
        sta     WRISTAPP_FLAGS
        clr     FLAGBYTE                        ; start with a clean slate
        clr     CURVAL
        rts
