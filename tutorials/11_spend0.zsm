;Name: spend watch
;Version: spend0
;Description: spend watch - by John A. Toebes, VIII
;This keeps track of how much is in one of 7 categories
;
; Press the NEXT/PREV buttons to advance/backup through the categories
; Press the SET button to add/subtract/set/clear the amounts in the categories
; If you press the set button while the action is blinking, it will be carried out, otherwise
; you can cancel the operation.
;
;TIP:  Download your watch faster:  Download a WristApp once, then do not send it again.  It stays in the watch!
;HelpFile: watchapp.hlp
;HelpTopic: 106
;Parent: SpendSet
;****************************************************************************************
;* Copyright (C) 1997 John A. Toebes, VIII                                              *
;* All Rights Reserved                                                                  *
;* This program may not be distributed in any form without the permission of the author *
;*         jtoebes@geocities.com                                                        *
;****************************************************************************************
;
; History:
;    31 July 96 - Corrected problem with totals not being recalculated when you reenter
;                 the wristapp.
;
            INCLUDE "WRISTAPP.I"
;
; (1) Program specific constants
;
; We use a few extra bytes here in low memory.  Since we can't possibly
; be running while the COMM app is running, we have no chance of
; conflicting with it's use of this memory.
;
BLINK_BUF       EQU     $5C     ; 3 Byte Buffer for the blink routine
;               EQU     $5D
;               EQU     $5E
CAT_SAVE        EQU     $5F     ; Temporary counter variable
COUNTER         EQU     $60     ; Temporary variable to hold the 
FLAGBYTE        EQU     $61
;   Bit 0 indicates that the display does not need to be cleared
;   The other bits are not used

CURRENT_MODE    EQU     $62     ; The current mode that we are in
MODE_SELECT     EQU     0       ; Set mode, selecting which category to modify
MODE_HUNDREDS   EQU     1       ; Set mode, changing the hundreds of dollars digits
MODE_DOLLARS    EQU     2       ; Set mode, changing the dollars digits
MODE_CENTS      EQU     3       ; Set mode, changing the cents
MODE_ACTION     EQU     4       ; Set mode, changing the action
MODE_VIEW       EQU     5       ; Normal display mode

CATEGORY        EQU     $63     ; Current category 
;
; These three bytes need to be contiguous.  The represent the current
; value that is being operated on
;
HUNDREDS        EQU     $64
DOLLARS         EQU     $65
CENTS           EQU     $66

ACTION          EQU     $67     ; Selector for the current action
ACT_ADD         EQU     0
ACT_SUB         EQU     1
ACT_SET         EQU     2
ACT_CLEAR       EQU     3
AMT_BASE        EQU     $F0
;
;
; (2) System entry point vectors
;
START   EQU     *
L0110:  jmp     MAIN    ; The main entry point - WRIST_MAIN
L0113:  rts             ; Called when we are suspended for any reason - WRIST_SUSPEND
        nop
        nop
L0116:  jmp     DO_UPD  ; Called to handle any timers or time events - WRIST_DOTIC
L0119:  rts             ; Called when the COMM app starts and we have timers pending - WRIST_INCOMM
        nop
        nop
L011c:  rts             ; Called when the COMM app loads new data - WRIST_NEWDATA
        nop
        nop

L011f:  lda     STATETAB0,X ; The state table get routine - WRIST_GETSTATE
        rts

L0123:  jmp     HANDLE_STATE
        db      STATETAB0-STATETAB0
L0127:  jmp     HANDLE_STATE
        db      STATETAB1-STATETAB0
