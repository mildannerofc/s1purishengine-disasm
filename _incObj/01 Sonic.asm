; ===========================================================================
; ---------------------------------------------------------------------------
; Object 01 - Sonic
; ---------------------------------------------------------------------------

SonicPlayer:
		if ErrorTesting=1
		btst	#bitA,(v_jpadpress2).w		; is A pressed?
		beq.s	.noCrash			; if not, branch
		RaiseError "Intentional crash test"	; force a crash
.noCrash:
		endif
		if	CheatDeathDebug
		tst.w	(f_debugmode).w		; is debug cheat enabled?
		beq.s	Sonic_Normal		; if not, branch
		tst.w	(v_debuguse).w		; is debug mode already activated?
		jne	(DebugMode).l		; if yes, go to debug mode (bne.w doesn't reach)
		btst	#bitB,(v_jpadpress1).w	; was button B pressed this frame?
		beq.s	Sonic_Normal		; if not, branch
		cmpi.b	#8,obRoutine(a0)	; is routine set set to Sonic_ResetLevel?
		beq.s	Sonic_Normal		; if yes, don't allow debug mode to prevent glitches
		move.w	#1,(v_debuguse).w	; enter debug mode
		move.b	#2,obRoutine(a0)	; make sure Sonic is in the default routine
		clr.b	(f_lockctrl).w		; unlock controls
		clr.b	(f_playerctrl).w	; clear player override flags
		move.b	#1,(f_timecount).w	; restart time counter if necessary
		clr.b	(f_nobgscroll).w	; unlock camera after drowning
		clr.w	(v_sonicbubbles+objoff_2C).w ; abort drowning if necessary
		rts				; wait one frame before entering debug mode
		else
		tst.w	(v_debuguse).w	; is debug mode	being used?
		beq.s	Sonic_Normal	; if not, branch
		jmp	(DebugMode).l
		endif
; ===========================================================================

Sonic_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Sonic_Index(pc,d0.w),d1
		jmp	Sonic_Index(pc,d1.w)
; ===========================================================================
Sonic_Index:	dc.w Sonic_Main-Sonic_Index
		dc.w Sonic_Control-Sonic_Index
		dc.w Sonic_Hurt-Sonic_Index
		dc.w Sonic_Death-Sonic_Index
		dc.w Sonic_ResetLevel-Sonic_Index
; ===========================================================================

Sonic_Main:	; Routine 0
		if RunInSpecificZone=1
        move.b    (v_zone),d0        ; Copy only the Zone (Byte) to d0
        cmp.b     #$00,d0            ; Modify here: Replace $00 with the desired Zone
        bne.s     .not_this_zone     ; If it is not the correct zone, skip the code

        move.b    (v_act),d0         ; Copy only the Act (Byte) to d0
        cmp.b     #$00,d0            ; Modify here: Replace $00 with the desired Act
        bne.s     .not_this_zone     ; If it is not the correct act, skip the code

        move.w    #$800,obInertia(a0) ; Apply inertia if both zone and act match

.not_this_zone:
		endif
		addq.b	#2,obRoutine(a0)
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.l	#Map_Sonic,obMap(a0)
		move.w	#make_art_tile(ArtTile_Sonic,0,0),obGfx(a0)
		move.b	#2,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		move.w	#$600,(v_sonspeedmax).w ; Sonic's top speed
		move.w	#$C,(v_sonspeedacc).w ; Sonic's acceleration
		move.w	#$80,(v_sonspeeddec).w ; Sonic's deceleration

Sonic_Control:	; Routine 2
		if	CheatDeathDebug=0
		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	loc_12C58	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	loc_12C58	; if not, branch
		move.w	#1,(v_debuguse).w ; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts
; ===========================================================================

loc_12C58:
		endif
		tst.b	(f_lockctrl).w	; are controls locked?
		bne.s	loc_12C64	; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w ; enable joypad control

loc_12C64:
		btst	#0,(f_playerctrl).w ; are controls locked?
		bne.s	loc_12C7E	; if yes, branch
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Sonic_Modes(pc,d0.w),d1
		jsr	Sonic_Modes(pc,d1.w)

loc_12C7E:
		bsr.s	Sonic_Display
		bsr.w	Sonic_RecordPosition
		bsr.w	Sonic_Water
		move.b	(v_anglebuffer).w,objoff_36(a0)
		move.b	(v_anglebuffer2).w,objoff_37(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	loc_12CA6
		tst.b	obAnim(a0)
		bne.s	loc_12CA6
		move.b	obPrevAni(a0),obAnim(a0)

loc_12CA6:
		bsr.w	Sonic_Animate
		tst.b	(f_playerctrl).w
		bmi.s	loc_12CB6
		jsr	(ReactToItem).l

loc_12CB6:
		bsr.w	Sonic_Loops
		bsr.w	Sonic_LoadGfx
		rts	
; ===========================================================================
Sonic_Modes:	dc.w Sonic_MdNormal-Sonic_Modes
		dc.w Sonic_MdJump-Sonic_Modes
		dc.w Sonic_MdRoll-Sonic_Modes
		dc.w Sonic_MdJump2-Sonic_Modes

		include	"_incObj/Sonic Display.asm"
		include	"_incObj/Sonic RecordPosition.asm"
		include	"_incObj/Sonic Water.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Modes	for controlling	Sonic
; ---------------------------------------------------------------------------

Sonic_MdNormal:
		if SpindashEnabled=1
		bsr.w	Sonic_SpinDash
		endif
		bsr.w	Sonic_Jump
		bsr.w	Sonic_SlopeResist
		bsr.w	Sonic_Move
		bsr.w	Sonic_Roll
		bsr.w	Sonic_LevelBound
		jsr	(SpeedToPos).l
		bsr.w	Sonic_AnglePos
		bsr.w	Sonic_SlopeRepel
		rts	
; ===========================================================================

Sonic_MdJump:
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_JumpDirection
		bsr.w	Sonic_LevelBound
		jsr	(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	loc_12E5C
		subi.w	#$28,obVelY(a0)

loc_12E5C:
		bsr.w	Sonic_JumpAngle
		bsr.w	Sonic_Floor
		rts	
; ===========================================================================

; ===========================================================================

Sonic_MdRoll:
		bsr.w	Sonic_Jump
		bsr.w	Sonic_RollRepel
		bsr.w	Sonic_RollSpeed
		bsr.w	Sonic_LevelBound
		jsr	(SpeedToPos).l
		bsr.w	Sonic_AnglePos
		bsr.w	Sonic_SlopeRepel
		rts	
; ===========================================================================

Sonic_MdJump2:
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_JumpDirection
		bsr.w	Sonic_LevelBound
		jsr	(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	loc_12EA6
		subi.w	#$28,obVelY(a0)

loc_12EA6:
		bsr.w	Sonic_JumpAngle
		bsr.w	Sonic_Floor
		rts	

		include	"_incObj/Sonic Move.asm"
		include	"_incObj/Sonic RollSpeed.asm"
		include	"_incObj/Sonic JumpDirection.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Unused subroutine to squash Sonic
; ---------------------------------------------------------------------------
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_13302
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	locret_13302
		move.w	#0,obInertia(a0) ; stop Sonic moving
		move.w	#0,obVelX(a0)
		move.w	#0,obVelY(a0)
		move.b	#id_Warp3,obAnim(a0) ; use "warping" animation

locret_13302:
		rts	

		include	"_incObj/Sonic LevelBound.asm"
		include	"_incObj/Sonic Roll.asm"
		include	"_incObj/Sonic Jump.asm"
		include	"_incObj/Sonic JumpHeight.asm"
		if SpindashEnabled=1
		include	"_incObj/Sonic SpinDash.asm"
		endif
		if JumpDashEnabled=1
		include	"_incObj/Sonic JumpDash.asm"
		endif
		include	"_incObj/Sonic SlopeResist.asm"
		include	"_incObj/Sonic RollRepel.asm"
		include	"_incObj/Sonic SlopeRepel.asm"
		include	"_incObj/Sonic JumpAngle.asm"
		include	"_incObj/Sonic Floor.asm"
		include	"_incObj/Sonic ResetOnFloor.asm"
		include	"_incObj/Sonic (part 2).asm"
		include	"_incObj/Sonic Loops.asm"
		include	"_incObj/Sonic Animate.asm"
		include	"_anim/Sonic.asm"
		include	"_incObj/Sonic LoadGfx.asm"
