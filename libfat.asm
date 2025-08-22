.TEXT

.ifndef __LIBFAT_INCLUDED__
.define __LIBFAT_INCLUDED__

.include libinclude.asm
.include libmath.asm
.include libnand.asm
.include liblib.asm

// void _parseBootSector()
_parseBootSector:
  push bp, bp to [sp]
  bp = sp + 1
  
  //NOTE: Down here, byte values are like ones in FAT spec, BUT word values are unSP ready
  //(order will make right values)
  //Reserved_Sector_Count = 0xe-0xf in bytes or 0x7 in words
  //Number_of_FATs = 0x10 in bytes or 0x8(second byte) in words
  //FAT_Size_32 = 0x24-0x27 in bytes or 0x13 and 0x12 in words
  //Bytes_Per_Sector = 0xb-0xc in bytes or 0x5(first byte) and 0x6(second byte) in words
  //Root_Cluster = 0x44-0x48 in bytes or 0x17-0x16 in words
  //Sectors_Per_Cluster = 0x13 in bytes or 0x6(first byte) in words
  
  r14 = _BootSectorCopyAddress //It is just easier with this
  
  //Data_Start = (Reserved_Sector_Count + Number_of_FATs * FAT_Size_32) * Bytes_Per_Sector
  //Multiply Number_of_FATs by FAT_Size_32
  r2 = r14 + 0x8                //get address of Number_of_FATs word
  r2 = [r2]                     //get Number_of_FATs word
  r2 &= 0x00ff                  //mask it so only second byte will be there
  r3 = r14 + 0x12               //get address of part of FAT_Size_32
  r3 = [r3]                     //get part of FAT_Size_32
  r4 = r14 + 0x13               //get address of part of FAT_Size_32
  r4 = [r4]                     //get part of FAT_Size_32
  call _multiply32x16uu         //multiply these unsigned values!
  
  //Add value we got to Reserved_Sector_Count
  r1 = r14 + 0x7                //get address of Reserved_Sector_Count word
  r1 = [r1]                     //get Reserved_Sector_Count word
  r2 = 0x0                      //a is 16 bit, so r2 should be 0
  r3 = r9                       //copy some regs, get mr
  r4 = r10                      //copy some regs, get mr
  call _add32x32uu              //add it!
  
  [_Data_StartSector0] = r11    //Data_Start sector in RAM
  [_Data_StartSector1] = r10    //Data_Start sector in RAM
  
  //Multiply Bytes_Per_Sector by the value we got
  r1 = r14 + 0x5                //get address of first byte of Bytes_Per_Sector
  r1 = [r1]                     //get first byte of Bytes_Per_Sector
  r1 &= 0xff00                  //mask it so only first byte will be there
  r1 = r1 lsr 0x4               //shifts, making 8 bit shift in sum,
  r1 = r1 lsr 0x4               //placing it where it would be in value
  
  r4 = r14 + 0x6                //get address of second byte of Bytes_Per_Sector
  r4 = [r4]                     //get second byte of Bytes_Per_Sector
  r4 &= 0x00ff                  //mask it so only second byte will be there
  r4 = r4 lsl 0x4               //shifts, making 8 bit shift in sum,
  r4 = r4 lsl 0x4               //placing it where it would be in value
  
  r1 |= r4                      //combine those values into one word
  
  [_Bytes_Per_Sector] = r1      //Bytes_Per_Sector in RAM
  
  r2 = r1                       //prepare data for multiplication
  r3 = r9                       //prepare data for multiplication
  r4 = r10                      //prepare data for multiplication
  
  call _multiply32x16uu         //and multiply
  
  [_Data_StartAddress0] = r10   //Data_Start address in RAM
  [_Data_StartAddress1] = r11   //Data_Start address in RAM
  
  
  //Get Sectors_Per_Cluster
  r2 = r14 + 0x6                //get address of first byte of Sectors_Per_Cluster
  r2 = [r2]                     //get first byte of Sectors_Per_Cluster
  r2 &= 0xff00                  //mask it so only first byte will be there
  r2 = r2 lsr 0x4               //shifts, making 8 byte shift in sum,
  r2 = r2 lsr 0x4               //placing it where it should be
  [_Sectors_Per_Cluster] = r2
  
  
  //FAT = Reserved_Sector_Count * Bytes_Per_Sector
  r1 = r14 + 0x7                //get address of Reserved_Sector_Count word
  r1 = [r1]                     //get Reserved_Sector_Count word
  [_FATSector] = r1             //Well... FAT Sector in RAM
  r2 = [_Bytes_Per_Sector]      //fetch Bytes_Per_Sector value from memory
  mr = r1*r2, uu                //and multiply to get address!
  [_FATAddress0] = r3           //FAT address in RAM
  [_FATAddress1] = r4           //FAT address in RAM
  
  r1 = r14 + 0x16
  r1 = [r1]
  r2 = r14 + 0x17
  r2 = [r2]
  call _chainSeeker
  
  call _directoryFindGameCodeFileSFN
  
  //Setup chipselects  
  ds = 0x0005
  r1 = 0x0005
  r1 = D:[r1]
  [0x7820] = r1  
  r1 = 0x0006
  r1 = D:[r1]
  [0x7821] = r1  
  r1 = 0x0007
  r1 = D:[r1]
  [0x7822] = r1  
  r1 = 0x0008
  r1 = D:[r1]
  [0x7823] = r1  
  r1 = 0x0009
  r1 = D:[r1]
  [0x7824] = r1 
  r8 = 0x0000
  r9 = 0x0000
  r10 = 0x0000
  r11 = 0x0000
  r12 = 0x0000
  r13 = 0x0000
  r14 = 0x0000
  r15 = 0x0000
  
  r3 = 0x0020
  r4 = 0x0005
  
  goto mr
  
  pop bp, pc from [sp]

