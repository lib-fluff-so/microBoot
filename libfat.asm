.TEXT

.ifndef __LIBFAT_INCLUDED__
.define __LIBFAT_INCLUDED__

.include libinclude.asm
.include libmath.asm
.include libnand.asm

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
  
  r14 = [_BootSectorCopyAddress] //It is just easier with this
  
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
  
  
  
  //Root_Dir = Data_Start + (Root_Cluster - 2) * Sectors_Per_Cluster * Bytes_Per_Sector
  //Subtract 2 from Root_Cluster (subtracting only low part, it would work)
  r3 = r14 + 0x16              //get first address of Root_Cluster word
  r3 = [r3]                    //get first Root_Cluster word
  r4 = r14 + 0x17              //get second address of Root_Cluster word
  r4 = [r4]                    //get second Root_Cluster word
  r2 = 0x2                     //prepare subtract value
  r3 -= r2                     //subtract! (not using 32 bit subtract, no reason ever to)
  
  //Multiply the value we got by Sectors_Per_Cluster
  r2 = r14 + 0x6               //get address of first byte of Sectors_Per_Cluster
  r2 = [r2]                    //get first byte of Sectors_Per_Cluster
  r2 &= 0xff00                 //mask it so only first byte will be there
  r2 = r2 lsr 0x4              //shifs, making 8 byte shift in sum,
  r2 = r2 lsr 0x4              //placing it where it should be
  
  call _multiply32x16uu        //and multiply!
  
  [_Root_DirCluster0] = r9     //Root_Dir cluster in RAM
  [_Root_DirCluster1] = r10    //Root_Dir cluster in RAM
  
  //Add the value we got to to Data_Start Sector
  r1 = [_Data_StartSector0]    //Get Data_Start Sector from RAM
  r2 = [_Data_StartSector1]    //Get Data_Start Sector from RAM
  call _add32x32uu             //And add!
  [_Root_DirSector0] = r10     //Root_Dir Sector in RAM
  [_Root_DirSector1] = r11     //Root_Dir Sector in RAM
  
  //Multiply the value we got by Bytes_Per_Sector (will do 32*16)
  r3 = r11                     //get values
  r4 = r10                     //get values
  r2 = [_Bytes_Per_Sector]     //fetch Bytes_Per_Sector value from memory
  call _multiply32x16uu        //multiply again!
  [_Root_DirAddress0] = r9
  [_Root_DirAddress1] = r10
  
  //Get page and offset of Root_Dir
  r3 = r9                      //copy some registers,
  r4 = r10                     //so they would be actual args to divide function
  r2 = [_NANDPage]             //divisor is NAND page size (without OOB)
  call _divide32x16uuSoftware  //YAY!!! DIVIDE!!!
  [_Root_DirPage] = r3         //here goes page
  [_Root_DirOffset] = r4       //here goes in-page offset
  
  
  
  //FAT = Reserved_Sector_Count * Bytes_Per_Sector
  r1 = r14 + 0x7               //get address of Reserved_Sector_Count word
  r1 = [r1]                    //get Reserved_Sector_Count word
  [_FATSector] = r1            //Well... FAT Sector in RAM
  r2 = [_Bytes_Per_Sector]     //fetch Bytes_Per_Sector value from memory
  mr = r1*r2, uu               //and multiply to get address!
  [_FATAddress0] = r3          //FAT address in RAM
  [_FATAddress1] = r4          //FAT address in RAM
  
  //Get page and offset of FAT
  r2 = [_NANDPage]             //divisor is NAND page size (without OOB)
  //NOTE: MR is already set
  call _divide32x16uuSoftware //YAY!!! DIVIDE!!!
  
  r2 = r3                     //swap them to work with them
  r3 = r4                     //swap them to work with them
  r4 = r2                     //swap them to work with them
  
  [_FATPage] = r4             //here goes page
  [_FATOffset] = r3           //here goes offset
  r3 = 0                      //should've been offset, but this is fine as well
                              //guaranteed to have no wacky problems, after all
  
  //Convert form PPPPOOOO to PPPPPPOO
  //NOTE: IDK how it works but it works. Let it be, really.
  r1 = 0x4                    //shift to proper format
  r3 = r3 lsr r1              //shift to proper format (0x8 shift)
  mr |= r4 lsr r1             //shift to proper format (0x8 shift)
  r3 = r3 lsr r1              //shift to proper format (0x8 shift)
  mr |= r4 lsr r1             //shift to proper format (0x8 shift)
  r1 = 0x2000                 //copy address here
  
  call _resetNAND
    
  //Wait (for the sake of god)  
  call _NANDPolling
  
  call _DMACopyNANDPage  //and copy
  
  pop bp, pc from [sp]

//SeekedTable _chainSeeker(uint16 seek=r1)
_chainSeeker:
	//NOTE: TBD

.endif