;Name: Day Finder
;Version: DAYFIND
;Description: This will allow you to determine the date for a given day of the week and vice-versa.
;by John A. Toebes, VIII
;
;Press the prev/next buttons to advance by a single day. Press SET to access the ability to advance/backup by
;weeks, months, days, and years.  The MODE button advances through those different states
;
;TIP:  Download your watch faster:  Download a WristApp once, then do not send it again.  It stays in the watch!
;HelpFile: watchapp.hlp
;HelpTopic: 106
            INCLUDE "WRISTAPP.I"
;
; (1) Program specific constants
;
FLAGBYTE        EQU     $61
B_CLEAR         EQU     0       ; Bit 0 indicates that we need to clear the display first
B_SCANUP        EQU     1       ; Bit 1 indicates that we are scanning up
B_SCANNING      EQU     2       ; Bit 2 indicates that we are in a fake scanning mode
DIGSEL          EQU     $62     ; Indicates which digit we are working on
                                ; 0 = DAY OF WEEK
                                ; 1 = Month
                                ; 2 = Day
                                ; 3 = Year
YEAR_DIG1       EQU     $63     ; This is the first digit of the year to blink (the tens digit)
YEAR_DIG2       EQU     $64     ; This is the second digit of the year to blink (the ones digit)
COUNTER         EQU     $65     ; A convenient counter for us to advance a week at a time
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
;
; (3) Program strings
S6_DAY          timex6  "DAY "
S6_FIND         timex6  "  FIND"
S8_TOEBES       timex   "J.TOEBES"
S8_DAYFIND      timex   "DAY FIND"
S8_WEEK         db      C_LEFTARR
                timex   " WEEK "
                db      C_RIGHTARR
S8_MONTH        db      C_LEFTARR
                timex   "MONTH "
                db      C_RIGHTARR
S8_DAY          db      C_LEFTARR
                timex   " DAY  "
                db      C_RIGHTARR
S8_YEAR         db      C_LEFTARR
                timex   " YEAR "
                db      C_RIGHTARR
;
; (4) State Table
;
STATETAB0:
        db      0
        db      EVT_ENTER,TIM1_4TIC,0           ; Initial state
        db      EVT_TIMER1,TIM_ONCE,0           ; The timer from the enter event
        db      EVT_RESUME,TIM_ONCE,0           ; Resume from a nested app
        db      EVT_MODE,TIM_ONCE,$FF           ; Mode button
        db      EVT_SET,TIM_ONCE,1              ; SET button pressed
        db      EVT_DNNEXT,TIM2_8TIC,0          ; NEXT button pressed
        db      EVT_DNPREV,TIM2_8TIC,0          ; PREV button pressed
        db      EVT_UPANY4,TIM_ONCE,0           ; The
        db      EVT_TIMER2,TIM2_TIC,0           ; The timer for the next/prev button pressed
        db      EVT_END

STATETAB1:
        db      1
        db      EVT_RESUME,TIM_ONCE,1           ; Resume from a nested app
        db      EVT_DNANY4,TIM_ONCE,1           ; NEXT, PREV, SET, MODE button pressed
        db      EVT_UPANY4,TIM_ONCE,1           ; NEXT, PREV, SET, MODE button released
        db      EVT_USER2,TIM_ONCE,0
        db      EVT_USER3,TIM2_8TIC,1           ;
        db      EVT_TIMER2,TIM2_TIC,1           ;
        db      EVT_END
;
; (5) State Table 0 Handler
; This is called to process the state events.
; We see ENTER, TIMER2, and RESUME events
;
HANDLE_STATE0:
        bset    1,APP_FLAGS                     ; Indicate that we can be suspended
        lda     BTNSTATE                        ; Get the event
        cmp     #EVT_DNNEXT
        beq     DO_NEXT0
        cmp     #EVT_DNPREV
        beq     DO_PREV0
        cmp     #EVT_TIMER2
        beq     DO_SCAN
        cmp     #EVT_ENTER                      ; Is this our initial entry?
        bne     REFRESH0
;
; This is the initial event for starting us up
;
DO_ENTER    
;
; (6) This code gets the current date from the system

        jsr     ACQUIRE                         ; Lock so that it doesn't change under us
        ldx     #TZ1_MONTH                      ; Assume that we are using the first timezone
        jsr     CHECK_TZ                        ; See which one we are really using
        bcc     COPY_TZ1                        ; If we were right, just skip on to do the work
        ldx     #TZ2_MONTH                      ; Wrong guess, just load up the second time zone