//CachedClusterFATPage byte[16+NANDFullPage] _cachedClusterFATPageRead(uint16 cluster=r14:r15)
_cachedClusterFATPageRead:
  push bp, bp to [sp]
  push r1, r2 to [sp]
  push r3, r4 to [sp]
  push r8, r9 to [sp]
  push r10, r11 to [sp]
  bp = sp + 5
  
  //Multiply by 4 bytes, size of FAT32 field
  r3 = r14
  r4 = r15
  r2 = 0x0004
  call _multiply32x16uu
  
  //Add the FAT start position to field position
  r3 = r9
  r4 = r10
  r1 = [_FATAddress0]
  r2 = [_FATAddress1]
  call _add32x32uu
  [_ChainSeekerCache + 2] = r11 //cluster address
  [_ChainSeekerCache + 3] = r10 //cluster address
  
  //Get page and offset
  //NOTE: using 32x16 division!
  r4 = r10                      //copy some registers,
  r3 = r11                      //so they would be actual args to divide function
  r2 = [_NANDPage]              //divisor is NAND page size (without OOB)
  call _divide32x16uuSoftware
  
  r2 = r3                       //swap them to work with them
  r3 = r4                       //swap them to work with them
  r4 = r2                       //swap them to work with them
  
  [_ChainSeekerCache + 4] = r4  //page
  [_ChainSeekerCache + 5] = r3  //offset
  
  //16+16 to 24+8(without offset BTW)
  call _generateNANDAddressWithoutOffset
  
  //Actually not copy the page second time if it was already copied
  check:
  	cmp r3, [_ChainSeekerCache]
  	jne copy
    cmp r4, [_ChainSeekerCache + 1]
    je end_function
  copy:
    r1 = _ChainSeekerCache + 8    //copy address here
    [_ChainSeekerCache] = r3      //cache
    [_ChainSeekerCache + 1] = r4  //cache
    call _DMACopyNANDPage         //and copy
  end_function:
    pop r10, r11 from [sp]
    pop r8, r9 from [sp]
    pop r3, r4 from [sp]
 	pop r1, r2 from [sp]
    pop bp, pc from [sp]
  	