;
; (3) Program strings
;
; These strings represent the 4 possible actions.  They need to be early on in the data segment so that
; then can be pointed to by using 8-bit offset addressing.  They are exactly 3 bytes long and are
; displayed by using the BLINK_TZONE routine
;
S3_MODE:
S3_ADD          timex   "ADD"
S3_SUB          timex   "SUB"
S3_SET          timex   "SET"
S3_CLR          timex   "CLR"
;
; These are the categories that the end user has configured.  They are set by using the SPENDSET program
; which searches for the first string "TOTAL   ".  These strings must be exactly 8 bytes each in order with
; total being the first one.
;
S8_TOTAL:       timex   "TOTAL   "
S8_CAT1:        timex   "CAT1    "
S8_CAT2:        timex   "CAT2    "
S8_CAT3:        timex   "CAT3    "
S8_CAT4:        timex   "CAT4    "
S8_CAT5:        timex   "CAT5    "
S8_CAT6:        timex   "CAT6    "
S8_CAT7:        timex   "CAT7    "
;
; These are the running amounts for each category.  Note that you can actually
; initialize them with some default and the code will run properly
;
AMT_TOTAL:      db      0,0,0
AMT_CAT1:       db      0,0,0
AMT_CAT2:       db      0,0,0
AMT_CAT3:       db      0,0,0
AMT_CAT4:       db      0,0,0
AMT_CAT5:       db      0,0,0
AMT_CAT6:       db      0,0,0
AMT_CAT7:       db      0,0,0
;
; These strings prompt for the current mode that we are in.  They are displayed on the top line of
; the display.
;
S6_SELECT       timex6  "SELECT"
S6_AMOUNT       timex6  "AMOUNT"
S6_ACTION       timex6  "ACTION"
S6_SPEND:       timex6  "SPEND"         ; save a byte by leaching off the space on the start of the next string
S6_WATCH:       timex6  " WATCH"
;
; This table selects which string is to be displayed.  It is directly indexed by the current mode
;
MSG_TAB         db      S6_SELECT-START ; 0 - MODE_SELECT  
                db      S6_AMOUNT-START ; 1 - MODE_HUNDREDS
                db      S6_AMOUNT-START ; 2 - MODE_DOLLARS 
                db      S6_AMOUNT-START ; 3 - MODE_CENTS   
                db      S6_ACTION-START ; 4 - MODE_ACTION  
                db      S6_SPEND-START  ; 5 - MODE_VIEW
;
; This is one of the magic tricks for providing the source for the blink routine.
; These are base pointers (offset from HUNDREDS) that we use to copy three bytes into
; BLINK_BUF.  The interesting one here is the MODE_CENTS entry which points to DATDIGIT1
; This works because the last number that we format happens to be the cents amount,
; and the blink routine expects the two characters instead of the actual value.
;
DATASRC         db      HUNDREDS-HUNDREDS       ; 1 - MODE_HUNDREDS
                db      DOLLARS-HUNDREDS        ; 2 - MODE_DOLLARS 
                db      DATDIGIT1-HUNDREDS      ; 3 - MODE_CENTS   
                db      S3_ADD-HUNDREDS         ; 4 - MODE_ACTION  0 - ACT_ADD
                db      S3_SUB-HUNDREDS         ; 4 - MODE_ACTION  1 - ACT_SUB
                db      S3_SET-HUNDREDS         ; 4 - MODE_ACTION  2 - ACT_SET
                db      S3_CLR-HUNDREDS         ; 4 - MODE_ACTION  3 - ACT_CLR
;
; This is the parameter to select which blink routine we want to use
;
BLINK_PARM      db      BLINK_MID12     ; 1 - MODE_HUNDREDS
                db      BLINK_MID34     ; 2 - MODE_DOLLARS
                db      BLINK_SECONDS   ; 3 - MODE_CENTS
                db      BLINK_TZONE     ; 4 - MODE_ACTION
;
; (4) State Tables
;
; This set of state tables is a little special since we actually use the
; same state processing routine for both states.  This saves us a lot of
; memory but still allows us to let the state table make it easy to exit
; the app with the MODE button
;
STATETAB0:
        db      0
        db      EVT_ENTER,TIM2_12TIC,0          ; Initial state
        db      EVT_RESUME,TIM_ONCE,0           ; Resume from a nested app
        db      EVT_TIMER2,TIM_ONCE,0           ; This is the timer
        db      EVT_MODE,TIM_ONCE,$FF           ; Mode button
        db      EVT_SET,TIM_ONCE,1              ; Set button
        db      EVT_DNANY4,TIM_ONCE,0           ; NEXT, PREV, SET, MODE button pressed
        db      EVT_END
        
