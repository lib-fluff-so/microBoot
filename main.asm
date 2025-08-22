//main.asm

.TEXT  

.include libnand.asm
.include libfat.asm
.include liblib.asm
.include libgfx.asm

.public _main

_main:  
  //Every unSP program ever  
  int off  
  fir_mov off  
    
  //More preparation code  
  sp = 0x6fff  
  bp = sp  
  ds = 0x0000
  
  //Setup chipselects  
  r1 = 0x0247  
  [0x7820] = r1  
  r1 = 0xff47  
  [0x7821] = r1  
   r1 = 0x0047  
  [0x7822] = r1  
  r1 = 0xfec7  
  [0x7823] = r1  
  r1 = 0x0047  
  [0x7824] = r1  
  
  //Set type (24+8)
  r1 = 0x0000
  [0x7856] = r1
  
  call _resetNAND
    
  //Wait (for the sake of god)  
  call _NANDPolling  
  
  r3 = 0x0000 //24+8 address
  r4 = 0x0000 //24+8 address
  r1 = _BootSectorCopyAddress //copy to address  
  call _DMACopyNANDPage
  call _resetNAND
  call _parseBootSector
    
  goto _exit