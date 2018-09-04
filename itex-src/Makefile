#YACC=yacc
YACC=bison -y -v
LEX=flex -P$(YYPREFIX) -olex.yy.c
SWIG=swig
LDFLAGS=
CFLAGS=-g -O2
CXXFLAGS=-g -O2
CPPFLAGS=



RM=rm -f
INSTALL=install -c
wims_home=../..
BINDIR=$(wims_home)/bin

YYPREFIX=itex2MML_yy

all:    y.tab.c lex.yy.c itex2MML

y.tab.c:	itex2MML.y
		$(YACC) -p $(YYPREFIX) -d itex2MML.y

lex.yy.c:	itex2MML.l
		$(LEX) itex2MML.l

y.tab.o:	y.tab.c itex2MML.h
		$(CC) $(CFLAGS) $(CPPFLAGS) -c -o y.tab.o y.tab.c

lex.yy.o:	lex.yy.c y.tab.c itex2MML.h
		$(CC) $(CFLAGS) $(CPPFLAGS) -c -o lex.yy.o lex.yy.c

itex2MML:	lex.yy.o y.tab.o itex2MML.cc itex2MML.h
		$(CXX) $(CFLAGS) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS) -o itex2MML lex.yy.o y.tab.o itex2MML.cc

universal:		
		CFLAGS='-arch i686 -arch ppc' make all

clean:
		$(RM) y.tab.* lex.yy.c itex2MML *.o *.output *.so *.dll *.sl *.bundle

install: itex2MML
		$(INSTALL) itex2MML $(BINDIR)