STATETAB1:
        db      1
        db      EVT_RESUME,TIM_ONCE,1           ; Resume from a nested app
        db      EVT_DNANY4,TIM_ONCE,1           ; NEXT, PREV, SET, MODE button pressed
        db      EVT_UPANY4,TIM_ONCE,1           ; NEXT, PREV, SET, MODE button released
        db      EVT_USER2,TIM_ONCE,0            ; Return to state 0
        db      EVT_END                         ; End of table
;
; (5) Put up the initial banner screen
;
HANDLE_ENTER
        clra
        sta     CATEGORY                        ; We start out displaying the totals
        jsr     FETCH_CATEGORY
        jsr     CLEARALL                        ; Clear the display
        lda     #S6_SPEND-START                 ; Put 'SPEND ' on the top line
        jsr     PUT6TOP
        lda     #S6_WATCH-START                 ; Put ' WATCH' on the second line
        jsr     PUT6MID
        clr     FLAGBYTE                        ; Force us to clear the display
        lda     #MODE_VIEW                      ; Start out in the VIEW mode
        sta     CURRENT_MODE
        lda     #SYS8_MODE                      ; Put MODE on the bottom line
        jmp     PUTMSGBOT
;
; (6) This is the main screen update routine.
;---------------------------------------------------------------
; Routine:
;   SHOWCURRENT
; Parameters:
;   HUNDREDS,DOLLARS,CENTS - Current value to be displayed
;   0,FLAGBYTE - Screen state (CLR=Must clear it first)
;   CATEGORY - the current category to be displayed
; Returns:
;   DATDIGIT1,DATDIGIT2 - 2 digit characters for the cents value
; Purpose:
;   This routine shows the current selected category and value for the category
;---------------------------------------------------------------
SHOWCURRENT
        brset   0,FLAGBYTE,NOCLEAR              ; If we don't need to clear the display, skip it
        jsr     CLEARALL                        ; Clear the display
        bset    0,FLAGBYTE                      ; And remember that we did it
NOCLEAR
        lda     #ROW_MP45                       ; Turn on the decimal point
        sta     DISP_ROW
        bset    COL_MP45,DISP_COL
        ldx     HUNDREDS                        ; Get the Hundreds
        jsr     FMTBLANK0                       ;   Format it
        jsr     PUTMID12                        ;   and display it
        ;
        ; We want to output the dollars, but if there were no hundreds, we want to let the
        ; first digit be a blank.  To do this, we simply let it be a blank and set it to a zero
        ; if there was actually anything in the hundreds field
        ;
        ldx     DOLLARS                         ; Get the Dollars
        jsr     FMTX                            ;   Format it
        tst     HUNDREDS                        ; Do we need to have a leading zero?
        beq     NOBLANKIT                       ; No, so it is fine
        ldx     DOLLARS                         ; Yes, Get the Dollars again
        jsr     FMTXLEAD0                       ;   And format it with a leading zero
NOBLANKIT
        jsr     PUTMID34                        ;   Display the Dollars
        ldx     CENTS                           ; Get the Cents
        jsr     FMTXLEAD0                       ;   Format it (and leave it around for later)
        jsr     PUTMID56                        ;   and display it.
        lda     CATEGORY                        ; Get which category we want
        lsla                                    ;  *2
        lsla                                    ;  *4
        lsla                                    ;  *8
        add     #S8_TOTAL-START                 ; *8+the start of the string
        jmp     BANNER8                         ;  and display the right string
;
; (7) State Table 0 and 1 Handler
; This is called to process the state events.
; We see SET, RESUME, DNANY4, and UPANY4 events
;
HANDLE_STATE:
        bset    1,APP_FLAGS                     ; Indicate that we can be suspended
        lda     BTNSTATE                        ; Get the event
        cmp     #EVT_ENTER                      ; Is this the initial state?
        beq     HANDLE_ENTER
        cmp     #EVT_DNANY4                     ; How about a button pressed?
        beq     HANDLE_DNANY
        bclr    1,BTNFLAGS                      ; Turn off the repeat counter
        cmp     #EVT_SET                        ; Did they press the set button
        bne     SKIP2                           ; No
        clr     CURRENT_MODE                    ; Yes, Go to MODE_SELECT
