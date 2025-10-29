
macro BOSUnicodeFont?
    local __pagetable
    db "UNIF"
    virtual
        __pagetable::
    end virtual
    macro codepage? page
        local __page
        repeat (16 - ($ and 15)) and 15
            db 0
        end repeat
        __page:
        virtual __pagetable
            dw (__page - $+2) shr 4
        end virtual
        macro bb? data&
            local bits
            bits = 0
            iterate bit, data
                bits = bits * 2 + bit
            end iterate
            dw bits
        end macro
        macro end?.codepage?
            restore end?.codepage?
            restore bb
        end macro
    end macro
    macro end?.BOSUnicodeFont?
        restore end?.BOSUnicodeFont?
    end macro
end macro
