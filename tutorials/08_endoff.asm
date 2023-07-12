;Name: Week End Off
;Version: ENDOFF
;Description: Week End Off - by John A. Toebes, VIII
;This application turns off all alarms on the weekend.
;
;TIP:  Download your watch faster:  Download a WristApp once, then do not send it again.  It stays in the watch!
;HelpFile: watchapp.hlp
;HelpTopic: 106
            INCLUDE "WRISTAPP.I"
;
; (1) Program specific constants
;
START     EQU   *
;
; (2) System entry point vectors
;
L0110:  jmp     MAIN    ; The main entry point - WRIST_MAIN
L0113:  rts             ; Called when we are suspended for any reason - WRIST_SUSPEND
        nop
        nop
L0116:  jmp     CHECKSTATE      ; Called to handle any timers or time events - WRIST_DOTIC
L0119:  jmp     ENABLE_ALL      ; Called when the COMM app starts and we have timers pending - WRIST_INCOMM
L011c:  jmp     CHECKSTATE      ; Called when the COMM app loads new data - WRIST_NEWDATA

L011f:  lda     STATETAB,X ; The state table get routine - WRIST_GETSTATE
        rts

L0123:  jmp     HANDLE_STATE0
        db      STATETAB-STATETAB
;
; (3) Program strings
;
S6_WEEK:        timex6  " WEEH "
S6_ENDOFF:      timex6  "ENDOFF"
S8_TOEBES:      timex   "J.TOEBES"
;
; (4) State Table
;
STATETAB:
        db      0
        db      EVT_ENTER,TIM_LONG,0    ; Initial state
        db      EVT_RESUME,TIM_ONCE,0   ; Resume from a nested app
        db      EVT_MODE,TIM_ONCE,$FF   ; Mode button
        db      EVT_END
;
; (5) State Table 0 Handler
; This is called to process the state events.
; We see ENTER and RESUME events
;        
HANDLE_STATE0:
        bset    1,APP_FLAGS             ; Allow us to be suspended
        jsr     CLEARALL                ; Clear the display
        lda     #S6_WEEK-START          ; Put ' WEEK ' on the top line
        jsr     PUT6TOP
        lda     #S6_ENDOFF-START        ; Put 'ENDOFF' on the second line
        jsr     PUT6MID
;
; (6) Faking a letter K
;
;
; We have    We want it to look like:
; |     |    |      
; |     |    |  |   
; |     |    |  |   
; |=====|    |===== 
; |     |    |     |
; |     |    |     |
; |     |    |     |
; This means turning off T5B and turning on T5H
        lda     #ROW_T5B
        sta     DISP_ROW
        bclr    COL_T5B,DISP_COL
        lda     #ROW_T5H
        sta     DISP_ROW
        bset    COL_T5H,DISP_COL
        jsr     CHECKSTATE              ; Just for fun, check the alarm state
        lda     #S8_TOEBES-START
        jmp     BANNER8
;
; (7) This is the main initialization routine which is called when we first get the app into memory
;
MAIN:
        bset    7,WRISTAPP_FLAGS        ; Tell them that we are a live application
        lda     #$C8    ; Bit3 = wristapp wants a call once a day when it changes (WRIST_DOTIC) (SET=CALL)
                        ; Bit6 = Uses system rules for button beep decisions (SET=SYSTEM RULES)
                        ; Bit7 = Wristapp has been loaded (SET=LOADED)
        sta     WRISTAPP_FLAGS
        ; Fall into CHECKSTATE
;
; (8) Determining the day of the week
;
CHECKSTATE
        jsr     ACQUIRE                 ; Lock so that it doesn't change under us
        lda     TZ1_DOW                 ; Assume that we are using the first timezone
        jsr     CHECK_TZ                ; See which one we are really using
        bcc     GOT_TZ1                 ; If we were right, just skip on to do the work
        lda     TZ2_DOW                 ; Wrong guess, just load up the second time zone
GOT_TZ1
        jsr     RELEASE                 ; Unlock so the rest of the system is happy
        cmp     #5                      ; Time zone day of week is 0=Monday...6=Sunday
        bhs     DISABLE_ALL             ; Saturday, Sunday - disable them all
        ; Fall into ENABLE_ALL
;---------------------------------------------------------------
; Routine:
;   (9) ENABLE_ALL/DISABLE_ALL
; Parameters:
;   NONE
; Purpose:
;   These routines enable/disable all of the alarms.  It hides the disabled status of
;   the alarm by storing it in bit 3 of the alarm flags.
;      Bit0 = Alarm is enabled (SET=ENABLED)
;      Bit1 = Alarm is masked (SET=MASKED)
;      Bit2 = Current alarm is in 12 hour mode and is in the afternoon (SET=AFTERNOON)
;      Bit3 = Alarm was enabled, but we are hiding it (SET=HIDDEN)
;   It is safe to call these routine multiple times.
;---------------------------------------------------------------
ENABLE_ALL
        ldx     #4                      ; We have 5 alarms to go through
ENABLE_NEXT
        lda     ALARM_STATUS,X          ; Get the flags for this alarm
        lsra                            ; Shift right 3 to get our hidden bit into place
        lsra
        lsra
        and     #1                      ; Mask out everything except the hidden bit (now in the enabled position
        ora     ALARM_STATUS,X          ; Or it back into the flags
        and     #7                      ; and clear out our hidden bit
        sta     ALARM_STATUS,X          ; then save it out again.
        decx                            ; Count down the number of alarms
        bpl     ENABLE_NEXT             ; And go back for the next one
        rts

DISABLE_ALL
        ldx     #4                      ; We have 5 alarms to go through
DISABLE_NEXT
        lda     ALARM_STATUS,X          ; Get the flags for this alarm
        and     #1                      ; And extract our enabled bit
        lsla                            ; Shift left 3 to save as our hidden bit
        lsla
        lsla
        ora     ALARM_STATUS,X          ; Or it back into the flags
        and     #$0e                    ; and clear out the enabled bit
        sta     ALARM_STATUS,X          ; then save it out again.
        decx                            ; Count down the number of alarms
        bpl     DISABLE_NEXT            ; And go back for the next one
        rts
