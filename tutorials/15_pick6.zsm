;Name: PICK6
;Version: PICK6
;Description: A sample lottery number picker to pick 6 numbers out of a pool of 49 numbers (no duplicates allowed).
;  To use it, just select it as the current app and it will pick a set of 6 numbers for you.  To get another set,
;  just press the next button.  This is for amusement only (but if you win anything because of it, I would welcome
;  anything that you send me).
;
;by John A. Toebes, VIII
;
;HelpFile: watchapp.hlp
;HelpTopic: 100
;****************************************************************************************
;* Copyright (C) 1997 John A. Toebes, VIII                                              *
;* All Rights Reserved                                                                  *
;* This program may not be distributed in any form without the permission of the author *
;*         jtoebes@geocities.com                                                        *
;****************************************************************************************
; (1) Program specific constants
;
            INCLUDE "WRISTAPP.I"
;
; Program specific constants
;
RAND_RANGE      EQU     48      ; This is the number of items to select from (1 to RAND_RANGE+1)
CURRENT_TIC     EQU     $27     ; Current system clock tic (Timer)
RAND_WCL        EQU     $61
RAND_WCH        EQU     $62
RAND_WNL        EQU     $63
RAND_WNH        EQU     $64
THIS_PICK       EQU     $65     ; We can share this with MARQ_POS since we don't do both at the same time
MARQ_POS        EQU     $65
TEMPL           EQU     $66
TEMPH           EQU     $67
START           EQU   *
BASE_TAB        EQU     $FE
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
S6_MARQ timex6  "   +O+   "
S8_TITLE timex  " PICK-6 "

MARQ_SEL
        DB      S6_MARQ+2-START
        DB      S6_MARQ+3-START
        DB      S6_MARQ+2-START
        DB      S6_MARQ+1-START
        DB      S6_MARQ-START
        DB      S6_MARQ+1-START
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

PICK_VALS       db      0,0,0,0,0,0,0,$FF
;
; (5) This flashes the text on the screen
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
        jsr     PUT6MID
        ldx     MARQ_POS
        lda     MARQ_SEL,X
        jmp     PUT6TOP
;
; (6) They want us to do it again
;
DOITAGAIN                       ; Tell them we are going to do it again
        clr     MARQ_POS
        bset    1,BTNFLAGS
        jsr     CLEARALL
        jmp     BANNER
;
; (7) State Table 0 Handler
; This is called to process the state events.
; We see ENTER, RESUME, TIMER2 and NEXT events
;        
HANDLE_STATE0:
        bset    1,APP_FLAGS             ; Indicate that we can be suspended
        bclr    1,BTNFLAGS
        lda     BTNSTATE
        cmp     #EVT_DNNEXT             ; Did they press the next button?
        beq     DOITAGAIN
        cmp     #EVT_ENTER              ; Or did we start out
        beq     DOITAGAIN
        cmp     #EVT_RESUME             
        beq     REFRESH
;
; (8) Select a random answer
;
SHOWIT
        clra
        ldx     #6
CLEARIT 
        sta     PICK_VALS-1,X
        decx
        bne     CLEARIT
;
; We want to pick 6 random numbers.  The first needs to be in the range 1 ... RAND_RANGE
; The second should be in the range 1 ... (RAND_RANGE-1)
; The third should be in the range 1 ... (RAND_RANGE-2)
; The fourth should be in the range 1 ... (RAND_RANGE-3)
; The fifth should be in the range 1 ... (RAND_RANGE-4)
; The sixth should be in the range 1 ... (RAND_RANGE-5)
;
        clr     THIS_PICK
ONE_MORE_PICK

REPICK
        jsr     RAND16
        and     #63
        sta     TEMPL
        lda     #RAND_RANGE
        sub     THIS_PICK
        cmp     TEMPL
        blo     REPICK
        lda     TEMPL
        bsr     INSERT_NUM

        inc     THIS_PICK
        lda     THIS_PICK
        cmp     #6
        bne     ONE_MORE_PICK
        bra     REFRESH
;
; (9) Insert a number in the list
;
INSERT_NUM
        inca
        ldx     #(PICK_VALS-1)-BASE_TAB   ; Index so that we can use the short addressing mode
TRY_NEXT
        incx                            ; Advance to the next number
        tst     BASE_TAB,X              ; Is it an empty slot?
        bne     NOT_END                 ; No, try some more
        sta     BASE_TAB,X              ; Yes, just toss it in there
        rts                             ; And return
NOT_END
        cmp     BASE_TAB,X              ; Non-empty slot, are we less than it?
        blo     PUT_HERE                ; Yes, so we go here
        inca                            ; No, Greater than or equal, we need to increment one and try again
        bra     TRY_NEXT
PUT_HERE
        sta     TEMPL
        lda     BASE_TAB,X
        sta     TEMPH
        lda     TEMPL
        sta     BASE_TAB,X
        lda     TEMPH
        incx
        tsta
        bne     PUT_HERE
        rts