COPY_TZ1
        lda     0,x                             ; Copy out the month
        sta     SCAN_MONTH
        lda     1,x                             ; Day
        sta     SCAN_DAY
        lda     2,x                             ; and year
        sta     SCAN_YEAR
        jsr     RELEASE                         ; Unlock so the rest of the system is happy

        bclr    B_CLEAR,FLAGBYTE                ; Indicate that we need to clear the display
        clr     DIGSEL                          ; Start us off on the week advance
        jsr     CLEARSYM                        ; Clear the display
        lda     #S6_DAY-START
        jsr     PUT6TOP
        lda     #S6_FIND-START
        jsr     PUT6MID
        lda     #S8_TOEBES-START
        jmp     BANNER8

DO_SCAN
        brclr   B_SCANUP,FLAGBYTE,DO_PREV0      ; Were we scanning up or down?
DO_NEXT0
        bset    B_SCANUP,FLAGBYTE               ; We are now scanning up
        jsr     INCREMENT_SCAN_DATE             ; Advance to the next date
        bra     SHOW_DATE                       ; Comment this out and use the next one if you want
        ;  jmp     APPT_SHOW_SCAN               ; to put the text 'SCAN' on the bottom when we are in scan mode

DO_PREV0
        bclr    B_SCANUP,FLAGBYTE               ; We are now scanning down
        jsr     DECREMENT_SCAN_DATE             ; Back up to the previous date
        bra     SHOW_DATE                       ; Show the date on the screen.
        ;  jmp     APPT_SHOW_SCAN               ; Use this if you want 'SCAN' on the bottom of the display
;
; We come here for a RESUME or TIMER2 event.  For this we want to reset the display
;
REFRESH0
        brset   B_CLEAR,FLAGBYTE,NOCLEAR0       ; Do we need to clear the display first?
        bset    B_CLEAR,FLAGBYTE                ; Mark that the display has been cleared
        jsr     CLEARALL                        ; and do the work of clearing
NOCLEAR0
        lda     #S8_DAYFIND-START               ; Put up the name of the app on the display
        jsr     BANNER8
SHOW_DATE
        jsr     APPT_SHOW_DATE                  ; Show the date on the screen
        ldx     SCAN_YEAR                       ; as well as the year
        jmp     PUTYEARMID
;--------------------------------------------------------------------------------
; (7) State Table 1 Handler
; This is called to process the state events.
; We see SET, RESUME, USER3, TIMER2, DNANY4, and UPANY4 events
;  We use the USER3 to trigger a delay which fires off a TIMER2 sequence of events.
;  This allows us to have the PREV/NEXT buttons repeat for advancing the WEEK and YEAR
;  since we can't use the UPDATE routines for them.
;
HANDLE_STATE1:
        bset    1,APP_FLAGS                     ; Indicate that we can be suspended
        lda     BTNSTATE                        ; Get the event
        cmp     #EVT_TIMER2                     ; Was it a timer for a repeat operation?
        beq     DO_UPD                          ; Yes, go handle it
        cmp     #EVT_USER3                      ; Was it the USER3 event fired from the PREV/NEXT buttons?
        bne     TRY_UP                          ; No, try again
        rts                                     ; Yes, just ignore it, it will cause a timer to go off later
TRY_UP
        bclr    B_SCANNING,FLAGBYTE             ; We can't be scanning any more, so turn it off
        cmp     #EVT_UPANY4                     ; Was it any button being released?
        bne     TRY_DN                          ; No, try again
        jmp     REFRESH                         ; Yes, go refresh the screen (note that the branch is out of range)
TRY_DN
        cmp     #EVT_DNANY4                     ; Is this our initial entry?
        beq     GET_DN                          ; No, try again
        jmp     FORCEFRESH                      ; Yes, go setup the screen (note that the branch is out of range)
GET_DN
        lda     BTN_PRESSED                     ; Let's see what the button they pressed was
        cmp     #EVT_PREV                       ; How about the PREV button
        beq     DO_PREV                         ; handle it
        cmp     #EVT_NEXT                       ; Maybe the NEXT button?
        beq     DO_NEXT                         ; Deal with it!
        cmp     #EVT_MODE                       ; Perhaps the MODE button
        beq     DO_MODE                         ; If so, handle it
        ; It must be the set button, so take us out of this state
        lda     #EVT_USER2
        jmp     POSTEVENT
