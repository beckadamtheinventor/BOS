
macro trx? stack_alloc_bytes
	local program
	element program.base
	virtual
		program.relocations.area::
	end virtual
	macro @ez80.word @value*
		local value, address
		value = @value
		address = $
		if value > program.data.start & value < program.data.end
			virtual program.relocations.area
				dw address - program.data.start
			end virtual
			@ez80.word value - program.data.start
		else
			@ez80.word value
		end if
	end macro

	jp $F8 ;this code should never be executed but in the case that it is...
assert stack_alloc_bytes < 256 shl 5
	db "TRX",0,stack_alloc_bytes shr 5
	dw program.data.len
	dw program.relocations.len shr 1
	db program.relocations
	program.data.start:
	macro end?.trx?
		program.data.end:
		program.data.len := $-program.data.start
		virtual program.relocations.area
			program.relocations.len := $-$$
			load program.relocations: $-$$ from $$
		end virtual
	end macro
end macro
