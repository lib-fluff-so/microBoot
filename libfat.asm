.TEXT

.ifndef __LIBFAT_INCLUDED__
.define __LIBFAT_INCLUDED__

.include libinclude.asm
.include libmath.asm

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
  //Multiply Number_of_FATs by FAT_Size_32 (NOTE: Only 1 word of FAT_Size_32 is used)
  r1 = r14 + 0x8          //get address of Number_of_FATs word
  r3 = [r1]               //get Number_of_FATs word
  r3 &= 0x00ff            //mask it so only second byte will be there
  r1 = r14 + 0x12         //get address of only ever used part of FAT_Size_32
  r4 = [r1]               //get only ever used part of FAT_Size_32
  mr = r3*r4, uu          //multiply these unsigned values!
  
  //Add value we got to Reserved_Sector_Count (NOTE: No reason to use 32 bit add)
  r1 = r14 + 0x7          //get address of Reserved_Sector_Count word
  r2 = [r1]               //get Reserved_Sector_Count word
  r2 = r2 + r3            //add it!
  
  [0x0003] = r2           //Data_Start sector in RAM
  
  //Multiply Bytes_Per_Sector by the value we got
  r1 = r14 + 0x5          //get address of first byte of Bytes_Per_Sector
  r1 = [r1]               //get first byte of Bytes_Per_Sector
  r1 &= 0xff00            //mask it so only first byte will be there
  r1 = r1 lsr 0x4         //shifts, making 8 bit shift in sum,
  r1 = r1 lsr 0x4         //placing it where it would be in value
  
  r4 = r14 + 0x6          //get address of second byte of Bytes_Per_Sector
  r4 = [r4]               //get second byte of Bytes_Per_Sector
  r4 &= 0x00ff            //mask it so only second byte will be there
  r4 = r4 lsl 0x4         //shifts, making 8 bit shift in sum,
  r4 = r4 lsl 0x4         //placing it where it would be in value
  
  r1 |= r4               //combine those values into one word
  
  [0x0002] = r1          //Bytes_Per_Sector in RAM
  
  mr = r1*r2, uu         //and multiply!
  
  [0x0000] = r3          //Data_Start address in RAM
  [0x0001] = r4          //Data_Start address in RAM
  
  
  
  //Root_Dir = Data_Start + (Root_Cluster - 2) * Sectors_Per_Cluster * Bytes_Per_Sector
  //Subtract 2 from Root_Cluster (NOTE: No reason to use 32 bit subtract)
  r1 = r14 + 0x16        //get address of Root_Cluster word
  r1 = [r1]              //get Root_Cluster word
  r2 = 0x2               //prepare subtract value
  r1 -= r2               //subtract!
  
  //Multiply the value we got by Sectors_Per_Cluster
  r2 = r14 + 0x6         //get address of first byte of Sectors_Per_Cluster
  r2 = [r2]              //get first byte of Sectors_Per_Cluster
  r2 &= 0xff00           //mask it so only first byte will be there
  r2 = r2 lsr 0x4        //shifs, making 8 byte shift in sum,
  r2 = r2 lsr 0x4        //placing it where it should be
  
  mr = r1*r2, uu         //and multiply!
  
  [0x000d] = r3          //Root_Dir from Data_Start in Ram
  [0x000e] = r4          //Root_Dir from Data_Start in Ram
  
  //Add the value we got to to Data_Start Sector
  r1 = [0x0003]          //Get Data_Start Sector from RAM
  r2 = 0x0
  call _add32x32uu       //And add!
  [0x0004] = r9          //Root_Dir Sector in RAM
  [0x0005] = r10         //Root_Dir sector in RAM
  
  //Multiply the value we got by Bytes_Per_Sector (will do 32*16)
  r3 = r9                //Get values
  r4 = r10               //Get values
  r2 = [0x0002]          //fetch Bytes_Per_Sector value from memory
  call _multiply32x16uu  //multiply again!
  
  //Get page and offset of Root_Dir
  r3 = r10               //copy some registers,
  r4 = r11               //so they would be actual args to divide function
  r2 = [_NANDFullPage]   //divisor is NAND page size (with OOB)
  call _divide32x16uuSoftware //YAY!!! DIVIDE!!!
  [0x0006] = r3          //here goes page
  [0x0007] = r4          //here goes in-page offset
  
  
  
  //FAT = Reserved_Sector_Count * Bytes_Per_Sector
  r1 = r14 + 0x7         //get address of Reserved_Sector_Count word
  r1 = [r1]              //get Reserved_Sector_Count word
  [0x0008] = r1          //Well... FAT Sector in RAM
  r2 = [0x0002]          //fetch Bytes_Per_Sector value from memory
  mr = r1*r2, uu         //and multiply to get address!
  [0x0009] = r3          //FAT address in RAM
  [0x000a] = r4          //FAT address in RAM
  
  //Get page and offset of FAT
  r2 = [_NANDFullPage]   //divisor is NAND page size (with OOB)
  //NOTE: MR is already set
  call _divide32x16uuSoftware //YAY!!! DIVIDE!!!
  [0x000b] = r3          //here goes page
  [0x000c] = r4          //here goes in-page offset
  
  pop bp, pc from [sp]

.endif