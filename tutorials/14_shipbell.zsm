;Name: Ships Bells
;Version: SHIPBELL
;Description: Ships bells - by John A. Toebes, VIII
;This application turns makes the hour chime with nautical bells.
;
;TIP:  Download your watch faster:  Download a WristApp once, then do not send it again.  It stays in the watch!
;HelpFile: watchapp.hlp
;HelpTopic: 106
            INCLUDE "WRISTAPP.I"
;
; (1) Program specific constants
;
START     EQU   *
CHANGE_FLAGS    EQU     $92     ; System Flags
SND_POS         EQU     $61
SND_REMAIN      EQU     $62
SND_NOTE        EQU     $63

NOTE_PAUSE      EQU     (TONE_PAUSE/16)
NOTE_BELL       EQU     (TONE_MID_C/16)
;
; (2) System entry point vectors
;
L0110:  jmp     MAIN    ; The main entry point - WRIST_MAIN
L0113:  rts             ; Called when we are suspended for any reason - WRIST_SUSPEND
        nop
        nop
L0116:  jmp     CHECKSTATE      ; Called to handle any timers or time events - WRIST_DOTIC
L0119:  jmp     STOPIT          ; Called when the COMM app starts and we have timers pending - WRIST_INCOMM
L011c:  rts
        nop
        nop                     ; Called when the COMM app loads new data - WRIST_NEWDATA

L011f:  lda     STATETAB,X ; The state table get routine - WRIST_GETSTATE
        rts

L0123:  jmp     HANDLE_STATE0
        db      STATETAB-STATETAB
;
; (3) Program strings
;
S6_SHIPS:       timex6  "SHIPS"
S6_BELLS:       timex6  " BELLS"
S8_TOEBES:      timex   "J.TOEBES"
;
; Here is the pattern for the ships bells.  We want to have a short bell followed by a very short silence
; followed by a longer bell.  We use 3 tics for the short bell, 1 tic for the silence and 6 tics for the longer
; bell.  The last bell is 7 ticks.
; We then have to byte swap each of these because the BRSET instruction numbers from bottom to top.
;
; The string looks like:
;   111 0 111111 000000 111 0 111111 000000 111 0 111111 000000 111 0 111111 000000
; Taking this into clumps of 4 bytes, we get
;   1110 1111  1100 0000  1110 1111  1100 0000  1110 1111  1100 0000  1110 1111  1100 0000  1111 1110
;
Pattern DB      $F7     ;1110 1111  ; 8 start here
        DB      $03     ;1100 0000
P67     DB      $F7     ;1110 1111  ; 6, 7 start here
        DB      $03     ;1100 0000
P45     DB      $F7     ;1110 1111  ; 4, 5 start here
        DB      $03     ;1100 0000
P23     DB      $F7     ;1110 1111  ; 2, 3 start here
        DB      $03     ;1100 0000
P1      DB      $7F     ;1111 1110  ; 1 starts here
;
; This table indexes where we start playing the tone from
;
STARTS  
        DB      (Pattern-Pattern)*8     ; 0 (8 AM,  4PM, Midnight)
        DB      (P1-Pattern)*8          ; 1 (1 AM,  9AM,  5PM)
        DB      (P23-Pattern)*8         ; 2 (2 AM, 10AM,  6PM)
        DB      (P23-Pattern)*8         ; 3 (3 AM, 11AM,  7PM)
        DB      (P45-Pattern)*8         ; 4 (4 AM, NOON,  8PM)
        DB      (P45-Pattern)*8         ; 5 (5 AM,  1PM,  9PM)
        DB      (P67-Pattern)*8         ; 6 (6 AM,  2PM, 10PM)
        DB      (P67-Pattern)*8         ; 7 (7 AM,  3PM, 11PM)
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
        lda     #S6_SHIPS-START         ; Put 'SHIPS ' on the top line
        jsr     PUT6TOP
        lda     #S6_BELLS-START         ; Put ' BELLS' on the second line
        jsr     PUT6MID
        bsr     FORCESTATE              ; Just for fun, check the alarm state
        lda     #S8_TOEBES-START
        jmp     BANNER8
