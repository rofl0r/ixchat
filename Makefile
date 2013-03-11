# Use config.mak to override any of the following variables.
# Do not make changes here.
#

exec_prefix = /usr/local
bindir = $(exec_prefix)/bin

prefix = /usr/local/
includedir = $(prefix)/include
libdir = $(prefix)/lib

SRCS = $(sort $(wildcard src/common/*.c))
SRCS_FE_GTK = $(sort $(wildcard src/fe-gtk/*.c))
SRCS_FE_TEXT = $(sort $(wildcard src/fe-text/*.c))
OBJS = $(SRCS:.c=.o)
OBJS_FE_GTK  = $(SRCS_FE_GTK:.c=.o)
OBJS_FE_TEXT = $(SRCS_FE_TEXT:.c=.o)

CFLAGS += -Os 

ALL_TOOLS=ixchat

PIXMAP=src/pixmaps/inline_pngs.h
_PNGS = message.png highlight.png fileoffer.png book.png hop.png op.png purple.png red.png voice.png
pixsrcdir=src/pixmaps
PNGS = $(pixsrcdir)/message.png $(pixsrcdir)/highlight.png $(pixsrcdir)/fileoffer.png \
       $(pixsrcdir)/book.png $(pixsrcdir)/hop.png $(pixsrcdir)/op.png $(pixsrcdir)/purple.png \
       $(pixsrcdir)/red.png $(pixsrcdir)/voice.png

PIXMAPLIST = traymsgpng $(pixsrcdir)/message.png \
             trayhilightpng $(pixsrcdir)/highlight.png \
             trayfilepng $(pixsrcdir)/fileoffer.png \
             bookpng $(pixsrcdir)/book.png \
             hoppng $(pixsrcdir)/hop.png \
             oppng $(pixsrcdir)/op.png \
             purplepng $(pixsrcdir)/purple.png \
             redpng $(pixsrcdir)/red.png \
             voicepng $(pixsrcdir)/voice.png \
             xchatpng $(pixsrcdir)/../../xchat.png

PERL_HEADERS = plugins/perl/irc.pm.h plugins/perl/xchat.pm.h
PERL_HEADERS_INPUT = plugins/perl/lib/IRC.pm \
                     plugins/perl/lib/Xchat.pm \
                     plugins/perl/lib/Xchat/Embed.pm \
                     plugins/perl/lib/Xchat/List/Network.pm \
                     plugins/perl/lib/Xchat/List/Network/Entry.pm\
                     plugins/perl/lib/Xchat/List/Network/AutoJoin.pm

INSTALL_FLAGS=-D -m

-include config.mak

all: $(ALL_TOOLS) $(PLUGINS)

install: $(ALL_TOOLS:%=$(DESTDIR)$(bindir)/%) install-plugins

install-plugins: $(PLUGINS:%=$(DESTDIR)$(libdir)/xchat/plugins/%)

$(DESTDIR)$(libdir)/xchat/plugins/%: %
	install -d $(DESTDIR)$(libdir)/xchat/plugins
	install $(INSTALL_FLAGS) 644 $< $@

$(PERL_HEADERS): $(PERL_HEADERS_INPUT)
	plugins/perl/generate_header

tcl.so: plugins/tcl/tcl.o
	$(CC) $< -shared -rdynamic -o $@ $(LDFLAGS) $(TCL_LDFLAGS)

plugins/tcl/tcl.o: plugins/tcl/tclplugin.c
	$(CC) $(CFLAGS) $(TCL_CFLAGS) -fPIC -c $< -o $@

python.so: plugins/python/python.o
	$(CC) $< -shared -rdynamic -o $@ $(LDFLAGS) $(PY_LDFLAGS)

plugins/python/python.o: plugins/python/python.c
	$(CC) $(CFLAGS) $(PY_CFLAGS) -fPIC -c $< -o $@

perl.so: plugins/perl/perl.o
	$(CC) $< -shared -rdynamic -o $@ $(LDFLAGS) $(PERL_LDFLAGS)

plugins/perl/perl.o: plugins/perl/perl.c $(PERL_HEADERS)
	$(CC) $(CFLAGS) $(PERL_CFLAGS) -fPIC -c $< -o $@

ixchat: $(OBJS) $(OBJS_FE_GTK)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(OBJS_FE_GTK)

ixchat-text: $(OBJS) $(OBJS_FE_TEXT)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(OBJS_FE_TEXT)

clean:
	rm -f $(OBJS)
	rm -f $(OBJS_FE_GTK)
	rm -f $(OBJS_FE_TEXT)
	rm -f $(PIXMAP)
	rm -f $(ALL_TOOLS)
	rm -f $(PERL_HEADERS)
	rm -f $(PLUGINS)
	rm -f plugins/perl/*.o
	rm -f plugins/python/*.o
	rm -f plugins/tcl/*.o

$(PIXMAP): $(PNGS)
	$(PIXMAPCONVERT) --raw --build-list $(PIXMAPLIST) > $(PIXMAP)

%.o: %.c $(PIXMAP)
	$(CC) $(CFLAGS) -c -o $@ $<

$(DESTDIR)$(bindir)/%: %
	install -d $(DESTDIR)$(bindir)
	install $(INSTALL_FLAGS) 755 $< $@

$(DESTDIR)$(prefix)/%: %
	install $(INSTALL_FLAGS) 644 $< $@

.PHONY: all clean install
