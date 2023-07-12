;Name: Prom Dump
;Version: promdump
;Description: Prom Dumper - by John A. Toebes, VIII
;This Prom Dump routine shows you what is in the EEProm
;
; Press the NEXT/PREV buttons to advance/backup by 6 bytes of memory at a time
; Press the SET button to change the location in memory where you are dumping.
;
;TIP:  Download your watch faster:  Download a WristApp once, then do not send it again.  It stays in the watch!
;HelpFile: watchapp.hlp
;HelpTopic: 106
            INCLUDE "WRISTAPP.I"
;
; (1) Program specific constants
;
FLAGBYTE        EQU     $61
;   Bit 0 indicates the direction of the last button
;   The other bits are not used
CURRENT_DIGIT   EQU     $62
DIGIT0          EQU     $63
DIGIT1          EQU     $64
DIGIT2          EQU     $65
DIGIT3          EQU     $66
;
; These should have been in the Wristapp.i files, but I forgot them...
;
INST_ADDRHI     EQU     $0437
INST_ADDRLO     EQU     $0438
HW_FLAGS        EQU     $9e
;
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

L0123:  jmp     HANDLE_STATE0
        db      STATETAB0-STATETAB0
L0127:  jmp     HANDLE_STATE1
        db      STATETAB1-STATETAB0
L012b:  jmp     HANDLE_STATE2
        db      STATETAB2-STATETAB0
;
; (3) Program strings
;
S6_EEPROM:      timex6   "EEPROM"
S6_DUMPER:      timex6  "DUMPER"
S8_LOCATION     timex   "aaaa    "
;
; (4) State Table
;
STATETAB0:
        db      0
        db      EVT_ENTER,TIM2_12TIC,0          ; Initial state
        db      EVT_RESUME,TIM_ONCE,0           ; Resume from a nested app
        db      EVT_TIMER2,TIM_ONCE,0           ; This is the timer
        db      EVT_DNNEXT,TIM2_8TIC,1          ; Next button
        db      EVT_DNPREV,TIM2_8TIC,1          ; Prev button
        db      EVT_MODE,TIM_ONCE,$FF           ; Mode button
        db      EVT_SET,TIM_ONCE,2              ; Set button
        db      EVT_USER0,TIM_ONCE,$FF          ; Return to system
        db      EVT_END
        
STATETAB1:
        db      0
        db      EVT_UPANY,TIM_ONCE,0            ; Releasing the prev or next button
        db      EVT_TIMER2,TIM2_TIC,1           ; Repeat operation with a timer
        db      EVT_END                         ; End of table

STATETAB2:
        db      2
        db      EVT_RESUME,TIM_ONCE,2           ; Resume from a nested app
        db      EVT_DNANY4,TIM_ONCE,2           ; NEXT, PREV, SET, MODE button pressed
        db      EVT_UPANY4,TIM_ONCE,2           ; NEXT, PREV, SET, MODE button released
        db      EVT_USER2,TIM_ONCE,0            ; Return to state 0
        db      EVT_END                         ; End of table

CURRENT_LOC
        dw      $0000                           ; This is where we start in memory
;
; (5) State Table 0 Handler
; This is called to process the state events.
; We see ENTER, TIMER2, and RESUME events
;
HANDLE_STATE0:
        bset    1,APP_FLAGS                     ; Indicate that we can be suspended
        lda     BTNSTATE                        ; Get the event
        cmp     #EVT_ENTER                      ; Is this the initial state?
        bne     SHOWDATA                        ; no, just clean up the screen
;
; (6) Put up the initial banner screen
;
        jsr     CLEARALL                        ; Clear the display
        lda     #S6_EEPROM-START                ; Put 'EEPROM' on the top line
        jsr     PUT6TOP
        lda     #S6_DUMPER-START                ; Put 'DUMPER' on the second line
        jsr     PUT6MID
        lda     #SYS8_MODE                      ; Put MODE on the bottom line
        jmp     PUTMSGBOT