//ClusterPage byte[Bytes_Per_Sector] _clusterRead(uint32 cluster=mr, uint32 destination=r1:r2)
//Copies into SDRAM(!), Cache in SRAM(!). Destination is in memory map.
_clusterRead:
  push bp, bp to [sp]
  push r3, r4 to [sp]
  push r12, r13 to [sp]
  push r9, r10 to [sp]
  push r11, r14 to [sp]
  push r1, r2 to [sp]
  
  bp = sp + 6
  
  r14 = _BootSectorCopyAddress
  
  //Subtract 2
  r2 = 0x2                      //prepare subtract value
  r3 -= r2                      //subtract!
  r4 -= 0x0000, carry           //and carry it to r4
  
  //Multiply the value we got by Sectors_Per_Cluster
  r2 = [_Sectors_Per_Cluster]
  
  call _multiply32x16uu         //and multiply!
  
  //Add the value we got to to Data_Start Sector
  r3 = r9
  r4 = r10
  r1 = [_Data_StartSector0]     //get Data_Start Sector from RAM
  r2 = [_Data_StartSector1]     //get Data_Start Sector from RAM
  call _add32x32uu              //and add!
  
  //Multiply the value we got by Bytes_Per_Sector (will do 32*16)
  r3 = r11                      //get values
  r4 = r10                      //get values
  r2 = [_Bytes_Per_Sector]      //fetch Bytes_Per_Sector value from memory
  call _multiply32x16uu         //multiply again!
  
  //Get page and offset
  r3 = r9                       //copy some registers,
  r4 = r10                      //so they would be actual args to divide function
  r2 = [_NANDPage]              //divisor is NAND page size (without OOB)
  call _divide32x16uuSoftware   //YAY!!! DIVIDE!!!
  
  r2 = r3                       //swap them to work with them
  r3 = r4                       //swap them to work with them
  r4 = r2                       //swap them to work with them
  r13 = r3                      //store offset in r13, so can be used in calculations later
  r12 = r4                      //store page in r12, so can be used in calculations later
  
  //16+16 to 24+8 without offset
  call _generateNANDAddressWithoutOffset
  
  r1 = _TempClusterRead
  //mr is already set
  call _DMACopyNANDPage         //COPY FIRST PAGE!
  
  r2 = [_NANDPage]
  r2 -= r13
  
  r4 = [_Sectors_Per_Cluster]
  r3 = [_Bytes_Per_Sector]
  mr = r3*r4, uu               //multiply Sectors_Per_Cluster by Bytes_Per_Sector
  [_Cluster_Size_Bytes0] = r3  //lay Cluster_Size_Bytes into RAM
  [_Cluster_Size_Bytes1] = r4  //lay Cluster_Size_Bytes into RAM
  r11 = r3
  cmp r2, r11
  jl CONTINUE
  goto FUNCTION_END
  
  CONTINUE:
    //copy here
    r1 += [_NANDPageWord]      //add copy address
    r3 = r13                   //retrieve offset
    r4 = r12                   //retrieve page
    r4 += 0x1                  //we'll copy next page
    //16+16 to 24+8 without offset
    call _generateNANDAddressWithoutOffset
    call _DMACopyNANDPage      //AND COPY n PAGE!
    r2 += [_NANDPage]
    cmp r2, r11
    
    jge FUNCTION_END
    jl CONTINUE
  
  FUNCTION_END:
    pop r1, r2 from [sp]
    r10 = 0x0200
    [0x7a80] = r10    //P_DMA_Ctrl0
    [0x7a82] = r1     //P_DMA_TAR_AddrL0
    [0x7a85] = r2     //P_DMA_TAR_AddrH0
    r1 = r13
    r1 = r1 lsr 0x1
    r1 += _TempClusterRead
    [0x7a81] = r1     //P_DMA_SRC_AddrL0
    r10 = 0x0000
    [0x7a84] = r10    //P_DMA_SRC_AddrH0
    r3 = r11
    r3 = r3 lsr 0x1
    [0x7a83] = r3    //P_DMA_TCountL0
    r10 = 0x0000
    [0x7a86] = r10    //P_DMA_TCountH0
    r10 = 0x0006
    [0x7abe] = r10    //P_DMA_SS
    r10 = 0x0009
    [0x7a80] = r10    //P_DMA_Ctrl0 
    call _DMAPolling
    
    pop r11, r14 from [sp]
    pop r9, r10 from [sp]
    pop r12, r13 from [sp]
    pop r3, r4 from [sp]
    pop bp, pc from [sp]

