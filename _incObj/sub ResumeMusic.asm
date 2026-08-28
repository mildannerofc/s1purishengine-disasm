; ---------------------------------------------------------------------------
; Subroutine to play music for LZ/SBZ3 after a drowning countdown
; ---------------------------------------------------------------------------

ResumeMusic:
		cmpi.w	#12,(v_air).w		; more than 12 seconds of air left?
		bhi.s	.over12			; if yes, only replenish air without changing music 

		tst.b	(v_invinc).w		; is Sonic invincible?
		beq.s	.notinvinc		; if not, branch
		move.w	#bgm_Invincible,d0	; resume invincibility music instead
		bra.s	.playselected		; play it
; ===========================================================================

.notinvinc:
		tst.b	(f_lockscreen).w	; is Sonic at a boss?
		beq.s	.normal 		; if not, branch
		move.w	#bgm_Boss,d0		; resume boss music instead

.playselected:
		jsr	(PlaySound).l		; play selected song
		bra.s	.over12			; do not play regular level music
; ===========================================================================

.normal:
		jsr	(PlayCurrentActMusic).l	; resume regular level music after drowning counting

.over12:
		move.w	#30,(v_air).w		; replenish air to 30 seconds
		clr.b	(v_sonicbubbles+objoff_32).w ; hide bubbles object
		rts				; return
; End of function ResumeMusic