.TEXT

.ifndef __LIBMATH_INCLUDED__
.define __LIBMATH_INCLUDED__

// [uint16,uint16] _divide32x16uu(uint32 a=mr, uint32 b=r2) => [r3(quotient), r4(remainder)]
_divide32x16uuSoftware:
  //Well, as clear from name, software division
  //Compatible with hardware division function
  //Made, because hardware division is half broken on current build of micron
  
  push bp, bp to [sp]
  push r1, r1 to [sp]
  push r9, r9 to [sp]
  bp = sp + 3
  
  r1 = 0
  r9 = 16
  
  loop_div:
    r9 -= 1
    
	[0x0100] = r1
	r1 = 0x1
	r4 = r4 lsl r1    //shift high word
	mr |= r3 lsl r1   //shift low word
	r1 = [0x0100]
	
	cmp r4, r2
	jb skip_sub
	
	r4 -= r2
	r1 |= 1
  
  skip_sub:
    r1 = r1 lsl 1
    
    cmp r9, 0
    jne loop_div
    
    r1 = r1 lsr 1
    
    r3 = r1
  
  pop r9, r9 from [sp]
  pop r1, r1 from [sp]
  pop bp, pc from [sp]

// [uint16,uint16] _divide32x16uu(uint32 a=mr, uint32 b=r2) => [r3(quotient), r4(remainder)]
_divide32x16uu:
  //PREPARE FOR "It just works!" TYPE F*CKERY!!!
  //TODO: Well, It actually doesn't work, this function is currently a placeholder for the
  //moment where division would work correctly in micron.
  
  push bp, bp to [sp]
  push r1, r1 to [sp]
  bp = sp + 2

  //Prepare 31.1 format: shift dividend left by 1 bit
  //so that we have room for the fractional quotient bit.
  r1 = 0x1
  r4 = r4 lsl r1    //shift high word
  mr |= r3 lsl r1   //shift low word
  
  //Clear AQ flag (FR[14])
  r1 = fr
  clrb r1, 0xe
  fr = r1

  //Do 15 iterations of non-restoring division
  r1 = 0
  divide_loop:
	divq mr, r2
	r1 += 0x1
	cmp r1, 0x10
	jne divide_loop
  
  pop r1, r1 from [sp]
  pop bp, pc from [sp]

// uint48 _add32x32uu(uint32 a=mr, uint32 b=r1:r2) => r11:r10:r9
_add32x32uu:
  push bp, bp to [sp]
  bp = sp + 1
  
  r9 = 0x0000
  r10 = r2
  r11 = r1
  
  r11 += r3
  
  r10 += r4, carry
  
  r9 += 0x0000, carry
  pop bp, pc from [sp]

// uint48 _multiply32x16uu(uint32 a=mr, uint16 b=r2) => r11:r10:r9
_multiply32x16uu:
  push bp, bp to [sp]
  push r1, r1 to [sp]
  push r3, r4 to [sp]
  push r12, r15 to [sp]
  push r14, r14 to [sp]
  bp = sp + 4
  
  r1 = r4                //move later used r4 to r1
  mr = r3*r2, uu         //multiply the lower part
  r10 = r3               //move the result
  r12 = r4               //move the result
  
  mr = r1*r2, uu         //multiply the higher part
  r13 = r3               //move the result
  r11 = r4               //move the result
  
  r14 = r12
  r14 += r13             //get the middle prt by overlapping high and low parts
  r15 = 0x0              //prepare to add carry
  r11 += r15, carry      //add carry to high part
  
  r9 = r10               //set result registers
  r10 = r14              //set result registers
  
  pop r14, r14 from [sp]
  pop r12, r15 from [sp]
  pop r3, r4 from [sp]
  pop r1, r1 from [sp]
  pop bp, pc from [sp]

.endif