;
; (8) Our real working code...
; We come here when they press the next/prev buttons.  if we are in a timer repeat
; situation (triggered when they press prev/next for the WEEK/YEAR) then we skip right
; to processing based on the button that was previously pressed
;
DO_NEXT
        bset    0,SYSFLAGS                      ; Mark our update direction as up
        bra     DO_UPD
DO_PREV
        bclr    0,SYSFLAGS                      ; Mark our update direction as down
DO_UPD
        lda     DIGSEL                          ; Which digit mode are we in?
        beq     DO_UPD_DOW                      ; 0 - Handle the WEEK
        cmp     #2
        blo     DO_UPD_MONTH                    ; <2 = 1 - Handle the MONTH
        beq     DO_UPD_DAY                      ; 2 - Handle the Day
DO_UPD_YEAR                                     ; >2 = 3 - Handle the YEAR
        brclr   0,SYSFLAGS,LASTYEAR             ; Were we in the down direction?
        ldx     #99                             ; Going up, let the WRAPX routine handle it for us
        lda     SCAN_YEAR
        jsr     INCA_WRAPX
        bra     SAVEYEAR
LASTYEAR
        lda     SCAN_YEAR                       ; Going down, get the year
        deca                                    ; Decrement it
        bpl     SAVEYEAR                        ; and see if we hit the lower end
        lda     #99                             ; Yes, 2000 wraps down to 1999
SAVEYEAR
        sta     SCAN_YEAR                       ; Save away the new year
        bra     SETUP_LAG                       ; And fire off an event to allow for repeating

DO_UPD_DOW                                      ; 0 - Day of week
        lda     #7                              ; We want to iterate 7 times advancing by one day.
        sta     COUNTER                         ;  (this makes it much easier to handle all the fringe cases)
WEEKLOOP
        brclr   0,SYSFLAGS,LASTWEEK             ; Are we going backwards?
        jsr     INCREMENT_SCAN_DATE             ; Going forwards, advance by one day
        bra     WEEKLOOPCHK                     ; And continue the loop
LASTWEEK
        jsr     DECREMENT_SCAN_DATE             ; Going backwards, retreat by one day
WEEKLOOPCHK
        dec     COUNTER                         ; Count down
        tst     COUNTER                         ; See if we hit the limit
        bne     WEEKLOOP                        ; and go back for more
; (9) Fake repeater
; This code is used for the Day of week and year modes where we want to have a
; repeating button, but the system routines won't handle it for us
; It works by posting a USER3 event which has a timer of about 1/2 second.
; After that timer expires, we get a timer2 event which then repeats every tic.
; The only thing that we have to worry about here is to not go through this
; every time so that it takes 1/2 second for every repeat.
SETUP_LAG
        brset   B_SCANNING,FLAGBYTE,INLAG       ; If we were already scanning, skip out
        bset    B_SCANNING,FLAGBYTE             ; Indicate that we are scanning
        lda     #EVT_USER3                      ; and post the event to start it off
        jsr     POSTEVENT
INLAG
        jmp     SHOW_DATE                       ; Put the date up on the display
; (10) Update routine usage
DO_UPD_MONTH                                    ; 1 - Handle the month
        lda     #MONTH_JAN                      ; The bottom end is January
        sta     UPDATE_MIN
        lda     #MONTH_DEC                      ; and the top end is December (INCLUSIVE)
        sta     UPDATE_MAX
        lda     #UPD_HMONTH                     ; We want the HALF-MONTH udpate function
        ldx     #SCAN_MONTH                     ; To update the SCAN_MONTH variable
        bra     SEL_UPD                         ; Go do it
DO_UPD_DAY                                      ; 2 - Handle the day
        lda     #1                              ; 1 is the first day of the month
        sta     UPDATE_MIN
        jsr     GET_SCAN_MONTHLEN               ; Figure out how long the month is
        sta     UPDATE_MAX                      ; and make that the limit
        lda     #UPD_HDAY                       ; We want the HALF-DAY update function
        ldx     #SCAN_DAY                       ; to update the SCAN_DAY variable
SEL_UPD
        jsr     START_UPDATEP                   ; And prepare the update routine
        bset    4,BTNFLAGS                      ; Mark that the update is now pending
        rts
; (11) Making the mode button work
; when they press the mode button, we want to cycle through the various choices
; on the display.
DO_MODE
        lda     DIGSEL                          ; Figure out where we are in the cycle
        inca                                    ; advance to the next one
        and     #3                              ; and wrap at 4 to zero
        sta     DIGSEL
