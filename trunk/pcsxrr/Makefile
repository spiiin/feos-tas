VERSION_MAJOR=1
VERSION_MINOR=5
VERSION=$(VERSION_MAJOR).$(VERSION_MINOR)

CC=gcc
CXX=g++
RC=windres
UPX=upx
BASEFLAGS=-W -Wall -Winit-self -Wpointer-arith -Wcast-align -Wwrite-strings \
  -march=i686 -mtune=generic -fomit-frame-pointer -finline-functions -ffast-math \
  -DPCSX_VERSION=\"${VERSION}\" -D__MINGW32__ -D_FILE_OFFSET_BITS=64 -D__MINGW_USE_VC2005_COMPAT -DWIN32_LEAN_AND_MEAN \
  -IWin32 -I.
CFLAGS=$(BASEFLAGS) -Wbad-function-cast -Wc++-compat
CXXFLAGS=$(BASEFLAGS) -Wnon-virtual-dtor -Wstrict-null-sentinel -fno-exceptions -fno-rtti
#-Wold-style-cast
LFLAGS=-lz -lcomctl32 -lcomdlg32 -lgdi32 -llua -static-libgcc -static-libstdc++
OE=.o
ODE=.od
OUTE=.exe
DEP=makefile.dep
RM=del
CMDSEP=&

ifndef WINDIR
  MINGW_BASE=i686-w64-mingw32
  CC=$(MINGW_BASE)-gcc
  CXX=$(MINGW_BASE)-g++
  RC=$(MINGW_BASE)-windres
  RM=rm -f
  CMDSEP=;
endif

MAIN_SRC=PsxBios.cpp Gte.cpp CdRom.cpp PsxCounters.cpp PsxDma.cpp DisR3000A.cpp Spu.cpp Sio.cpp PsxHw.cpp Mdec.cpp PsxMem.cpp Misc.cpp \
  plugins.cpp Decode_XA.cpp R3000A.cpp PsxInterpreter.cpp PsxHLE.cpp movie.cpp cheat.cpp LuaEngine.cpp
IX86_SRC=ix86/iR3000A.cpp ix86/ix86.cpp
WIN32_SRC=Win32/WndMain.cpp Win32/Plugin.cpp Win32/ConfigurePlugins.cpp Win32/AboutDlg.cpp Win32/ramwatch.cpp Win32/ram_search.cpp \
  Win32/memcheat.cpp Win32/maphkeys.cpp Win32/moviewin.cpp Win32/luaconsole.cpp
RES_SRC=Win32/pcsx.rc

SOURCES=$(MAIN_SRC) $(IX86_SRC) $(WIN32_SRC) $(RES_SRC)
OBJECTS=$(patsubst %.rc,%$(OE),$(patsubst %.c,%$(OE),$(patsubst %.cpp,%$(OE),$(SOURCES))))
DOBJECTS=$(patsubst %.rc,%$(OE),$(patsubst %.c,%$(ODE),$(patsubst %.cpp,%$(ODE),$(SOURCES))))

.SUFFIXES: .c .cpp .rc

%$(OE): %.c
	$(CC) $(CFLAGS) -O3 -o $@ -c $<

%$(OE): %.cpp
	$(CXX) $(CXXFLAGS) -O3 -o $@ -c $<

%$(ODE): %.c
	$(CC) $(CFLAGS) -O1 -ggdb3 -o $@ -c $<

%$(ODE): %.cpp
	$(CXX) $(CXXFLAGS) -O1 -ggdb3 -o $@ -c $<

%$(OE): %.rc
	$(RC) $< $@


ALL: pcsx$(OUTE)
debug: pcsx_debug$(OUTE)


pcsx$(OUTE): $(OBJECTS)
	$(CXX) -o $@ $(OBJECTS) $(LFLAGS) -mwindows -s
	$(UPX) --best --lzma $@

pcsx_debug$(OUTE): $(DOBJECTS)
	$(CXX) -o $@ $(DOBJECTS) $(LFLAGS) -mwindows -ggdb3


include $(DEP)

$(DEP): Makefile $(SOURCES)
	$(RM) $(DEP)
#USE -M to include library headers, -MM to exclude them
	$(foreach file,$(filter %.c,$(SOURCES)),$(CC) -MM -MG -MT "$(patsubst %.c,%$(OE),$(file)) $(patsubst %.c,%$(ODE),$(file))" $(CFLAGS) $(file) >> $@ $(CMDSEP))
	$(foreach file,$(filter %.cpp,$(SOURCES)),$(CXX) -MM -MG -MT "$(patsubst %.cpp,%$(OE),$(file)) $(patsubst %.cpp,%$(ODE),$(file))" $(CXXFLAGS) $(file) >> $@ $(CMDSEP))

clean:
	$(RM) pcsx$(OUTE) pcsx_debug$(OUTE) $(OBJECTS) $(DOBJECTS) $(DEP)