; (7) FMTHEX is a routine similar to FMTX, but it handles hex values instead
;=======================================================================
; Routine: FMTHEX
; Purpose:
;   Format a byte into the buffer
; Parameters:
;   A - Byte to be formatted
;   X - Offset into Message buffer to put the byte
;=======================================================================
FMTHEX:
        sta     S8_LOCATION,X   ; Save the byte
        and     #$0f            ; Extract the bottom nibble
        sta     S8_LOCATION+1,X ; Save the hex value of the nibble
        lda     S8_LOCATION,X   ; Get the value once again
        lsra                    ; Shift right by 4 to get the high order nibble
        lsra
        lsra
        lsra

        sta     S8_LOCATION,X   ; And put it back into the buffer
        rts
;
; (8) This is called when we press the prev/next button or when the timer fires during that event
;
HANDLE_STATE1:
        lda     BTNSTATE
        cmp     #EVT_TIMER2                     ; Is this a repeat/timer event?
        beq     REPEATBTN                       ; yes, do as they asked

        bclr    0,FLAGBYTE                      ; Assume that they hit the prev button
        cmp     #EVT_DNPREV                     ; Did they hit the prev button
        bne     REPEATBTN                       ; Yes, we guessed right
        bset    0,FLAGBYTE                      ; No, they hit next.  Mark the direction.
REPEATBTN:
        brclr   0,FLAGBYTE,NEXTLOC              ; If they hit the next button, go do that operation
;
; They pressed the prev button, let's go to the previous location
;
PREVLOC:
        lda     CURRENT_LOC+1
        sub     #6
        sta     CURRENT_LOC+1
        lda     CURRENT_LOC
        sbc     #0
        sta     CURRENT_LOC
        bra     SHOWDATA
NEXTLOC:
        lda     #6
        add     CURRENT_LOC+1
        sta     CURRENT_LOC+1
        lda     CURRENT_LOC
        adc     #0
        sta     CURRENT_LOC
;
; (9) This is the main screen update routine.
; It dumps the current memory bytes based on the current address.  Note that since it updates the entire
; display, it doesn't have to clear anything
;
SHOWDATA:
        jsr     CLEARSYM

        clrx
        bsr     GETBYTE
        jsr     PUTTOP12

        ldx     #1
        bsr     GETBYTE
        jsr     PUTTOP34

        ldx     #2
        bsr     GETBYTE
        jsr     PUTTOP56

        ldx     #3
        bsr     GETBYTE
        jsr     PUTMID12

        ldx     #4
        bsr     GETBYTE
        jsr     PUTMID34

        ldx     #5
        bsr     GETBYTE
        jsr     PUTMID56

        lda     CURRENT_LOC             ; Get the high order byte of the address
        clrx
        bsr     FMTHEX          ; Put that at the start of the buffer
        lda     CURRENT_LOC+1           ; Get the low order byte of the address
        ldx     #2
        bsr     FMTHEX          ; Put that next in the buffer

        lda     #S8_LOCATION-START
        jmp     BANNER8
; (10) GETBYTE gets a byte from memory and formats it as a hex value
;=======================================================================
; Routine: GETBYTE
; Purpose:
;   Read a byte from memory and put it into DATDIGIT1/DATDIGIT2 as hex values
; Parameters:
;   X - Offset from location to read byte
;   CURRENT_LOC - Base location to read from
;=======================================================================
GETBYTE
        txa
        add     CURRENT_LOC+1
        sta     INST_ADDRLO
        lda     CURRENT_LOC
        adc     #0
        sta     INST_ADDRHI
        bset    6,HW_FLAGS                      ; Tell them that it is an EEPROM address
        jsr     GET_INST_BYTE                   ; Get the current byte
        sta     DATDIGIT2                       ; And save it away
        lsra                                    ; Extract the high nibble
        lsra
        lsra
        lsra

        sta     DATDIGIT1                       ; And save it
        lda     DATDIGIT2                       ; Get the byte again
        and     #$0f                            ; Extract the low nibble
        sta     DATDIGIT2                       ; And save it
        rts