SKIP2   bra     GOREFRESH
;
; (8) They pressed a button, so handle it
;
HANDLE_DNANY
        lda     BTN_PRESSED                     ; Let's see what the button they pressed was
        beq     DO_NEXT                         ; MODE=1, and NEXT=0, so if it is less, it must be the next button
        cmp     #EVT_SET                        ; MODE=1 SET=2 PREV=3, test all at once
        blo     DO_MODE                         ; <2 = 1 so we have a EVT_MODE
        bhi     DO_PREV                         ; >2 = 3 so we have a EVT_PREV
        ;
        ; They pressed the set button, so we want to carry out the operation IF they have
        ; one currently selected.
        ;
DO_SETOUT
        lda     CURRENT_MODE                    ; See what mode we were in
        cmp     #MODE_ACTION                    ; Is it the ACTION mode?
        bne     NO_ACTION                       ; No, so just cancel the operation
        jsr     DO_OPERATION                    ; Do what they requested
        jsr     DO_TOTAL                        ; And total up everything
        jsr     PLAYCONF                        ; Plus tell them that we did it
NO_ACTION
        bclr    0,FLAGBYTE                      ; We need to clear the display
        lda     #MODE_VIEW                      ; And switch back to VIEW mode
        sta     CURRENT_MODE
        lda     #EVT_USER2                      ; And go back to state 0
        jmp     POSTEVENT
;
; (9) This handles the update routine to change a digit...
;
DO_NEXT
        bset    0,SYSFLAGS                      ; Mark our update direction as up
        BRSKIP2                                 ; and skip over the next instruction
DO_PREV
        bclr    0,SYSFLAGS                      ; Mark our update direction as down
DO_UPD
        lda     CURRENT_MODE                    ; Which mode are we in?
        beq     CHANGE_CATEGORY                 ; 0=MODE_SELECT, so change the category
        cmp     #MODE_VIEW                      ; 5=MODE_VIEW, so we also change the category
        bne     TRYOTHERS
CHANGE_CATEGORY
; (10) updating the category
        ldx     #CATEGORY                       ; Point to the category variable
        lda     #7                              ; get our range of values
        bsr     ADJUST_PX_ANDA                  ; And let the routine do the adjust for us
        jsr     FETCH_CATEGORY                  ; Update the current amount from the new category
GOREFRESH
        bra     REFRESH
;
; (11) ADJUST_PX_ANDA - a routine to adjust a value based on the direction
;---------------------------------------------------------------
; Routine:
;   ADJUST_PX_ANDA
; Parameters:
;   A - Binary range to limit value within ((2**x)-1)
;   0,SYSFLAGS - Direction to adjust, SET=UP
;   X - Pointer to value to be adjusted
; Returns:
;   Value pointed to by X is adjusted
; Purpose:
;   This routine adjusts a value up or down based on the current direction, wrapping 
;   it to the binary range indicated by the value in A.  Note that this value must
;   be a power of 2-1 (e.g. 1, 3, 7, 15, 31, 63, or 127)
;---------------------------------------------------------------
ADJUST_PX_ANDA
        inc     ,X
        brset   0,SYSFLAGS,NODEC
        dec     ,X
        dec     ,X
NODEC   and     ,X
        sta     ,X
        rts
;
; (12) Try updating one of the other modes
; We have already handled MODE_SELECT and MODE_VIEW.  This code handles
; MODE_HUNDREDS, MODE_DOLLARS, MODE_CENTS, and MODE_ACTION
;
TRYOTHERS
        cmp     #MODE_CENTS                     ; 3=MODE_CENTS
        bls     TRYMORE                         ; If it is <=, then we leave only MODE_ACTION
; (13) updating the Action
        lda     CATEGORY                        ; Which category is it?
        beq     REFRESH                         ; If we are displaying the total, you can't change the action
        ldx     #ACTION                         ; Point to the current action
        lda     #3                              ; and the range of actions
        bsr     ADJUST_PX_ANDA                  ; and let our simple routine handle it for us
        bra     REFRESH
TRYMORE
        beq     DOCENTS                         ; If it is MODE_CENTS, go handle it
