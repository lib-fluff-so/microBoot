.DATA

.ifndef __LIBINCLUDE_INCLUDED__
.define __LIBINCLUDE_INCLUDED__

.define PRINT_END 0xFADE

_errorUnsupportedNAND:
  .dd 0x8BAD
  .dw 0xF1A5
  .dw 'E: unsupported NAND!'
  .dw PRINT_END
_errorUnsupportedFAT:
  .dd 0x18BA
  .dw 0xDFA7
  .dw "E: unsupported FAT type"
  .dw PRINT_END
_errorCycleChain:
  .dd 0xDEAD
  .dw 0x10CC
  .dw "E: cyclic FAT chain"
  .dw PRINT_END
_errorBadCluster:
  .dd 0xBADC
  .dw 0x1A57
  .dw "E: bad cluster specified"
  .dw PRINT_END
_errorDFAC:
  .dd 0x00DF
  .dw 0xAC00
  .dw "E: DFAC? IDK what happened."
  .dw PRINT_END
_errorBadMath:
  .dw 0x8BAD
  .dw 0xCA1C
  .dw "E: somehow math is not mathing."
  .dw PRINT_END
_ProgramFinished:
  .dw 0xCC00
  .dw 0xFFEE
  .dw "Coffee time! This is bootloader, but it is still not booting anything."
  .dw PRINT_END
_NANDPageWord:
  .dw 0x0400
_NANDFullPageWord:
  .dw 0x0420
_NANDPage:
  .dw 0x0800
_NANDFullPage:
  .dw 0x0840
_BootSectorCopyAddress:
  .dw 0x1000
_ClusterSeekTablePositionFAT:
  .dw 0x3000
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
.define _FATSector 0x0008
.define _FATAddress0 0x0009
.define _FATAddress1 0x000a
.define _FATPage 0x000b
.define _FATOffset 0x000c
.endif