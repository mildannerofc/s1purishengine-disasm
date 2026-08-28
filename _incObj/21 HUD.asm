; ---------------------------------------------------------------------------
; Object 21 - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------

HUD:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	HUD_Index(pc,d0.w),d1
		jmp	HUD_Index(pc,d1.w)
; ===========================================================================
HUD_Index:	dc.w HUD_Main-HUD_Index     ; Routine 0
		dc.w HUD_Flash-HUD_Index    ; Routine 2 (Mantido na posição original)
		if HUDScrolling=1
		dc.w HUD_Move-HUD_Index     ; Routine 4 (Sua nova rotina de movimento)
		endif
; ===========================================================================
; HUD Scrolling Speed
; ======================================================================

HUDScrollSpeed = 5	; Adjust how many speed it will move.
HUD_SmoothScroll = 0 ; Activate smooth gliding HUD

; ======================================================================
; HUD MOVEMENT CONFIGURATION (Modify here to adjust the behavior)
; ===========================================================================

	if HUD_SmoothScroll=1
HUD_EASING    =  3    ; Bitshift factor for division (LSR). 
                        ; 1 = Very fast/snappy, 2 = Medium, 3 = Smooth (Default), 4 = Super slow.
HUD_MIN_SPEED =  1    ; Minimum speed in pixels per frame (Ensures it reaches target).
                        ; Increase to 2 or 3 for a harder stop at the end.
	endif
; ======================================================================

HUD_Main:	; Routine 0
		if HUDScrolling=1
		addq.b	#4,obRoutine(a0)
		move.w	#0,obX(a0)
		move.w	#$108,obScreenY(a0)
		move.l	#Map_HUD,obMap(a0)
		move.w	#make_art_tile(ArtTile_HUD,0,0),obGfx(a0)
		move.b	#0,obRender(a0)
		move.b	#0,obPriority(a0)
		rts                                 ; Finaliza a Routine 0

HUD_Move:    ; Routine 4
		if HUD_SmoothScroll=1
        move.w    #$90,d1           ; Load the target final X position
        move.w    obX(a0),d0        ; Load the current HUD X position
        
        cmp.w     d0,d1             ; Compare target (d1) with current position (d0)
        beq.s     .reached          ; If they match exactly, the HUD has arrived

        ; Start easing (smooth approach) calculation
        sub.w     d0,d1             ; Calculate the distance (Target - Current)
        bpl.s     .pos              ; If the result is positive, branch to .pos
        neg.w     d1                ; If negative, make it positive
        
.pos:   lsr.w     #HUD_EASING,d1    ; Apply custom smoothness factor
        addq.w    #HUD_MIN_SPEED,d1 ; Apply custom minimum speed cap

        ; Check movement direction to apply speed correctly
        move.w    obX(a0),d0        ; Reload current position
        cmp.w     #$90,d0           ; Compare current position with target
        bge.s     .move_left        ; If current > target, move left

.move_right:
        add.w     d1,d0             ; Add calculated speed to current X
        move.w    d0,obX(a0)        ; Update object X coordinate
        jmp       DisplaySprite

.move_left:
        sub.w     d1,d0             ; Subtract calculated speed from current X
        move.w    d0,obX(a0)        ; Update object X coordinate
        jmp       DisplaySprite

.reached:
        move.b    #2,obRoutine(a0)  ; Advance to next routine (HUD idle)
        jmp       DisplaySprite

; ---------------------------------------------------------------------------
		else
        move.w    obX(a0),d0        ; Loads the current HUD X position
        cmpi.w    #$90,d0           ; Has it reached position $90?
        bge.s    .reached          ; If greater or equal, finalize the movement
 
        addq.w    #HUDScrollSpeed,d0             ; Move 5 pixels to the right
        move.w    d0,obX(a0)        ; Update the object's X coordinate directly
        jmp       DisplaySprite

.reached:
        move.b    #2,obRoutine(a0)
        jmp       DisplaySprite
		endif
		else
		addq.b	#2,obRoutine(a0)
		move.w	#$90,obX(a0)
		move.w	#$108,obScreenY(a0)
		move.l	#Map_HUD,obMap(a0)
		move.w	#make_art_tile(ArtTile_HUD,0,0),obGfx(a0)
		move.b	#0,obRender(a0)
		move.b	#0,obPriority(a0)
		endif

HUD_Flash:	; Routine 2
		moveq	#0,d0
		btst	#3,(v_framebyte).w
		bne.s	.display
		tst.w	(v_rings).w	; do you have any rings?
		bne.s	.norings	; if so, branch
		addq.w	#1,d0		; make ring counter flash red
; ===========================================================================

.norings:
		cmpi.b	#9,(v_timemin).w ; have	9 minutes elapsed?
		bne.s	.display	; if not, branch
		addq.w	#2,d0		; make time counter flash red

	.display:
		move.b	d0,obFrame(a0)
		jmp	DisplaySprite
; ===========================================================================