; (14) Update MODE_HUNDREDS=1 and MODE_DOLLARS=2
        clrx                                    ; Set the lower limit =0
        stx     UPDATE_MIN
        ldx     #99                             ; And the upper limit= 99
        stx     UPDATE_MAX
        add     #HUNDREDS-1                     ; Point to the right byte to update
        tax                                     ; And put it in X as the parameter
        lda     CURRENT_MODE                    ; MODE=1       MODE=2
        deca                                    ;    0           1
        lsla                                    ;    0           2
        add     #UPD_MID12                      ;  5=UPD_MID12 7=UPD_MID34
        jsr     START_UPDATEP                   ; And prepare the update routine   
        bset    4,BTNFLAGS                      ; Mark that the update is now pending
        rts
;
; (15) This is where we switch which digit we are changing...
;
DO_MODE
        lda     CURRENT_MODE                    ; Get the mode
        ldx     #MODE_ACTION                    ; Limit it to the first 5 modes
        jsr     INCA_WRAPX                      ; And let the system increment it for us
        sta     CURRENT_MODE                    ; Save it back
        ; When we switch to the ACTION mode and we have the Totals category showing,
        ; we need to limit them to the single action of CLEAR
        ;
        cmp     #MODE_ACTION                    ; Did we go to action mode?
        bne     REFRESH                         ; No, nothing to do
        clr     ACTION                          ; Reset the action to be add
        tst     CATEGORY                        ; Are we displaying the totals
        bne     REFRESH                         ; No, nothing more to do
        lda     #ACT_CLEAR                      ; Yes, switch them to CLEAR
        sta     ACTION
;
; (16) Refresh the screen and start blinking the current digit...
;
REFRESH
        ; 0 - SELECT   <Category>
        ; 1 - AMOUNT    (Blink hundreds)
        ; 2 - AMOUNT    (Blink dollars)
        ; 3 - AMOUNT    (Blink cents)
        ; 4 - ACTION    
        jsr     SHOWCURRENT                     ; Format the screen
        ldx     CURRENT_MODE                    ; Get the mode
        lda     MSG_TAB,X                       ; So that we can get the message for it
        jsr     PUT6TOP                         ; And put that on the top of the display
        ;
        ; Now we need to make the right thing blink
        ;
        ldx     CURRENT_MODE                    ; Are we in Select mode?
        beq     NOBLINK2                        ; Yes, don't blink anything
        cpx     #MODE_ACTION                    ; How about ACTION MODE?
        bhi     NOBLINK2                        ; >ACTION is VIEW mode, so if so, don't blink either
        ; 1 -> BLINK_MID12    PARM=&HUNDREDS
        ; 2 -> BLINK_MID34    PARM=&DOLLARS
        ; 3 -> BLINK_SECONDS  PARM=&2Characters
        ; 4 -> BLINK_TZONE    PARM=&3Characters
        brset   1,BTNFLAGS,NOBLINK2             ; Also, we don't want to be blinking if we are in an update routine
        bne     SETUP_BLINK                     ; If we were not in action mode, we have the right data source
        ; Put a > on the display
        ldx     #C_RIGHTARR                     ; Put a > sign right in front of the action
        lda     #POSL3_5
        jsr     PUTLINE3
        lda     CURRENT_MODE                    ; Get the mode
        add     ACTION                          ; And add in the action
        tax                                     ; To compute our data source pointer
SETUP_BLINK
;
; (17) Set up the parameters for and call the blink routine
;
        ldx     DATASRC-1,X                     ; Get the offsetted pointer to the right data
        lda     HUNDREDS,X                      ; And copy the 3 bytes to our blink buffer
        sta     BLINK_BUF
        lda     HUNDREDS+1,X
        sta     BLINK_BUF+1
        lda     HUNDREDS+2,X
        sta     BLINK_BUF+2
        ldx     CURRENT_MODE                    ; Get our mode again
        lda     BLINK_PARM-1,X                  ; and use it to pick up which parameter we are passing
        ldx     #BLINK_BUF                      ; Point to the common blink buffer
        jsr     START_BLINKP                    ; And do it
        bset    2,BTNFLAGS                      ; Mark a blink routine as pending
NOBLINK2
        rts
