;Name: Hello World
;Version: HELLO
;Description: This is a simple Hello Program
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
START   EQU   *
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

L0123:  jmp     HANDLE_STATE0
        db      STATETAB-STATETAB
;
; (3) Program strings
S6_HELLO:   timex6  "HELLO "
S6_WORLD:   timex6  "WORLD "
;
; (4) State Table
; (4) State Table
STATETAB:
                db      0
                db      EVT_ENTER,TIM_ONCE,0    ; Initial state
                db      EVT_RESUME,TIM_ONCE,0   ; Resume from a nested app
                db      EVT_DNNEXT,TIM_ONCE,0   ; Next button
                db      EVT_MODE,TIM_ONCE,$FF   ; Mode button
                db      EVT_END
;
; (5) State Table 0 Handler
; This is called to process the state events.  We only see ENTER, RESUME, and DNNEXT events
;
HANDLE_STATE0:
                bset    1,$8f                   ; Indicate that we can be suspended
                lda     BTNSTATE                ; Get the event
                cmp     #EVT_DNNEXT             ; Did they press the next button?
                beq     DOTOGGLE                ; Yes, toggle what we are displaying
CLEARIT         bclr    0,FLAGBYTE              ; Start us in the show display state
REFRESH         brclr   0,FLAGBYTE,SHOWDISP     ; Do we want to see the main display?
                jmp     SETALL                  ; No, just turn on all segments
SHOWDISP        jsr     CLEARALL                ; Clear the display
                lda     #S6_HELLO-START         ; Get the offset for the first string
                jsr     PUT6TOP                 ; And send it to the top line
                lda     #S6_WORLD-START         ; Get the offset for the second string
                jsr     PUT6MID                 ; and put it on the middle line
                lda     #SYS8_MODE              ; Get the system offset for the 'MODE' string
                jmp     PUTMSGBOT               ; and put it on the bottom line
;
; (6) Our only real piece of working code...
DOTOGGLE        brset   0,FLAGBYTE,CLEARIT      ; If it is set, just jump to clear it like normal
                bset    0,FLAGBYTE              ; Already clear, so set it
                bra     REFRESH                 ; and let the refresh code handle it
;
; (7) This is the main initialization routine which is called when we first get the app into memory
;
MAIN:
                lda     #$c0                    ; We want button beeps and to indicate that we have been loaded
                sta     $96
                clr     FLAGBYTE                ; start with a clean slate
                rts
