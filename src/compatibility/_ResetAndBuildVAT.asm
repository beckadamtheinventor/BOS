;@DOES reset VAT pointers and rebuild the VAT.
_ResetAndBuildVAT:
	ld hl,ti.symTable
	ld (ti.pTemp),hl
	ld (ti.progPtr),hl
assert $ = _BuildVAT
