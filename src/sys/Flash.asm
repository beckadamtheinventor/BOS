
;some code copied from Cesium
;begin Cesium license

; Copyright 2015-2020 Matt "MateoConLechuga" Waltz
; 
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
; 
; 1. Redistributions of source code must retain the above copyright notice,
;    this list of conditions and the following disclaimer.
; 
; 2. Redistributions in binary form must reproduce the above copyright notice,
;    this list of conditions and the following disclaimer in the documentation
;    and/or other materials provided with the distribution.
; 
; 3. Neither the name of the copyright holder nor the names of its contributors
;    may be used to endorse or promote products derived from this software
;    without specific prior written permission.
; 
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGE.

;end cesium license

;directly copied from cesium
port_ospre55:
.unlock:
	ld	bc,$24
	ld	a,$8c
	call	.write
	ld	bc,$06
	call	.read
	or	a,4
	call	.write
	ld	bc,$28
	ld	a,$4
	jq	.write
.lock:
	ld	bc,$28
	xor	a,a
	call	.write
	ld	bc,$06
	call	.read
	res	2,a
	call	.write
	ld	bc,$24
	ld	a,$88
	jq	.write
.write:
	ld	de,$c979ed
	ld	hl,ti.heapBot - 3
	ld	(hl),de
	jp	(hl)
.read:
	ld	de,$c978ed
	ld	hl,ti.heapBot - 3
	ld	(hl),de
	jp	(hl)

;modified to use static unlock routine
flash_unlock:
sys_FlashUnlock:
port_unlock:
	push	de,bc,hl
	call	port_ospre55.unlock
.pop:
	pop	hl,bc,de
	ret

;modified to use static lock routine
flash_lock:
sys_FlashLock:
port_lock:
	push	de,bc,hl
	call	port_ospre55.lock
.code := $-3
	jq	port_unlock.pop