REFRESH
        brset   B_CLEAR,FLAGBYTE,NOCLEAR        ; Do we need to clear the display first?
FORCEFRESH
        jsr     CLEARALL                        ; Yes, clear everything before we start
        bset    B_CLEAR,FLAGBYTE                ; And remember that we have already done that
NOCLEAR
        clr     BTNFLAGS                        ; Turn off any scrolling banners
        lda     #ROW_TD23                       ; Turn off the dash from the week blink
        sta     DISP_ROW
        bclr    COL_TD23,DISP_COL
        jsr     SHOW_DATE                       ; Display the date
; (12) Establishing a blink routine
; This makes the appropriate section of the display blink based on what we are changing
        lda     DIGSEL                          ; Get the digit we are on
        beq     DO_BLINK_DOW                    ; 0 -> Update Day of week
        cmp     #2                              
        blo     DO_BLINK_MONTH                  ; <2 = 1 -> Update month
        beq     DO_BLINK_DAY                    ; 2 - Update day of month

DO_BLINK_YEAR   ;        3: Year
; (13) Calling BLINK_SECOND
; For BLINK_SECONDS, the UPDATE_PARM points to the 2 character format for the year.
        ldx     SCAN_YEAR                       ; Get our year
        jsr     GETBCDHI                        ; And extract out the high digit of it
        sta     YEAR_DIG1                       ; Save that away
        ldx     SCAN_YEAR                       ; Do it again
        jsr     GETBCDLOW                       ; to get the low digit
        sta     YEAR_DIG2                       ; and save that away
        ldx     #YEAR_DIG1                      ; the parm points to the first digit
        lda     #BLINK_SECONDS                  ; and we want a BLINK_SECONDS function
        bra     SETUP_BLINK                     ; so do it already

DO_BLINK_DOW    ;        0: Day of week:
; (14) Calling BLINK_SEGMENT
; Unfortunately, there is no blink routine to blink the upper two letters on the display.
; To get around this, I have chosen to blink a single segment on the display (the dash
; after the day of the week).  This routine was designed to blink the AM/PM or other
; symbols, but it works quite fine for our purposed.  You need to set UPDATE_POS to have
; the row to be updated and UPDATE_VAL holds the mask for the COLUMS to be XORed.
; In this way, you might have more than one segment blinking, but there are few segments
; on the same row which would achieve a reasonable effect. 
;            UPDATE_POS   ROW_TD23 
;            UPDATE_VAL   (1<<COL_TD23)
        lda     #ROW_TD23
; We want to blink the DASH after the day of week sta UPDATE_POS
; Store the ROW for it in UPDATE_POS lda #(1<<COL_TD23)
; Get the mask for the column sta UPDATE_VAL
; And store that in UPDATE_VAL lda #BLINK_SEGMENT
; We want a BLINK_SEGMENT function bra SETUP_BLINK
; and get to it.
DO_BLINK_MONTH         ; 1: Month
; (15) Calling BLINK_HMONTH, BLINK_HDAY
; These are the normal boring cases of calling the blink routine.  They simply need the
; address of the byte holding the value to blink and the function to blink them with.
;            UPDATE_PARM - Points to the month
        lda     #BLINK_HMONTH                   ; We want a BLINK HALF-MONTH function
        ldx     #SCAN_MONTH                     ; to blink our month
        bra     SETUP_BLINK                     ; and do it

DO_BLINK_DAY    ;       2: Day
;           UPDATE_PARM - Points to the day
        lda     #BLINK_HDAY                     ; We want a BLINK HALF-DAY function
        ldx     #SCAN_DAY                       ; to blink our day

SETUP_BLINK
        jsr     START_BLINKP                    ; Request the blink function
        lda     digsel                          ; Figure out which one we are blinking
        lsla                                    ; *2
        lsla                                    ; *4
        lsla                                    ; *8
        add     #S8_WEEK-START                  ; And use that to index the banner to put on the bottom
        jsr     BANNER8
        bset    2,BTNFLAGS                      ; Mark a blink routine as pending
        rts
;
; (16) This is the main initialization routine which is called when we first get the app into memory
;
MAIN:
        lda     #$c0                            ; We want button beeps and to indicate that we have been loaded
        sta     WRISTAPP_FLAGS
        clr     FLAGBYTE                        ; start with a clean slate
        rts