;
; (6) This is the main initialization routine which is called when we first get the app into memory
;
MAIN:
        lda     #$C4    ; Bit2 = wristapp wants a call once an hour when it changes (WRIST_DOTIC) (SET=CALL)
                        ; Bit6 = Uses system rules for button beep decisions (SET=SYSTEM RULES)
                        ; Bit7 = Wristapp has been loaded (SET=LOADED)
        sta     WRISTAPP_FLAGS
        bclr    2,MODE_FLAGS    ; Turn off the hourly chimes
        clr     SND_REMAIN
;
; (7) Determining the current hour
;
CHECKSTATE
        brclr   5,CHANGE_FLAGS,NO_HOUR  ; Have we hit the hour mark?
FORCESTATE
        bclr    3,MAIN_FLAGS            ; Make sure we don't play the system hourly chimes
        jsr     ACQUIRE                 ; Lock so that it doesn't change under us
        lda     TZ1_HOUR                ; Assume that we are using the first timezone
        jsr     CHECK_TZ                ; See which one we are really using
        bcc     GOT_TZ1                 ; If we were right, just skip on to do the work
        lda     TZ2_HOUR                ; Wrong guess, just load up the second time zone
GOT_TZ1
;
;        12  1  2  3  4  5  6  7  8  9 10 11 12  1  2  3  4  5  6  7  8  9 10 11 12
;        00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18
; deca   FF 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17
; anda   07 00 01 02 03 04 05 06 07 00 01 02 03 04 05 06 07 00 01 02 03 04 05 06 07
        and     #7                      ; Convert the hour to the number of bells
        tax                             ; Save away as an index into the start position table
        bne     NOTEIGHT                ; Is it midnight (or a multiple of 8)
        lda     #8                      ; Yes, so that is 8 bells, not zero
NOTEIGHT
        lsla                            ; Multiple the number of bells by 8 to get the length
        lsla
        lsla
        sta     SND_REMAIN              ; Save away the number of bells left to play
        lda     STARTS,X                ; Point to the pattern of the first bell
        sta     SND_POS                 
        bset    1,BTNFLAGS              ; Turn on the tic timer
        JMP     RELEASE                 ; And release our lock on the time
;
; (8) Playing the next note piece
;
NO_HOUR
        lda     SND_REMAIN              ; Do we have any more notes to play?
        bne     DO_SOUND                ; No, skip out
STOPIT
        lda     #TONE_PAUSE             ; End of the line, shut up the sound hardware
        sta     $28
        clr     SND_REMAIN              ; Force us to quit looking at sound
        bclr    1,BTNFLAGS              ; and turn off the tic timer
        rts

DO_SOUND
        deca                            ; Yes, note that we used one up
        sta     SND_REMAIN
        lda     SND_POS                 ; See where we are in the sound
        lsra                            ; Divide by 8 to get the byte pointer
        lsra
        lsra
        tax                             ; and make it an index
        lda     Pattern,X               ; Get the current pattern byte
        sta     SND_NOTE                ; And save it where we can test it
        lda     SND_POS                 ; Get the pointer to where we are in the sound
        inc     SND_POS                 ; Advance to the next byte
        and     #7                      ; and hack off the high bytes to leave the bit index
        lsla                            ; Convert that to a BRSET instruction
        sta     TSTNOTE                 ; And self modify our code so we can play
TSTNOTE brset   0,SND_NOTE,PLAYIT       ; If the note is not set, skip out
        lda     #TONE_PAUSE             ; Not playing, we want to have silence
        brskip2
PLAYIT  lda     #NOTE_BELL              ; Playing, select the bell tone
        sta     $28                     ; And make it play
NO_SOUND
        rts