;
; (18) Update MODE_CENTS
; This is a special case since we don't have a system routine that allows updating
; the right most digits on the middle line.  Fortunately we can fake it by turning
; on the tic timer and waiting until 8 tics have passed before going into a repeat
; loop.  The code has been carefully constructed so that the tic timer can just go
; straight to the DO_UPD code to work.
DOCENTS
        ldx     #COUNTER                        ; Point to the counter (saves code size)
        brset   1,BTNFLAGS,NOSTART              ; Are we already in an update loop?
        lda     #8                              ; No, we need to wait 8 tics
        sta     ,X      ; X->COUNTER            ; Save the value
        BSET    1,BTNFLAGS                      ; and start the timer
        bra     DOIT                            ; But still do it once right now
;
DEC_DELAY                                       
        dec     ,X      ; X->COUNTER            ; We haven't hit the limit, decrement it and try again
        rts
NOSTART
        tst     ,X      ; X->COUNTER            ; We are in the loop, have we hit the limit?
        bne     DEC_DELAY                       ; no, go off and delay once more
DOIT
        lda     #99                             ; Our upper limit is 99
        ldx     #CENTS                          ; Point to the cents variable (saves code size)
        brset   0,SYSFLAGS,UPCENTS              ; Are we in an up mode?
        dec     ,X      ; X->CENTS              ; Down, decrement the value
        bpl     REFRESH                         ; If we didn't wrap, just go display it
        sta     ,X      ; X->CENTS              ; We wrapped, save the upper limit
        bra     REFRESH                         ; and go display it
UPCENTS
        inc     ,X      ; X->CENTS              ; Up, increment the value
        cmp     ,X      ; X->CENTS              ; Did we hit the limit?
        bpl     REFRESH                         ; No, go display it
        clr     ,X      ; X->CENTS              ; Yes, wrap to the bottom
        bra     REFRESH                         ; and display it
;
; (19) DO_OPERATION - Perform the requested operation
;---------------------------------------------------------------
; Routine:
;   DO_OPERATION
; Parameters:
;    HUNDREDS,DOLLARS,CENTS - Amount to be added/subtracted/set
;    CATEGORY - Item to be updated
;    ACTION - 0 = ACT_ADD
;             1 = ACT_SUB
;             2 = ACT_SET
;             3 = ACT_CLEAR
; Purpose:
;   Adjusts the corresponding category by the given amount
;---------------------------------------------------------------
DO_OPERATION
        lda     CATEGORY                        ; Get our category
        bsr     COMPUTE_BASE                    ; And point to the data for it
        lda     ACTION                          ; Which action is it?
        beq     DO_ADD                          ; 0=ADD, go do it
        cmp     #ACT_SET                        ; 3 way compare here... (code trick)
        beq     DO_SET                          ; 2=SET, go do it
        blo     DO_SUB                          ; <2=1 (SUB), go do it
DO_CLR                                          ; >2 = 3 (CLEAR)
        clr     HUNDREDS                        ; Clear out the current values
        clr     DOLLARS
        clr     CENTS
        tst     CATEGORY                        ; Were we clearing the total?
        bne     DO_SET                          ; No, just handle it
        ;
        ; They want to clear everything
        ;
        ldx     #(3*8)-1                        ; Total number of categories
CLEAR_TOTALS
; Mini Routine here X=number of bytes to clear
        clra
CLR_MORE
        sta     AMT_TOTAL,X                     ; Clear out the next byte
        decx                                    ; Decrement the number to do
        bpl     CLR_MORE                        ; And go for more
        rts
;
; (20) Handle Subtracting a value
;
DO_SUB
        neg     HUNDREDS                        ; Just negate the value to be added
        neg     DOLLARS
        neg     CENTS                           ; And fall into the add code
;
; (21) Handle Adding a value
;
DO_ADD
        lda     CENTS                           ; Add the cents
        add     AMT_BASE+2,X
        sta     CENTS
        lda     DOLLARS                         ; Add the dollars
        add     AMT_BASE+1,X
        sta     DOLLARS
        lda     HUNDREDS                        ; Add the hundreds
        add     AMT_BASE,X
        sta     HUNDREDS
        ldx     #CENTS                          ; Point to the cents as it will be the first one we fix up
        tst     ACTION                          ; See what type of operation we just did
        beq     FIXUP_ADD                       ; Was it an ADD? If so, do do it
        bsr     TRYDEC                          ; Decrement, fix up the Cents
        bsr     TRYDEC                          ; Then fix up the dollars
        lda     HUNDREDS                        ; Did the hundreds underflow as a result?
        bmi     DO_CLR                          ; Yes, so just set everything to zero
        bra     DO_SET                          ; No, so copy over the values to the current entry
