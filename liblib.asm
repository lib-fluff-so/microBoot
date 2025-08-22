.TEXT

.ifndef __LIBLIB_INCLUDED__
.define __LIBLIB_INCLUDED__

.include libinclude.asm

_byteSwap:
  push bp, bp to [sp]
  push r4, r4 to [sp]
  //who needs frame pointer in _byteSwap?
  r4 = r1
  r1 = r1 lsl 4
  r1 = r1 lsl 4
  r4 = r4 lsr 4
  r4 = r4 lsr 4
  r1 |= r4
  pop r4, r4 from [sp]
  pop bp, pc from [sp]

_DMAPolling:
  tstb [0x7a80], 1
  jnz _DMAPolling
  retf

//void _exit()  
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
    [r3] = r4  
    
    r1 += 1
    r3 += 1
    jmp cycle
  
  function_end:
  	pop r4, r4 from [sp]
  	pop bp, pc from [sp]  
  
.endif