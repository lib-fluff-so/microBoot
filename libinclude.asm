.DATA

.ifndef __LIBINCLUDE_INCLUDED__
.define __LIBINCLUDE_INCLUDED__

_errorUnsupportedNAND:  
  .dw 'The system halted: unsupported NAND!'  
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

.endif