//SeekedTable _chainSeeker(uint32 seekCluster=r1:r2)
_chainSeeker:
  push bp, bp to [sp]
  push r3, r4 to [sp]
  push r8, r9 to [sp]
  bp = sp + 3
  
  r8 = 0x0000
  r9 = 0x0005
  
  the_cycle:
    r2 &= 0x0fff                    //mask it, so reserved 4 bits won't be affecting anything
    check1:
      cmp r2, 0x0000                //if starts with 0x0000, then it could special
      jne check2                    //if not then skip to check2
      cmp r1, 0x0000                //maybe it is empty
      je EMPTY                      //then raise EMPTY
      cmp r1, 0x0001                //or even invalid
      je INVALID_CLUSTER            //then raise INVALID_CLUSTER
    check2: //either check was skipped, or completely passed without problems. Starting check2
      cmp r2, 0x0fff                //if starts with 0x0fff, then it could be special
      jne MAIN                      //if not, then copy cluster. All checks were already done.
      cmp r1, 0xfff7                //maybe it is bad?
      je BAD                        //then raise BAD
      cmp r1, 0xfff8                //or is it end of file?
      jge EOF                       //then raise EOF
      cmp r1, 0xfff0                //but if it is 0x0ffffff0-0x0ffffff6, then it is invalid
      jge INVALID_CLUSTER           //then raise INVALID_CLUSTER
      jmp MAIN                      //not special? If so, copy cluster.
    EMPTY:
      r3 = _ChainSeekerEmpty
      [_SeekedTablePosition] = r3
      pop r8, r9 from [sp]
      pop r3, r4 from [sp]
      pop bp, pc from [sp]
    EOF:
      r3 = _ChainSeekerOK
      [_SeekedTablePosition] = r3
      pop r8, r9 from [sp]
      pop r3, r4 from [sp]
      pop bp, pc from [sp]
    BAD:
      r3 = 0x5000
      r1 = _errorBadCluster
      call _print
      call _exit
    INVALID_CLUSTER:
      r3 = 0x5000
      r1 = _errorInvalidCluster
      call _print
      call _exit
    MAIN:
      r3 = r1
      r4 = r2
      
      r1 = r8
      r2 = r9
      call _clusterRead
      
      r14 = r3
      r15 = r4
      call _cachedClusterFATPageRead
      
      r4 = [_ChainSeekerCache + 0x5]//offset
      r4 = r4 lsr 0x1               //shift it so words not bytes
      r3 = _ChainSeekerCache + 0x8  //start of page in ram
      r4 += r3                      //get address in ram
      r1 = [r4]                     //first word of entry
      r4 += 0x1
      r2 = [r4]                     //second word of entry
      
      //NOTE: 16+16=32, can potentially cause problems. 
      //Doing like this because _clusterRead does the same thing.
      r3 = [_Cluster_Size_Bytes0]
      r3 = r3 lsr 0x1
      r8 += r3
      r9 += 0x0000, carry
      
      goto the_cycle
    
    
    goto the_cycle