TRYDEC
        lda     ,X                              ; Get the current byte to check
        bpl     RETDEC                          ; If it didn't underflow, then skip to the next byte
        add     #100                            ; Add back the 100 that it underflowed
        sta     ,X                              ; And save that away
        decx                                    ; Back up to the next most significant byte
        dec     ,X                              ; and borrow the one
        rts
RETDEC  decx                                    ; No need to do anything, so skip to the next byte
        rts
TRYADD
        lda     ,X                              ; Get the current byte to check
        sub     #100                            ; See if it was less than 100
        bmi     RETDEC                          ; If so, then it was already normalized so skip out
        sta     ,X                              ; It was an overflow, so save the fixed value
        decx                                    ; Skip to the next byte
        inc     ,X                              ; And add in the overflow
        rts

FIXUP_ADD
        bsr     TRYADD                          ; Fix up the cents
        bsr     TRYADD                          ; and then fix up the dollars
;
; (22) Handle setting a value
;
DO_SET
        bsr     COMPUTE_CATEGORY_BASE           ; Point to the data for our category
        lda     HUNDREDS                        ; Copy over the values to the current category
        sta     AMT_BASE,X
        lda     DOLLARS
        sta     AMT_BASE+1,X
        lda     CENTS
        sta     AMT_BASE+2,X
        rts
;
; (23) COMPUTE_BASE - Computes an offset pointer to get to the total amounts
; This is a trick to save us a few bytes in the instructions.
;---------------------------------------------------------------
; Routine:
;   COMPUTE_BASE
; Parameters:
;   A - Offset into total
; Returns:
;   X - Pointer relative to AMT_BASE to use
; Purpose:
;   Computes an offset pointer to get to the total amounts
;---------------------------------------------------------------
COMPUTE_CATEGORY_BASE
        lda     CATEGORY                        ; Get our category
COMPUTE_BASE
        ldx     #3
        mul
        add     #AMT_TOTAL-AMT_BASE
        tax
        rts
;
; (24) This is the main initialization routine which is called when we first get the app into memory
;
MAIN:
        lda     #$c0                            ; We want button beeps and to indicate that we have been loaded
        sta     WRISTAPP_FLAGS
        ; Fall into DO_TOTAL
;
; (25) DO_TOTAL - Recomputes the current total
;---------------------------------------------------------------
; Routine:
;   DO_TOTAL
; Parameters:
;   NONE
; Purpose:
;   Recomputes the current total
;---------------------------------------------------------------
DO_TOTAL
        lda     CATEGORY                        ; Remember our category
        sta     CAT_SAVE
        clr     ACTION                          ; Say that we want to add 0=ACT_ADD
        clr     CATEGORY                        ; To the total category
        ldx     #2                              ; But we need to clear it first
        bsr     CLEAR_TOTALS
        lda     #7                              ; And iterate over the 7 categories
        sta     COUNTER
TOT_LOOP
        lda     COUNTER                         ; Get our current category
        bsr     FETCH_CATEGORY                  ; And fetch the data
        jsr     DO_OPERATION                    ; Then add it to the total
        dec     COUNTER                         ; Go to the next category
        bne     TOT_LOOP                        ; Until we are done
        lda     CAT_SAVE                        ; Restore the category
        sta     CATEGORY
        ; fall into FETCH_CATEGORY
; (26) FETCH_CATEGORY - Retrieves the value of the total amount for the selected category
;---------------------------------------------------------------
; Routine:
;   FETCH_CATEGORY
; Parameters:
;   A - Category to be fetched
; Returns:
;   HUNDREDS,DOLLARS,CENTS - Current value of selected category
; Purpose:
;   Retrieves the value of the total amount for the selected category
;---------------------------------------------------------------
FETCH_CATEGORY
        bsr     COMPUTE_BASE                    ; Get the pointer to the base
        lda     AMT_BASE,X                      ; And retrieve the data
        sta     HUNDREDS
        lda     AMT_BASE+1,X
        sta     DOLLARS
        lda     AMT_BASE+2,X
        sta     CENTS
        rts
;--------------------END OF CODE---------------------------------------------------
