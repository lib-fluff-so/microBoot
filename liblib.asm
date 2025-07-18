.TEXT

.ifndef __LIBLIB_INCLUDED__
.define __LIBLIB_INCLUDED__

.include libinclude.asm

//void _nothing()  
_exit:  
  jmp _exit
  
//void _print(word* from=r1, word* dest=r3)  
_print:  
  push bp, bp to [sp]  
  push r4, r4 to [sp]
  bp = sp + 2
  
  cycle:  
    r4 = [r1]  
    cmp r4, PRINT_END
    je function_end
    ds:[r3] = r4  
    r1 += 1  
    r3 += 1
    jmp cycle
  
  function_end:
  	pop r4, r4 from [sp]
  	pop bp, pc from [sp]  
  
.endif