;
; (10) Display the currently selected random numbers
;
REFRESH
        ldx     PICK_VALS
        bsr     GOFMTX
        jsr     PUTTOP12

        ldx     PICK_VALS+1
        bsr     GOFMTX
        jsr     PUTTOP34

        ldx     PICK_VALS+2
        bsr     GOFMTX
        jsr     PUTTOP56

        ldx     PICK_VALS+3
        bsr     GOFMTX
        jsr     PUTMID12

        ldx     PICK_VALS+4
        bsr     GOFMTX
        jsr     PUTMID34

        ldx     PICK_VALS+5
        bsr     GOFMTX
        jsr     PUTMID56

        lda     #ROW_MP23
        sta     DISP_ROW
        bset    COL_MP23,DISP_COL

        lda     #ROW_MP45
        sta     DISP_ROW
        bset    COL_MP45,DISP_COL

        lda     #ROW_TP23
        sta     DISP_ROW
        bset    COL_TP23,DISP_COL

        lda     #ROW_TP45
        sta     DISP_ROW
        bset    COL_TP45,DISP_COL
BANNER
        lda     #S8_TITLE-START ; And show the mode on the bottom
        jmp     BANNER8

GOFMTX  JMP     FMTX
; (11) Here is an excellent random number generator
; it comes courtesy of Alan Beale <biljir@pobox.com%gt;
; The following C code gives a good MWC (multiply-with-carry)
; generator.  This type is generally superior to linear
; congruential generators.  As a bonus, there is no particular advantage to using the high-order
; rather than the low-order bits.
; The algorithm was developed and analyzed by George
; Marsaglia, a very well-known scholar of random number lore.
;
; The code assumes 16 bit shorts and 32 bit longs (hardly surprising).
;
;static unsigned short wn,wc;  /* random number and carry */
;
;unsigned short rand() {
;    unsigned long temp;
;    temp = 18000*wn + wc;
;    wc = temp >> 16;
;    wn = temp & 0xffff;
;    return wn;
;}
;
;To seed, set wn to anything you like, and wc to anything between 0 and 17999.
;
; Translating this into assembler is
;nHnL*0x4650 + RAND_WCHcL
;
;    unsigned long temp;
;    temp = 18000*wn + wc;
;    wc = temp >> 16;
;    wn = temp & 0xffff;
;    return wn;
;     temp = 0x4650 * n + c
;     temp = 0x4650 * nHnL + cHcL
;     temp = (0x4600 + 0x50) * (nH00 + nL) + cHcL
;     temp = 0x4600*nH00 + 0x4600*nL + 0x50*nH00 + 0x50*nL + cHcL
;     temp = 0x46*nH*0x10000 + 0x46*nL*0x100 + 0x50*nH*0x1000 + 0x50*nL + cHcL
; We construct the 32bit result into tH tL cH cL and then swap the 16 bit values
; once we have no more need of the original numbers in the calculation
;
RAND_MULT       EQU     18000   ; This is for the random number generator
RAND_MULTH      EQU     RAND_MULT/256
RAND_MULTL      EQU     RAND_MULT&255

RAND16
        lda     RAND_WNL        ; A=nL
        ldx     RAND_MULTL      ; X=0x50
        mul                     ; X:A = 0x50*nL
        add     RAND_WCL        ; A=Low(0x50nL)+cL
        sta     RAND_WCL        ; cL=Low(0x50nL)+cL
        txa                     ; A=High(0x50nL)
        adc     RAND_WCH        ; A=High(0x50nL)+cH
        sta     RAND_WCH        ; cH=High(0x50nL)+cH
        clra                    ; A=0
        sta     TEMPH           ; tH=0
        adc     #0              ; A=Carry(0x50nL)+cH
        sta     TEMPL           ; tL=Carry(0x50nL)+cH

        lda     RAND_WNL        ; A=nL
        ldx     RAND_MULTH      ; X=0x46
        bsr     RAND_SUB        ; tL:cH += 0x46*nL  tH=carry(0x46*nL)

        lda     RAND_WNH        ; A=nH
        ldx     RAND_MULTL      ; X=0x50
        bsr     RAND_SUB        ; tL:cH += 0x50*nH  tH=carry(0x50*nH)

        lda     RAND_WNH        ; A=nH
        ldx     RAND_WCL        ; X=cL
        stx     RAND_WNL        ; nL=cL
        ldx     RAND_WCH        ; X=cH
        stx     RAND_WNH        ; hH=cH
        ldx     RAND_MULTH      ; X=0x46
        mul                     ; X:A=0x46*nH
        add     TEMPL           ; A=Low(0x46*nH)+tL
        sta     RAND_WCL        ; nL=Low(0x46*nH)+tL
        txa                     ; A=High(0x46*nH)
        adc     TEMPH           ; A=High(0x46*nH)+tH
        sta     RAND_WCH        ; nH=High(0x46*nH)+tH
        rts

RAND_SUB
        mul                     ; Compute the values
        add     RAND_WCH        ; A=LOW(result)+cH
        sta     RAND_WCH        ; cH=Low(result)+cH
        txa                     ; X=High(result)
        adc     TEMPL           ; X=High(result)+tL+Carry(low(result)+cH)
        sta     TEMPL           ; tL=High(result)+tL+Carry(low(result)+cH)
        clra                    ; A=0
        adc     TEMPH           ; A=carry(High(result)+tL+Carry(low(result)+cH))+tH
        sta     TEMPH           ; tH=carry(High(result)+tL+Carry(low(result)+cH))+tH
        rts
;
; (12) This is the main initialization routine which is called when we first get the app into memory
;
MAIN:
        lda     #$c0            ; We want button beeps and to indicate that we have been loaded
        sta     WRISTAPP_FLAGS
        lda     CURRENT_TIC
        sta     RAND_WNL
        sta     RAND_WNH
        sta     RAND_WCL
        and     #$3f
        sta     RAND_WCH
        rts
