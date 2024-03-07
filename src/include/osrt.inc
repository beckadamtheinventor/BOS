virtual at $04E000
_osrt_lib_table rb bos.fs_sector_size
end virtual
virtual at 319552
osrt.argv_so.version rb 4
osrt.argv_0 rb 4
osrt.argv_1 rb 4
osrt.argv_2 rb 4
osrt.argv_3 rb 4
osrt.argv_4 rb 4
osrt.argv_a rb 4
osrt.argv_fail rb 4
end virtual
virtual at 319744
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
virtual at 320128
osrt.numstr_so.version rb 4
osrt.str_to_int       rb 4
osrt.hexstr_to_int    rb 4
osrt.nibble           rb 4
osrt.byte_to_hexstr   rb 4
osrt.int_to_hexstr    rb 4
osrt.long_to_hexstr   rb 4
osrt.b_to_hexstr      rb 4
osrt.byte_to_str      rb 4
osrt.int_to_str       rb 4
osrt.long_to_str      rb 4
osrt.intstr_to_str    rb 4
end virtual
virtual at 320512
osrt.str_so.version rb 4
osrt.substring        rb 4
osrt.duplicate_string rb 4
osrt.subsection_mem   rb 4
osrt.duplicate_mem    rb 4
osrt.sreadline         rb 4
osrt.sreadlineuntil    rb 4
osrt.sreaduntil        rb 4
osrt.sreadidentifier   rb 4
end virtual
