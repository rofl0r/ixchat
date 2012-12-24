# Use config.mak to override any of the following variables.
# Do not make changes here.
#

exec_prefix = /usr/local
bindir = $(exec_prefix)/bin

prefix = /usr/local/
includedir = $(prefix)/include
libdir = $(prefix)/lib

SRCS = $(sort $(wildcard src/common/*.c src/fe-gtk/*.c))
OBJS = $(SRCS:.c=.o)

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

-include config.mak

all: $(ALL_TOOLS) $(PLUGINS)

install: $(ALL_TOOLS:%=$(DESTDIR)$(bindir)/%) install-plugins

install-plugins: $(PLUGINS:%=$(DESTDIR)$(libdir)/xchat/plugins/%)

$(DESTDIR)$(libdir)/xchat/plugins/%: %
	install -D $< $@

$(PERL_HEADERS):
	plugins/perl/generate_header

python.so: plugins/python/python.o
	$(CC) $< -shared -o $@ $(LDFLAGS) $(PY_LDFLAGS)

plugins/python/python.o: plugins/python/python.c
	$(CC) $(CFLAGS) $(PY_CFLAGS) -fPIC -c $< -o $@

perl.so: plugins/perl/perl.o
	$(CC) $< -shared -o $@ $(LDFLAGS) $(PERL_LDFLAGS)

plugins/perl/perl.o: plugins/perl/perl.c $(PERL_HEADERS)
	$(CC) $(CFLAGS) $(PERL_CFLAGS) -fPIC -c $< -o $@

ixchat: $(OBJS)
	$(CC) $(LDFLAGS) -o ixchat $(OBJS)

clean:
	rm -f $(OBJS)
	rm -f $(PIXMAP)
	rm -f $(ALL_TOOLS)
	rm -f $(PERL_HEADERS)

$(PIXMAP): $(PNGS)
	$(PIXMAPCONVERT) --raw --build-list $(PIXMAPLIST) > $(PIXMAP)

%.o: %.c $(PIXMAP)
	$(CC) $(CFLAGS) -c -o $@ $<

$(DESTDIR)$(bindir)/%: %
	install -D $< $@

$(DESTDIR)$(prefix)/%: %
	install -D -m 644 $< $@

.PHONY: all clean install
