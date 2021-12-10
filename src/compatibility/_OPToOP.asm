
iterate dest, 1, 2, 3, 4, 5, 6
	iterate source, 1, 2, 3, 4, 5, 6
		if ~dest = source
			_OP#source#ToOP#dest:
				ld hl,fsOP#source
				jq _MovToOP#dest
		end if
	end iterate
	_MovToOP#dest:
		ld de,fsOP#dest
		jq _Mov11b
end iterate
