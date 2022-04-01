virtual at $04E000
_osrt_lib_table rb $200
end virtual
virtual at 320000
osrt.argv_so.version rb 4
osrt.argv_0 rb 4
osrt.argv_1 rb 4
osrt.argv_2 rb 4
osrt.argv_3 rb 4
osrt.argv_4 rb 4
osrt.argv_a rb 4
osrt.argv_fail rb 4
end virtual
virtual at 320512
osrt.mem_so.version rb 4
osrt.check_address_writable rb 4
osrt.read_a_from_addr rb 4
osrt.read_byte_from_addr rb 4
osrt.read_word_from_addr rb 4
osrt.read_int_from_addr rb 4
osrt.read_long_from_addr rb 4
osrt.set_a_at_addr rb 4
osrt.set_byte_at_addr rb 4
osrt.set_word_at_addr rb 4
osrt.set_int_at_addr rb 4
osrt.set_long_at_addr rb 4
osrt.xor_val_addr rb 4
osrt.or_val_addr rb 4
osrt.and_val_addr rb 4
end virtual
virtual at 321024
osrt.numstr_so.version rb 4
osrt.str_to_int       rb 4
osrt.hexstr_to_int    rb 4
osrt.nibble           rb 4
osrt.byte_to_hexstr   rb 4
osrt.int_to_hexstr    rb 4
osrt.long_to_hexstr   rb 4
osrt.b_to_hexstr      rb 4
end virtual
