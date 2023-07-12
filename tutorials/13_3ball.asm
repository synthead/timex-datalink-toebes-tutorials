;Name: 3BALL
;Version: 3BALL
;Description: An executive decision maker that will give a yes/no/maybe answer.  Pressing Next will generate another answer and beep (since it will be the same answer sometimes).
;
;(c) 1997 Wayne Buttles (timex@fdisk.com). Compiled using tools and knowledge published by John A. Toebes, VIII and Michael Polymenakos (mpoly@panix.com).
; Some enhancements by John Toebes...
;
;HelpFile: watchapp.hlp
;HelpTopic: 100
;
; (1) Program specific constants
;
            INCLUDE "WRISTAPP.I"
;
; Program specific constants
;
CURRENT_TIC     EQU     $27     ; Current system clock tic (Timer)
LAST_ANS        EQU     $61
RAND_SEED       EQU     $60
MARQ_POS        EQU     $62
START           EQU   *
;
; (2) System entry point vectors
;
L0110:  jmp     MAIN    ; The main entry point - WRIST_MAIN
L0113:  bclr    1,BTNFLAGS      ; Called when we are suspended for any reason - WRIST_SUSPEND
        rts
L0116:  jmp     FLASH   ; Called to handle any timers or time events - WRIST_DOTIC
L0119:  bclr    1,BTNFLAGS      ; Called when the COMM app starts and we have timers pending - WRIST_INCOMM
        rts
L011c:  rts             ; Called when the COMM app loads new data - WRIST_NEWDATA
        nop
        nop

L011f:  lda     STATETAB,X ; The state table get routine - WRIST_GETSTATE
        rts

L0123:  jmp   HANDLE_STATE0
        db    STATETAB-STATETAB
;
; (3) Program strings
;
S6_MSG  timex6  "3 BALL"
S6_MAYBE timex6 "MAYBE"
S6_YES  timex6  " YES"
S6_NO   timex6  "  NO"
S6_MARQ timex6  "   +O+   "

MARQ_SEL
        DB      S6_MARQ+2-START
        DB      S6_MARQ+3-START
        DB      S6_MARQ+2-START
        DB      S6_MARQ+1-START
        DB      S6_MARQ-START
        DB      S6_MARQ+1-START

MSG_SEL DB      S6_YES-START
        DB      S6_NO-START
        DB      S6_MAYBE-START
        DB      S6_YES-START
;
; (4) State Table
;
STATETAB:
        db      0
        db      EVT_ENTER,TIM2_16TIC,0  ; Initial state
        db      EVT_RESUME,TIM_ONCE,0   ; Resume from a nested app
        db      EVT_DNNEXT,TIM2_16TIC,0 ; Next button
        db      EVT_TIMER2,TIM_ONCE,0   ; Timer
        db      EVT_MODE,TIM_ONCE,$FF   ; Mode button
        db      EVT_END
;
; (5) State Table 0 Handler
; This is called to process the state events.
; We see ENTER, RESUME, TIMER2 and NEXT events
;        
HANDLE_STATE0:
        bset    1,APP_FLAGS             ; Indicate that we can be suspended
        bclr    1,BTNFLAGS              ; Turn off the MARQUIS tic event
        lda     BTNSTATE
        cmp     #EVT_DNNEXT             ; Did they press the next button?
        beq     DOITAGAIN
        cmp     #EVT_ENTER              ; Or did we start out
        beq     DOITAGAIN
        cmp     #EVT_RESUME             
        beq     REFRESH
;
; (6) Select a random answer
;
SHOWIT
        bsr     RAND
        and     #3              ; go to a 1 in 4 chance
        sta     LAST_ANS
;
; (7) Display the currently selected random number
;
REFRESH
        ldx     LAST_ANS        ; Get the last answer we had, and use it as an index
        lda     MSG_SEL,X       ; And get the message to display
        jsr     PUT6TOP         ; Put that on the top
BANNER
        lda     #S6_MSG-START   
        jsr     PUT6MID
        lda     #SYS8_MODE      ; And show the mode on the bottom
        jmp     PUTMSGBOT
;
; (8) This flashes the text on the screen
;
FLASH
        lda     CURRENT_APP     ; See which app is currently running
        cmp     #APP_WRIST      ; Is it us?
        bne     L0113           ; No, so just turn off the tic timer since we don't need it
        ldx     #5
        lda     MARQ_POS
        jsr     INCA_WRAPX
        sta     MARQ_POS
        tax
        lda     MARQ_SEL,X
        jmp     PUT6TOP
;
; (9) They want us to do it again
;
DOITAGAIN                       ; Tell them we are going to do it again
        clr     MARQ_POS
        bset    1,BTNFLAGS
        bra     BANNER
;
; (10) Here is a simple random number generator
;
RAND
        lda     RAND_SEED
        ldx     #85
        mul
        add     #25
        sta     RAND_SEED
        rola
        rola
        rola
        rts     
;
; (11) This is the main initialization routine which is called when we first get the app into memory
;
MAIN:
        lda     #$c0            ; We want button beeps and to indicate that we have been loaded
        sta     WRISTAPP_FLAGS
        lda     CURRENT_TIC
        sta     RAND_SEED
        rts