;
; (11) State Table 2 Handler
; This is called to process the state events.
; We see SET, RESUME, DNANY4, and UPANY4 events
;
HANDLE_STATE2:
        bset    1,APP_FLAGS                     ; Indicate that we can be suspended
        lda     BTNSTATE                        ; Get the event
        cmp     #EVT_UPANY4
        beq     REFRESH2
        cmp     #EVT_DNANY4                     ; Is this our initial entry?
        bne     FORCEFRESH
        lda     BTN_PRESSED                     ; Let's see what the button they pressed was
        cmp     #EVT_PREV                       ; How about the PREV button
        beq     DO_PREV                         ; handle it
        cmp     #EVT_NEXT                       ; Maybe the NEXT button?
        beq     DO_NEXT                         ; Deal with it!
        cmp     #EVT_MODE                       ; Perhaps the MODE button
        beq     DO_MODE                         ; If so, handle it
        ; It must be the set button, so take us out of this state
        bsr     SHOWDATA
        lda     #EVT_USER2
        jmp     POSTEVENT
;
; (12) This handles the update routine to change a digit...
;
DO_NEXT
        bset    0,SYSFLAGS                      ; Mark our update direction as up
        bra     DO_UPD
DO_PREV
        bclr    0,SYSFLAGS                      ; Mark our update direction as down
DO_UPD
        clra
        sta     UPDATE_MIN                      ; Our low end is 0
        lda     #$F
        sta     UPDATE_MAX                      ; and the high end is 15 (the hes digits 0-F)
        bsr     GET_DISP_PARM
        lda     #UPD_DIGIT
        jsr     START_UPDATEP                   ; And prepare the update routine   
        bset    4,BTNFLAGS                      ; Mark that the update is now pending
        rts
;
; (13) This is where we switch which digit we are changing...
;
DO_MODE
        lda     CURRENT_DIGIT
        inca
        and     #3
        sta     CURRENT_DIGIT
;
; (14) Refresh the screen and start blinking the current digit...
;
REFRESH2
        lda     DIGIT0                          ; Get the first digit
        lsla                                    ; *16
        lsla
        lsla
        lsla
        add     DIGIT1                          ; Plus the second digit
        sta     CURRENT_LOC                     ; To make the high byte of the address
        lda     DIGIT2                          ; Get the third digit
        lsla                                    ; *16 
        lsla
        lsla
        lsla
        add     DIGIT3                          ; Plus the fourth digit
        sta     CURRENT_LOC+1                   ; To make the low byte of the address
FORCEFRESH
        bclr    7,BTNFLAGS                      ; Turn off any update routine that might be pending
        jsr     SHOWDATA                        ; Format the screen
        ldx     #4                              ; We need to copy over 4 bytes from the buffer
COPYIT
        decx                                    ; This will be one down.
        lda     S8_LOCATION,X                   ; Get the formatted byte
        sta     DIGIT0,X                        ; And store it for the update routine
        tstx                                    ; Did we copy enough bytes?
        bne     COPYIT                          ; No, go back for more
        bsr     GET_DISP_PARM                   ; Get the parm for the blink routine
        lda     #BLINK_DIGIT                    ; Request to blink a digit
        jsr     START_BLINKP                    ; And do it
        bset    2,BTNFLAGS                      ; Mark a blink routine as pending
        rts
;
; (15) This gets the parameters for an UPDATE/BLINK routine
;
GET_DISP_PARM
        lda     CURRENT_DIGIT                   ; Figure out what digit we are dumping
        sta     UPDATE_POS                      ; Store it for the BLINK/UPDATE routine
        add     #DIGIT0                         ; Point to the byte to be updated
        tax                                     ; And put it into X as needed for the parameter
        rts
;
; (16) This is the main initialization routine which is called when we first get the app into memory
;
MAIN:
        lda     #$c0                            ; We want button beeps and to indicate that we have been loaded
        sta     WRISTAPP_FLAGS
        clr     CURRENT_DIGIT                   ; Start out on the first digit
        rts
