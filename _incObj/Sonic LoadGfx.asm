; ---------------------------------------------------------------------------
; Sonic DPLC loading subroutine
; ---------------------------------------------------------------------------

; LoadSonicDynPLC:
Sonic_LoadGfx:
		move.b	obFrame(a0),d0				; get Sonic's current frame
		cmp.b	(v_sonframenum).w,d0			; has the frame changed?
		beq.s	.end					; if not, nothing to do
		move.b	d0,(v_sonframenum).w			; update cached frame number
		lea	(SonicDynPLC).l,a2			; load Sonic DPLC table
		move.w	#ArtTile_Sonic*tile_size,d4		; starting VRAM tile
		move.l	#Art_Sonic,d6				; base Sonic art pointer
		jmp	(LoadDynPLC).l				; load DPLC
.end:
		rts						; return
; End of function Sonic_LoadGfx