_directoryFindGameCodeFileSFN:
  push bp, bp to [sp]
  push r1, r4 to [sp]               //temp registers
  push r2, r3 to [sp]               //pointers
  bp = sp + 3
  r3 = 0x0000                       //realpointer (physical address)
  ds = 0x0005                       //additional 6 bits of realpointer (physical address)
  r2 = 0x0000                       //fakepointer (inside the entry)
  
  loop:
    ATTR_GET:
      //Set pointers to ATTR
      r3 += 0x0005
      r2 += 0x0005
      //Get value
      r1 = D:[r3]
      call _byteSwap
      //Mask it, so no SFN and reserved bits in word
      r1 &= 0x003f
    LFN_CHECK:
      //Checking if it is LFN or not
      cmp r1, 0x0f
      jne ATTR_CHECK                //Not LFN? Skip to ATTR_CHECK
    LFN_SKIP:
      //Now, if we found LFN entry, then we need to skip to the entry LFN corresponds to.
      //Set pointers to LDIR_Ord (our pointers were on ATTR if we got to this label)
      r3 -= 0x0005
      r2 -= 0x0005
      //Get value
      r1 = D:[r3]
      //DO NOT Byte-Swap (easier without doing this).
      //Mask 0x3f, so no LFN in the word. Not 0x40 because no need to know if last or not.
      r1 &= 0x003f
      r9 = r3                       //copy realpointer to r9 because it will be overriden
      r4 = 16                       //directory entry size in words
      mr = r1*r4,uu                 //multiply to get position we need to add to pointers
      r1 = r3                       //copy the r3 to r1 because it will be overriden
      r3 = r9                       //and return realpointer
      r3 += r1                      //it is impossible to have 6 and a half KB name, right?
      //3 cycles of carry are never a problem
      r4 = ds                          
      r4 += 0x0000, carry             
      ds = r4                         
      jmp loop
    ATTR_CHECK:
      //if we got to this label, then pointers are guaranteed to be on ATTR
      tstb r1, 3                    //we shouldn't search through partition labels
      jnz SKIP_TO_NEXT
      tstb r1, 4                    //and we shouldn't search through folders
      jnz SKIP_TO_NEXT
    NAME_SEARCH_PREPARE:
      //Set pointers to SFN (our pointers were on ATTR if we got to this label)
      r3 -= 0x0005
      r2 -= 0x0005
    NAME_SEARCH_LOOP:
      //Get value
      r1 = D:[r3]
      cmp r2, 0x0006
      je FIND_FUNCTION_END
      call _byteSwap
      //get the word of the needed name
      r4 = _GameCodeFileSFN
      r4 += r2
      r4 = [r4]
      cmp r2, 0x0000                //if fakepointer is on 0, 
      jne CHECK_AND_MASK_IF_NEEDED  //then go to special check (and if not then do not)
      SPECIAL_CHECK:
        r9 = r1 & 0xff00            //inside r9 we store r1 masked with 0xff00 for first byte
        cmp r9, 0xe500              //if deleted,
        je SKIP_TO_NEXT             //then skip to next
        cmp r9, 0x0000              //if 0x00, then there is no more entries, file not found
        je FIND_FUNCTION_END_NOT_FOUND
      //mask 0xff00, if pointer is 0x5
      CHECK_AND_MASK_IF_NEEDED:
        cmp r2, 0x0005
        jne CHECK_AND_INCREASE_POINTER
        r1 &= 0xff00
        r4 &= 0xff00
      CHECK_AND_INCREASE_POINTER:
        r2 += 0x0001
        r3 += 0x0001
        //compare the word of the needed name with the word of this name
        cmp r1, r4
        je NAME_SEARCH_LOOP         //if they are equal, then check the next word
        //And if they are not equal, we'll skip to next entry
    SKIP_TO_NEXT:
      r4 = 0x0010                   //each directory entry is 16 words long
      r4 -= r2                      //so we get how many words add to realpointer
      r2 = 0x0000                   //reset the fakepointer
      r3 += r4                      //add remainings to 16 to realpointer
      goto loop
      
  FIND_FUNCTION_END:
    //if we got to this label, than our pointers are guaranteed to be 0x0006
    r2 += 0x4                       //add up to 0xa
    r3 += 0x4                       //add up to 0xa
    r4 = D:[r3]                     //get first word of GameCode address
    r2 += 0x3                       //add up to 0xd
    r3 += 0x3                       //add up to 0xd
    r1 = D:[r3]                     //get second word of GameCode address
    r2 = r4                         //move first word to r2
    call _chainSeeker               //and run _chainSeeker!
    
    pop r2, r3 from [sp]            //pointers
    pop r1, r4 from [sp]            //temp registers
    pop bp, pc from [sp]
  FIND_FUNCTION_END_NOT_FOUND:
    r3 = 0x5000
    r1 = _errorGameCodeFileNotFound
    call _print
    
    goto _exit

.endif