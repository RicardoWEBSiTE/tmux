# $Id: Makefile,v 1.3 2007-09-20 18:48:04 nicm Exp $

.SUFFIXES: .c .o .y .h
.PHONY: clean

PROG= tmux
VERSION= 0.1

OS!= uname
REL!= uname -r
DATE!= date +%Y%m%d-%H%M

# This must be empty as OpenBSD includes it in default CFLAGS.
DEBUG=

# Command prefix. This will go when we get a configuration file...
META?= \002 # C-b

SRCS= tmux.c server.c buffer.c buffer-poll.c xmalloc.c xmalloc-debug.c \
      input.c screen.c window.c session.c local.c log.c command.c

YACC= yacc -d

CC= cc
INCDIRS+= -I. -I- -I/usr/local/include
CFLAGS+= -DBUILD="\"$(VERSION) ($(DATE))\"" -DMETA="'${META}'"
.ifdef DEBUG
CFLAGS+= -g -ggdb -DDEBUG
LDFLAGS+= -Wl,-E
.endif
#CFLAGS+= -pedantic -std=c99
CFLAGS+= -Wno-long-long -Wall -W -Wnested-externs -Wformat=2
CFLAGS+= -Wmissing-prototypes -Wstrict-prototypes -Wmissing-declarations
CFLAGS+= -Wwrite-strings -Wshadow -Wpointer-arith -Wcast-qual -Wsign-compare
CFLAGS+= -Wundef -Wshadow -Wbad-function-cast -Winline -Wcast-align

PREFIX?= /usr/local
INSTALLBIN= install -g bin -o root -m 555
INSTALLMAN= install -g bin -o root -m 444

LDFLAGS+= -L/usr/local/lib
LIBS+= -lutil -lncurses

OBJS= ${SRCS:S/.c/.o/:S/.y/.o/}

CLEANFILES= ${PROG} *.o .depend *~ ${PROG}.core *.log

.c.o:
		${CC} ${CFLAGS} ${INCDIRS} -c ${.IMPSRC} -o ${.TARGET}

.y.o:
		${YACC} ${.IMPSRC}
		${CC} ${CFLAGS} ${INCDIRS} -c y.tab.c -o ${.TARGET}

all:		${PROG}

${PROG}:	${OBJS}
		${CC} ${LDFLAGS} -o ${PROG} ${LIBS} ${OBJS}

depend:
		mkdep ${CFLAGS} ${INCDIRS} ${SRCS:M*.c}

clean:
		rm -f ${CLEANFILES}
