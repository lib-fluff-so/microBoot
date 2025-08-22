.TEXT

.ifndef __LIBNAND_INCLUDED__
.define __LIBNAND_INCLUDED__

.include libinclude.asm
.include liblib.asm

// void _resetNAND()
_resetNAND:
  push bp, bp to [sp]
  push r1, r1 to [sp]
  bp = sp + 2
      
  //Perform NAND reset
  r1 = 0x0055 //control setup  
  [0x7850] = r1  
  r1 = 0xc200 //DMA INT setup  
  [0x7855] = r1  
  r1 = 0x00ff //reset NAND command  
  [0x7851] = r1 
  call _NANDPolling
  
  pop r1, r1 from [sp]
  pop bp, pc from [sp]

// void _NANDPolling()  
_NANDPolling:  
  push bp, bp to [sp]  
  push r1, r1 to [sp]  
  bp = sp + 2  
  
  polling:  
    r1 = [0x7850]  
    r1 &= 0x8000  
    cmp r1, 0x8000  
    jne polling
  
  pop r1, r1 from [sp]  
  pop bp, pc from [sp]  
  
// page _DMACopyNANDPage(uint32 read_address=mr, word* dest=r1)
// NOTE: read_address is in format PPPPPPOO, where P is Page and O is Offset
_DMACopyNANDPage:
  push bp, bp to [sp]
  push r10, r10 to [sp]
  bp = sp + 2
  
  //Read NAND with DMA
  r10 = 0x0200
  [0x7a80] = r10    //P_DMA_Ctrl0
  r10 = 0x0000
  [0x7a82] = r1     //P_DMA_TAR_AddrL0
  [0x7a85] = r10    //P_DMA_TAR_AddrH0
  r10 = 0x7854
  [0x7a81] = r10    //P_DMA_SRC_AddrL0
  r10 = 0x0000
  [0x7a84] = r10    //P_DMA_SRC_AddrH0
  r10 = [_NANDFullPage]
  [0x7a83] = r10    //P_DMA_TCountL0
  r10 = 0x0000
  [0x7a86] = r10    //P_DMA_TCountH0
  r10 = 0x0005
  [0x7abe] = r10    //P_DMA_SS
  r10 = 0x1088
  [0x7a80] = r10    //P_DMA_Ctrl0 
  
  r10 = 0xc200
  [0x7855] = r10
  r10 = 0x0000
  [0x7851] = r10
  [0x7852] = r3
  [0x7853] = r4
  r10 = 0xc200
  [0x7855] = r10
  r10 = 0x0000
  [0x7852] = r3
  [0x7853] = r4
  r10 = 0x0030
  [0x7851] = r10
  call _NANDPolling
  r10 = [0x7a80]
  r10 += 0x1
  [0x7a80] = r10
  call _DMAPolling
  
  pop r10, r10 from [sp]
  pop bp, pc from [sp]


// uint32 _generateNANDAddressWithoutOffset(uint32 page_offset=mr)
_generateNANDAddressWithoutOffset:
  push bp, bp to [sp]
  
  r3 = 0                      //should've been offset, but this is fine as well
                              //guaranteed to have no wacky problems, after all
  //Convert form PPPPOOOO to PPPPPPOO
  //Shift to proper format (0x8 shift)
  r1 = 0x4                    //shift to proper format (0x8 shift)
  r3 = r3 lsr r1              //shift to proper format (0x8 shift)
  mr |= r4 lsr r1             //shift to proper format (0x8 shift)
  r3 = r3 lsr r1              //shift to proper format (0x8 shift)
  mr |= r4 lsr r1             //shift to proper format (0x8 shift)
  
  pop bp, pc from [sp]
  
.endif