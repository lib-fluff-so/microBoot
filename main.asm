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
  
  //Set type (20+12)
  r1 = 0x0000
  [0x7856] = r1
    
  call _resetNAND
    
  //Wait (for the sake of god)  
  call _NANDPolling  
    
  //Read ID  
  r1 = 0x0055 //control setup  
  [0x7850] = r1  
  r1 = 0xc200 //DMA INT setup  
  [0x7855] = r1  
  r1 = 0x0090 //read ID command  
  [0x7851] = r1  
  nop //i think timings? works in Hannah Montana  
  nop  
  nop  
  nop  
  r1 = 0x0000 //write lows  
  [0x7852] = r1  
  nop  
  nop  
  nop  
  nop  
  r1 = 0x0000 //write highs  
  [0x7853] = r1  
  nop  
  nop  
  nop  
  nop  
  call _NANDPolling
  //Get needed data
  r1 = [0x7854]
  r2 = [0x7854]
  //Get not needed data because otherwise it won't work
  r3 = [0x7854]
  r3 = [0x7854]
  r3 = [0x7854]
    
  //Parse ID  
  furbyConnectNAND:  
    cmp r1, 0x98  
    jne unknownNAND  
    cmp r2, 0xd1  
    jne unknownNAND  
    
    //YAY!!! It's right NAND!!!  
    r3 = 0x0000 //24+8 address
    r4 = 0x0000 //24+8 address
    r1 = [_BootSectorCopyAddress] //copy to address  
    call _DMACopyNANDPage
    call _resetNAND
    call _parseBootSector
    
    r3 = 0x5000
    r1 = _ProgramFinished
    call _print
    
    goto _exit
    
  unknownNAND:  
    r3 = 0x5000
    r1 = _errorUnsupportedNAND  
    call _print  
    goto _exit