.DATA

.ifndef __LIBINCLUDE_INCLUDED__
.define __LIBINCLUDE_INCLUDED__

.define PRINT_END 0x1000

_errorUnsupportedNAND:
  .dw 0x8BAD
  .dw 0xF1A5
  .dw "E:Unsupported NAND!"
_errorGameCodeFileNotFound:
  .dw 0x0000
  .dw 0xF11E
  .dw "E:GameCode not found!"
  .dw PRINT_END
_errorUnsupportedFAT:
  .dw 0x18BA
  .dw 0xDFA7
  .dw "E:Unsupported FAT type!"
  .dw PRINT_END
_errorBadCluster:
  .dw 0xBADC
  .dw 0x1A57
  .dw "E:Bad cluster specified!"
  .dw PRINT_END
_errorInvalidCluster:
  .dw 0x124C
  .dw 0x1A57
  .dw "E:Invalid cluster specified."
_GameCodeFileSFN:
  .dw 0x4741  //GA
  .dw 0x4D45  //ME
  .dw 0x434F  //CO
  .dw 0x4445  //DE
  .dw 0x4249  //BI
  .dw 0x4E00  //N (0x00 will be masked)
_NANDPageWord:
  .dw 0x0400
_NANDFullPageWord:
  .dw 0x0420
_NANDPage:
  .dw 0x0800
_NANDFullPage:
  .dw 0x0840
.define _BootSectorCopyAddress 0x1000
.define _SeekedTablePosition 0x3000
.define _TempClusterRead 0x1500
.define _Data_StartSector0 0x0003
.define _Data_StartSector1 0x0011
.define _Bytes_Per_Sector 0x0002
.define _Data_StartAddress0 0x0000
.define _Data_StartAddress1 0x0001
.define _Root_DirCluster0 0x000d
.define _Root_DirCluster1 0x000e
.define _Root_DirSector0 0x0004
.define _Root_DirSector1 0x0005
.define _Root_DirAddress0 0x000f
.define _Root_DirAddress1 0x0010
.define _Root_DirPage 0x0006
.define _Root_DirOffset 0x0007
.define _Sectors_Per_Cluster 0x000b
.define _Cluster_Size_Bytes0 0x000c
.define _Cluster_Size_Bytes1 0x000d
.define _FATSector 0x0008
.define _FATAddress0 0x0009
.define _FATAddress1 0x000a
.define _ChainSeekerCache 0x0500
.define _ChainSeekerEmpty 0xF7EE
.define _ChainSeekerOK 0x600D
.endif