#####################################################################
#																	 
#	Created by u'nSP IDE V4.1.1		23:03:44	07/09/25
#
#####################################################################




COMPILEDATE = %date:~0,4%%date:~5,2%%date:~8,2%

COMPILEDATE_ = %date:~0,4%-%date:~5,2%-%date:~8,2%

COMPILETIME = %time:~0,2%%time:~3,2%%time:~6,2%

PRJDIR	= C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot

APPDIR	= C:\PROG~5P2\GENE~V14\UNSP~1GG.1

USERDIR	= C:\users\fluff_\AppData\Roaming\Generalplus\unSPIDE

OUTDIR	= .\Debug

MK	= $(APPDIR)\make

CC	= "$(APPDIR)\toolchain\udocc"

AS	= "$(APPDIR)\toolchain\xasm16"

LD	= "$(APPDIR)\toolchain\xlink16"

LDIRAM0	= "$(APPDIR)\toolchain\xlink16_GPCE3_IRAM0"

AR	= "$(APPDIR)\toolchain\xlib16"

RESC	= "$(APPDIR)\toolchain\resc"

RM	= del	/F	1>NUL	2>NUL

STRIP	= "$(APPDIR)\toolchain\stripper"

S37STRIP	= "$(APPDIR)\toolchain\BinaryFileStripper"

RD	= rd /S /Q

GETCHKSUM	= "$(APPDIR)\toolchain\GetChecksum"

HDBPACKER	= "$(APPDIR)\toolchain\HDBPacker"

BOOTPACKER	= "$(APPDIR)\toolchain\BootPacker" 

LIKMODIFIER	= "$(APPDIR)\toolchain\unSP_LIKModifier" 

INCLUDES	= -I"C:/Program Files (x86)/Generalplus/unSPIDE_4.1.1/uBoot" -I"C:/Program Files (x86)/Generalplus/unSPIDE_4.1.1/library/include" -I"C:/Program Files (x86)/Generalplus/unSPIDE_4.1.1/library/include/sys"

BODY	= -body GPL16250VA_CS0Flash -nobdy -bfile "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\uBoot.bdy"

BODYFILE	= "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\uBoot.bdy" 

BINFILE	= "$(OUTDIR)\uBoot.S37"

PRJNAME = uBoot

BODYNAME = GPL16250VA_CS0Flash

SWTOOLID = 0x0008

IDEBUILDVER = 0x04010100

BINFILENOEXT	= $(OUTDIR)\uBoot

ARYFILE	= "$(OUTDIR)\uBoot.ary"

SBMFILE	= "$(OUTDIR)\uBoot.sbm"

OPT	= -S -gstabs -Wall -mglobal-var-iram -mISA=2.0

ASFLAGS	= -t4 -d -sr

CASFLAGS	= -t4 -sr -wpop

CFLAGS	= $(OPT) -B$(APPDIR)\toolchain\ $(INCLUDES) 

BINTYPE	= -as

LDFLAGS	=  -blank 0x00 -initdata

EXTRAFLAGS	= 


OBJFILES	= \
	"$(OUTDIR)\main.obj" \
	"$(OUTDIR)\isr.obj" \
	"$(OUTDIR)\Resource.obj" \
	"$(OUTDIR)\Unused.obj" \
	"$(OUTDIR)\libfat.obj" \
	"$(OUTDIR)\libmath.obj" \
	"$(OUTDIR)\libui.obj" \
	"$(OUTDIR)\liblib.obj" \
	"$(OUTDIR)\libnand.obj" \
	"$(OUTDIR)\libinclude.obj" 

"$(OUTDIR)\main.obj": "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\main.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\main.obj" "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\main.asm" 

"$(OUTDIR)\isr.obj": "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\isr.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\isr.obj" "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\isr.asm" 

"$(OUTDIR)\Resource.obj": "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\Resource.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\Resource.obj" "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\Resource.asm" 

"$(OUTDIR)\Unused.obj": "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\Unused.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\Unused.obj" "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\Unused.asm" 

"$(OUTDIR)\libfat.obj": "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\libfat.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\libfat.obj" "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\libfat.asm" 

"$(OUTDIR)\libmath.obj": "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\libmath.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\libmath.obj" "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\libmath.asm" 

"$(OUTDIR)\libui.obj": "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\libui.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\libui.obj" "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\libui.asm" 

"$(OUTDIR)\liblib.obj": "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\liblib.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\liblib.obj" "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\liblib.asm" 

"$(OUTDIR)\libnand.obj": "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\libnand.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\libnand.obj" "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\libnand.asm" 

"$(OUTDIR)\libinclude.obj": "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\libinclude.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\libinclude.obj" "C:\Program Files (x86)\Generalplus\unSPIDE_4.1.1\uBoot\libinclude.asm" 


.SUFFIXES : .c .asm .obj .s37 .tsk .res

all :	 BEFOREBUILD "$(OUTDIR)" $(BINFILE)

BEFOREBUILD :
	@echo Count=0

"$(OUTDIR)" :
	@if not exist "$(OUTDIR)\$(NULL)" mkdir "$(OUTDIR)"

$(BINFILE) : $(OBJFILES) 
	@echo Count=0
	$(LD) $(BINTYPE) $(ARYFILE) $(BINFILE) $(LDFLAGS) $(BODY) $(EXTRAFLAGS) -undefined-opt __TgP190708CM -undefined-opt __TgP190708CL -undefined-opt __TgP190708M
	@echo Count=0

compile :	 $(OBJFILES)

CLEANFILES = \
	"$(OUTDIR)\main.obj" \
	"$(OUTDIR)\main.lst" \
	"$(OUTDIR)\isr.obj" \
	"$(OUTDIR)\isr.lst" \
	"$(OUTDIR)\Resource.obj" \
	"$(OUTDIR)\Resource.lst" \
	"$(OUTDIR)\Unused.obj" \
	"$(OUTDIR)\Unused.lst" \
	"$(OUTDIR)\libfat.obj" \
	"$(OUTDIR)\libfat.lst" \
	"$(OUTDIR)\libmath.obj" \
	"$(OUTDIR)\libmath.lst" \
	"$(OUTDIR)\libui.obj" \
	"$(OUTDIR)\libui.lst" \
	"$(OUTDIR)\liblib.obj" \
	"$(OUTDIR)\liblib.lst" \
	"$(OUTDIR)\libnand.obj" \
	"$(OUTDIR)\libnand.lst" \
	"$(OUTDIR)\libinclude.obj" \
	"$(OUTDIR)\libinclude.lst" \
	"$(BINFILENOEXT).s37" \
	"$(BINFILENOEXT).tsk" \
	"$(BINFILENOEXT)_SPI.bin*" \
	"$(BINFILENOEXT).hdb" \
	"$(BINFILENOEXT).lod" \
	"$(BINFILENOEXT).map" \
	"$(BINFILENOEXT).sbm" \
	"$(BINFILENOEXT).sym" \
	"$(BINFILENOEXT).smy" \
	$(SBMFILE)

clean :
	$(RM) $(wordlist 1,30,$(CLEANFILES))

.c.asm:
	$(CC) $(CFLAGS) $(INCLUDES) -o "$(OUTDIR)\$@" $<

.asm.obj:
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\$@" $<

