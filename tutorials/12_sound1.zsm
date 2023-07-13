;Sound: Datalink Default
;Version: Sound1
;
; This sample corresponds to the default sounds that you get when you reset a datalink
; watch to its default state.
;
;****************************************************************************************
;* Copyright (C) 1997 John A. Toebes, VIII                                              *
;* All Rights Reserved                                                                  *
;* This program may not be distributed in any form without the permission of the author *
;*         jtoebes@geocities.com                                                        *
;****************************************************************************************
;
            INCLUDE "WRISTAPP.I"
;
; This is the default sound table
;
DEF_SOUNDS
        db      SP_1-SD_1       ; 0000: 08

        db      SD_1-DEF_SOUNDS ; 0001: 0b   BUTTON BEEP
        db      SD_2-DEF_SOUNDS ; 0002: 0c   RETURN TO TIME
        db      SD_3-DEF_SOUNDS ; 0003: 0d   HOURLY CHIME
        db      SD_4-DEF_SOUNDS ; 0004: 0e   CONFIRMATION
        db      SD_5-DEF_SOUNDS ; 0005: 0f   APPOINTMENT BEEP
        db      SD_5-DEF_SOUNDS ; 0006: 0f   ALARM BEEP
        db      SD_5-DEF_SOUNDS ; 0007: 0f   PROGRAM DOWNLOAD
        db      SD_5-DEF_SOUNDS ; 0008: 0f   EXTRA
        db      SD_6-DEF_SOUNDS ; 0009: 11   COMM ERROR
        db      SD_7-DEF_SOUNDS ; 000a: 12   COMM DONE
;
; This is the soundlet count table which contains the duration
; counts for the individual soundlets
;
SD_1    db      SND_END+1       ; 000b: 81
SD_2    db      SND_END+1       ; 000c: 81
SD_3    db      SND_END+2       ; 000d: 82
SD_4    db      SND_END+4       ; 000e: 84
SD_5    db      10,SND_END+40   ; 000f: 0a a8
SD_6    db      SND_END+10      ; 0011: 8a
SD_7    db      SND_END+32      ; 0012: a0
;
; This is the soundlet pointer table which contains the pointers to the soundlets
;
SP_1    db      SL_2-DEF_SOUNDS ; 0013: 1d
SP_2    db      SL_1-DEF_SOUNDS ; 0014: 1b
SP_3    db      SL_3-DEF_SOUNDS ; 0015: 1f
SP_4    db      SL_2-DEF_SOUNDS ; 0016: 1d
SP_5    db      SL_4-DEF_SOUNDS ; 0017: 22
        db      SL_5-DEF_SOUNDS ; 0018: 27
SP_6    db      SL_6-DEF_SOUNDS ; 0019: 2a
SP_7    db      SL_2-DEF_SOUNDS ; 001a: 1d
;
; These are the soundlets themselves.  The +1 or other number
; indicates the duration for the sound.
;
SL_1    db      TONE_HI_GSHARP+1                ; 001b: 91
        db      TONE_END                        ; 001c: 00

SL_2    db      TONE_MID_C+1                    ; 001d: 31
        db      TONE_END                        ; 001e: 00

SL_3    db      TONE_MID_C+2                    ; 001f: 32
        db      TONE_PAUSE+2                    ; 0020: f2
        db      TONE_END                        ; 0021: 00

SL_4    db      TONE_HI_C+2                     ; 0022: 22
        db      TONE_PAUSE+2                    ; 0023: f2
        db      TONE_HI_C+2                     ; 0024: 22
        db      TONE_PAUSE+10                   ; 0025: fa
        db      TONE_END                        ; 0026: 00

SL_5    db      TONE_HI_C+2                     ; 0027: 22
        db      TONE_PAUSE+2                    ; 0028: f2
        db      TONE_END                        ; 0029: 00

SL_6    db      TONE_HI_C+3                     ; 002a: 23
        db      TONE_MID_C+3                    ; 002b: 33
        db      TONE_END                        ; 002c: 00
;
; This is the tone that the comm app plays for each record
;
        db      TONE_MID_C/16                    ; 002d: 03
