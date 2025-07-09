.TEXT

.ifndef __LIBLIB_INCLUDED__
.define __LIBLIB_INCLUDED__

//void _nothing()  
_exit:  
  jmp _exit
  
//void _print(word* from=r1, uint16 length=r2, word* dest=r3)  
_print:  
  push bp, bp to [sp]  
  push r4, r4 to [sp]
  bp = sp + 1  
  
  cycle:  
    r4 = [r1]  
    ds:[r3] = r4  
    r1 += 1  
    r2 -= 1  
    r3 += 1  
    cmp r2, 0x0000  
    jne cycle  
      
  pop r4, r4 from [sp]
  pop bp, pc from [sp]  
  
.endif