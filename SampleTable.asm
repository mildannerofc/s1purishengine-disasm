
; ---------------------------------------------------------------
SampleTable:
			;			type			pointer		Hz
			dcSample	TYPE_DPCM, 		Kick, 		8000				; $81 - Kick (S1/2)
			dcSample	TYPE_PCM,		Snare,		24000				; $82 - Snare (S1/2)
			dcSample	TYPE_DPCM, 		Timpani, 	7250				; $83 - Timpani (Normal)
			dcSample	TYPE_PCM,		Clap,		17000				; $84 - Clap (S2)
			dcSample	TYPE_PCM,		Cymbal,		16843				; $85 - Cymbal (TR-626)
			dcSample	TYPE_NONE										; $86 - PLACEHOLDER
			dcSample	TYPE_NONE										; $87 - PLACEHOLDER
			dcSample	TYPE_DPCM, 		Timpani, 	9750				; $88 - Timpani High
			dcSample	TYPE_DPCM, 		Timpani, 	8750				; $89 - Timpani Mid
			dcSample	TYPE_DPCM, 		Timpani, 	7150				; $8A - Timpani Low
			dcSample	TYPE_DPCM, 		Timpani, 	7000				; $8B - Timpani Floor
dacSega:	dcSample	TYPE_PCM,		SegaPCM,	0, FLAGS_SFX		; $8C	NOTE: sample rate is auto-detected from WAV file
			dc.w	-1	; end marker

; ---------------------------------------------------------------
			incdac	Kick, "sound/dac/kick.dpcm"
			incdac	Snare, "sound/dac/snare.pcm"
			incdac	Timpani, "sound/dac/timpani.dpcm"
			incdac	Clap, "sound/dac/clap.wav"
			incdac	Cymbal, "sound/dac/cymbal.wav"
			incdac	SegaPCM, "sound/dac/sega.wav"
			even
