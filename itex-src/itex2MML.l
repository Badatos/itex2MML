/*             itex2MML 1.4.11
 *   itex2MML.l last modified 9/3/2013
 */

%{
%}
%option noyywrap
%x MATH FINDARG ATTRIBUTELIST BBOLD FRAKTUR CALLIGRAPHIC ROMAN PLAINTEXT INT1 INT2 INT3 MATHENV SVGENV SVGEND HTMLENV HTMLEND  OPTARG ARRAYOPTIONS COLOPTS TEXTOPTARG TEXTOPTARG1 RAISEBOX1 RAISEBOX2
%{
#include <string.h>

#define YYSTYPE char *

#include "y.tab.h"
#include "itex2MML.h"

#define YY_NEVER_INTERACTIVE 1
#define YY_INPUT(buffer,result,max_size) result = s_itex2MML_read (buffer, max_size)

static int s_itex2MML_read (char * buffer, int max_size);

#define yylval itex2MML_yylval
#define itex2MML_optarg_depth 100

extern char * yylval;

int itex2MML_lineno = 1;
int itex2MML_inoptarg[itex2MML_optarg_depth];
int itex2MML_optarg_ind = 0;
int itex2MML_env_start = 0;

int itex2MML_rowposn = 0;
int itex2MML_displaymode = 0;

%} 
%%
%{ if (itex2MML_rowposn==1) itex2MML_rowposn=0;
   if (itex2MML_rowposn==2) itex2MML_rowposn=1;
%}

<INITIAL>"$"{1,2}   BEGIN(MATH); itex2MML_inoptarg[0] = 0; itex2MML_rowposn=2; if (yyleng==2) { itex2MML_displaymode=1; return STARTDMATH;}; itex2MML_displaymode=0; return STARTMATH;
<INITIAL>"\\[" BEGIN(MATH); itex2MML_inoptarg[0] = 0; itex2MML_rowposn=2; itex2MML_displaymode=1; return STARTDMATH;
<INITIAL>EOF    return 0;
<INITIAL>"\n" {itex2MML_lineno++; yylval=itex2MML_copy_string(yytext); return CHAR;}
<INITIAL>.     {yylval=itex2MML_copy_string(yytext); return CHAR;}


<MATH>{



"$"{1,2} |
"\\]"           {BEGIN(INITIAL); return ENDMATH;}


"^"            return SUP;
"_"            return SUB; 
"{"[\t\r\n ]*"}"   return EMPTYMROW;
"{"            {itex2MML_rowposn = 2; if(itex2MML_inoptarg[itex2MML_optarg_ind] != 0) itex2MML_inoptarg[itex2MML_optarg_ind]++; return MROWOPEN;}
"}"            {if(itex2MML_inoptarg[itex2MML_optarg_ind] != 0) itex2MML_inoptarg[itex2MML_optarg_ind]--; return MROWCLOSE;}

"\\left"       {itex2MML_rowposn=2; return LEFT;}
"\\right"      {return RIGHT;}

"\\big"   |
"\\bigr"  {return BIG;}
"\\Big"   |
"\\Bigr"  {return BBIG;}
"\\bigg"  |
"\\biggr" {return BIGG;}
"\\Bigg"  |
"\\Biggr" {return BBIGG;}

"\\bigl"  {return BIGL;}
"\\Bigl"  {return BBIGL;}
"\\biggl" {return BIGGL;}
"\\Biggl" {return BBIGGL;}

"\\mathrlap"  {return RLAP;}
"\\mathllap"  {return LLAP;}
"\\mathclap"  {return CLAP;}
"\\rlap" |
"\\llap" |
"\\ulap" |
"\\dlap"               {/* Ignore */ ;}


"&amp;" |
"&"         {itex2MML_rowposn=2; return COLSEP;}

"\\&"           {yylval=itex2MML_copy_string("&amp;"); return MI;}

"\\$"           {yylval=itex2MML_copy_string("$"); return MI;}
"\\%"           {yylval=itex2MML_copy_string("%"); return MI;}


[a-zA-Z]+       {yylval=itex2MML_copy_string(yytext); return MI;}

[0-9]{1,3}(,[0-9]{3,3})*(\.[0-9]+)? |
[0-9]*[\.][0-9]+                   |
[0-9]+           {yylval=itex2MML_copy_string(yytext); return MN;}
"\\infty"   |
"\\infinity"     {yylval=itex2MML_copy_string("&infin;"); return MN;}

"("   |
"["             {yylval=itex2MML_copy_string(yytext); return LEFTDELIM;}

")"   {yylval=itex2MML_copy_string(yytext); return RIGHTDELIM;}
"]"   {if(itex2MML_inoptarg[itex2MML_optarg_ind]==1 && itex2MML_optarg_ind > 0) {itex2MML_inoptarg[itex2MML_optarg_ind]=0; itex2MML_optarg_ind--; return OPTARGCLOSE;} else {yylval=itex2MML_copy_string(yytext); return RIGHTDELIM;}}

"\\lgroup" |
"\\lpar" {yylval=itex2MML_copy_string("("); return OTHERDELIM;}

"\\rgroup" |
"\\rpar" {yylval=itex2MML_copy_string(")"); return OTHERDELIM;}

"\\lbracket" {yylval=itex2MML_copy_string("["); return OTHERDELIM;}
"\\rbracket" {yylval=itex2MML_copy_string("]"); return OTHERDELIM;}

"\\lbrace" |
"\\{"       {yylval=itex2MML_copy_string("{"); return OTHERDELIM;}

"\\rbrace" |
"\\}"       {yylval=itex2MML_copy_string("}"); return OTHERDELIM;}


"||" |
"\\||" |
"\\Arrowvert" |
"\\vert\\vert" |
"\\Vert"   {yylval=itex2MML_copy_string("&DoubleVerticalBar;"); return OTHERDELIM;}


"|" |
"\\|" |
"\\vert" |
"\\arrowvert" {yylval=itex2MML_copy_string("&VerticalBar;"); return OTHERDELIM;}

"\\lvert" |
"\\bracevert"  {yylval=itex2MML_copy_string("&VerticalBar;"); return LEFTDELIM;}
"\\rvert"  {yylval=itex2MML_copy_string("&VerticalBar;"); return RIGHTDELIM;}


"\\setminus"   {yylval=itex2MML_copy_string("&setminus;"); return MO;}
"\\backslash"   {yylval=itex2MML_copy_string("&bsol;"); return MO;}
"\\smallsetminus"   {yylval=itex2MML_copy_string("&#xFE68;"); return MOF;}

"\\sslash" {yylval=itex2MML_copy_string("&parsl;"); return MO;}

"\\lfloor" |
"\\lceil"  |
"\\lmoustache" |
"\\lang"   |
"\\langle"      {yylval=itex2MML_copy2(yytext, ";"); if (yylval != itex2MML_empty_string) yylval[0]='&'; return LEFTDELIM;}
"\\llangle"     {yylval=itex2MML_copy_string("&Lang;"); return LEFTDELIM;}

"\\rfloor" |
"\\rceil"  |
"\\rmoustache" |
"\\rang"   |
"\\rangle"      {yylval=itex2MML_copy2(yytext, ";"); if (yylval != itex2MML_empty_string) yylval[0]='&'; return RIGHTDELIM;}
"\\rrangle"     {yylval=itex2MML_copy_string("&Rang;"); return RIGHTDELIM;}

"/"             {yylval=itex2MML_copy_string(yytext); return OTHERDELIM;}

"\\uparrow"   |
"\\downarrow" |
"\\updownarrow" {yylval=itex2MML_copy2(yytext, ";"); if (yylval != itex2MML_empty_string) yylval[0]='&'; return OTHERDELIM;}

"."             {yylval=itex2MML_copy_string(yytext); return PERIODDELIM;}

"-"    {if (itex2MML_rowposn==1) return UNARYMINUS; else {yylval=itex2MML_copy_string("&minus;"); return MO;}}

"+"    {if (itex2MML_rowposn==1) return UNARYPLUS; else {yylval=itex2MML_copy_string("+"); return MO;}}

"\\#" {yylval=itex2MML_copy_string("#"); return MOL;}

","   |
":"   |
"!"   |
"="   |
"~"   |
";"   |
"?"   |
"#"   |
"`"   |
"*"        {yylval=itex2MML_copy_string(yytext); return MOL;}

"\\prime"  {yylval=itex2MML_copy_string("&prime;"); return MOLL;}
"'"        {yylval=itex2MML_copy_string("&prime;"); return MOL;}
"''"     {yylval=itex2MML_copy_string("&Prime;"); return MOL;}
"'''"  {yylval=itex2MML_copy_string("&#8244;"); return MOL;}
"''''"  {yylval=itex2MML_copy_string("&#8279;"); return MOL;}

"\\alpha"   |
"\\beta" |
"\\gamma" |
"\\delta" |
"\\zeta" |
"\\eta"  |
"\\theta" |
"\\iota"  |
"\\kappa" |
"\\lambda" |
"\\mu"     |
"\\nu"    |
"\\xi"   |
"\\pi"     |
"\\rho"   |
"\\sigma"  |
"\\tau"   |
"\\upsilon" |
"\\chi"  |
"\\psi"  |
"\\omega" |
"\\backepsilon"   |
"\\varkappa" |
"\\varpi" |
"\\varrho" |
"\\varsigma" |
"\\vartheta"      {yylval=itex2MML_copy2(yytext, ";"); if (yylval != itex2MML_empty_string) yylval[0]='&'; return MI;}

"\\varepsilon" {yylval=itex2MML_copy_string("&#x03B5;"); return MI;}
"\\phi"  {yylval=itex2MML_copy_string("&#x03D5;"); return MI;}
"\\varphi"  {yylval=itex2MML_copy_string("&#x03C6;"); return MI;}

"\\arccos"  |
"\\arcsin"  |
"\\arctan"  |
"\\arg"     |
"\\Arg"     |
"\\cos"     |
"\\cosh"    |
"\\cot"     |
"\\coth"    |
"\\csc"     |
"\\dim"     |
"\\exp"     |
"\\hom"     |
"\\ker"     |
"\\lg"      |
"\\ln"      |
"\\log"     |
"\\sec"     |
"\\sin"     |
"\\sinh"    |
"\\tan"     |
"\\tanh"    {yylval=itex2MML_copy_string(yytext+1); return MI;}

"\\det"     |
"\\gcd"     |
"\\inf"     |
"\\lim"     |
"\\liminf"  |
"\\limsup"  |
"\\max"     |
"\\min"     |
"\\Pr"      |
"\\sup"    {yylval=itex2MML_copy_string(yytext+1); return MIB;}

"\\omicron"  {yylval=itex2MML_copy_string("&oscr;"); return MI;}

"\\epsilon"  {yylval=itex2MML_copy_string("&epsi;"); return MI;}

"\\cdot"   {yylval=itex2MML_copy_string("&sdot;"); return MO;}

"\\Alpha"   |
"\\Beta" |
"\\Delta"  |
"\\Gamma"  |
"\\digamma"  |
"\\Lambda" |
"\\Pi"     |
"\\Phi"    |
"\\Psi"    |
"\\Sigma"  |
"\\Theta"  |
"\\Xi"     |
"\\Zeta" |
"\\Eta"  |
"\\Iota"  |
"\\Kappa" |
"\\Mu"     |
"\\Nu"    |
"\\Rho"   |
"\\Tau"  | 
"\\mho"  | 
"\\Omega"     {yylval=itex2MML_copy2(yytext, ";"); if (yylval != itex2MML_empty_string) yylval[0]='&'; return MI;}

"\\Upsilon" |
"\\Upsi" {yylval=itex2MML_copy_string("&Upsi;"); return MI;}

"\\iff" {yylval=itex2MML_copy_string("&iff;"); return MOL;}
"\\longleftarrow" {yylval = itex2MML_copy_string("&#x27F5;"); return MOL;}
"\\Longleftarrow" {yylval = itex2MML_copy_string("&xlArr;"); return MOL;}
"\\Longleftrightarrow"  {yylval=itex2MML_copy_string("&#x27FA;"); return MOL;}
"\\Leftrightarrow"  {yylval=itex2MML_copy_string("&Leftrightarrow;"); return MOL;}
"\\longleftrightarrow" {yylval=itex2MML_copy_string("&#x27F7;"); return MOL;}

"\\impliedby" |
"\\Leftarrow"   {yylval=itex2MML_copy_string("&Leftarrow;"); return MOL;}

"\\implies" |
"\\Rightarrow"   {yylval=itex2MML_copy_string("&Rightarrow;"); return MOL;}

"\\hookleftarrow" {yylval=itex2MML_copy_string("&hookleftarrow;"); return MOL;}

"\\embedsin" |
"\\hookrightarrow"  {yylval=itex2MML_copy_string("&hookrightarrow;"); return MOL;}

"\\longrightarrow"  {yylval=itex2MML_copy_string("&longrightarrow;"); return MOL;}

"\\Longrightarrow"  {yylval=itex2MML_copy_string("&#x27F9;"); return MOL;}

"\\leftarrow"   {yylval=itex2MML_copy_string("&leftarrow;"); return MOL;}

"\\to"    |
"\\rightarrow"  {yylval=itex2MML_copy_string("&rightarrow;"); return MOL;}

"\\leftrightarrow"  {yylval=itex2MML_copy_string("&leftrightarrow;"); return MOL;}

"\\longmapsto" {yylval = itex2MML_copy_string("&#x27FC;"); return MOL;}
"\\Longmapsfrom" {yylval = itex2MML_copy_string("&#x27FD;"); return MOL;}
"\\Longmapsto" {yylval = itex2MML_copy_string("&#x27FE;"); return MOL;}

"\\mapsto"  |
"\\map"       {yylval=itex2MML_copy_string("&map;"); return MOL;}

"\\nearrow" |
"\\nearr"    {yylval=itex2MML_copy_string("&nearr;"); return MOL;}

"\\nwarrow" |
"\\nwarr"     {yylval=itex2MML_copy_string("&nwarr;"); return MOL;}

"\\searrow" |
"\\searr"     {yylval=itex2MML_copy_string("&searr;"); return MOL;}

"\\swarrow" |
"\\swarr"     {yylval=itex2MML_copy_string("&swarr;"); return MOL;}

"\\neArrow" |
"\\neArr"    {yylval=itex2MML_copy_string("&neArr;"); return MOL;}

"\\nwArrow" |
"\\nwArr"     {yylval=itex2MML_copy_string("&nwArr;"); return MOL;}

"\\seArrow" |
"\\seArr"     {yylval=itex2MML_copy_string("&seArr;"); return MOL;}

"\\swArrow" |
"\\swArr"     {yylval=itex2MML_copy_string("&swArr;"); return MOL;}

"\\darr"     {yylval=itex2MML_copy_string("&darr;"); return MOL;}

"\\Downarrow" {yylval=itex2MML_copy_string("&dArr;"); return MOL;}

"\\uparr"    {yylval=itex2MML_copy_string("&uarr;"); return MOL;}

"\\Uparrow" {yylval=itex2MML_copy_string("&uArr;"); return MOL;}

"\\downuparrow" |
"\\duparr" |
"\\updarr"  {yylval=itex2MML_copy_string("&updownarrow;"); return MOL;}

"\\Updownarrow"  {yylval=itex2MML_copy_string("&Updownarrow;"); return MOL;}

"\\leftsquigarrow"       {yylval=itex2MML_copy_string("&#x21DC;"); return MOL;}
"\\rightsquigarrow"      {yylval=itex2MML_copy_string("&zigrarr;"); return MOL;}
"\\dashleftarrow"        {yylval=itex2MML_copy_string("&#x290E;"); return MOL;}
"\\dashrightarrow"       {yylval=itex2MML_copy_string("&#x290F;"); return MOL;}
"\\curvearrowbotright"   {yylval=itex2MML_copy_string("&#x293B;"); return MOL;}
"\\righttoleftarrow"     {yylval=itex2MML_copy_string("&#x27F2;"); return MOL;}
"\\lefttorightarrow"     {yylval=itex2MML_copy_string("&#x27F3;"); return MOL;}
"\\leftrightsquigarrow" |
"\\upuparrows"          |
"\\rightleftarrows"     |
"\\rightrightarrows"    |
"\\curvearrowleft"      |
"\\curvearrowright"     |
"\\downdownarrows"      |
"\\leftarrowtail"       |
"\\rightarrowtail"      |
"\\leftleftarrows"      |
"\\leftrightarrows"     |
"\\Lleftarrow"          |
"\\Rrightarrow"         |
"\\looparrowleft"       |
"\\looparrowright"      |
"\\Lsh"                 |
"\\Rsh"                 |
"\\circlearrowleft"     |
"\\circlearrowright"    |
"\\twoheadleftarrow"    |
"\\twoheadrightarrow"   |
"\\nLeftarrow"          |
"\\nleftarrow"          |
"\\nLeftrightarrow"     |
"\\nleftrightarrow"     |
"\\nRightarrow"         |
"\\nrightarrow"         |
"\\rightharpoonup"      |
"\\rightharpoondown"    |
"\\leftharpoonup"       |
"\\leftharpoondown"     |
"\\downharpoonleft"     |
"\\downharpoonright"    |
"\\leftrightharpoons"   |
"\\rightleftharpoons"   |
"\\upharpoonleft"       |
"\\upharpoonright"   {yylval=itex2MML_copy2(yytext, ";"); if (yylval != itex2MML_empty_string) yylval[0]='&'; return MOL;}

"\\xrightarrow"        |
"\\xleftarrow"         |
"\\xleftrightarrow"    |
"\\xLeftarrow"         |
"\\xRightarrow"        |
"\\xLeftrightarrow"    |
"\\xleftrightharpoons" |
"\\xrightleftharpoons" |
"\\xhookleftarrow"     |
"\\xhookrightarrow"    |
"\\xmapsto" {BEGIN(OPTARG); char * s1 = itex2MML_copy_string(yytext+2); yylval = itex2MML_copy3("&", s1, ";"); itex2MML_free_string(s1); return XARROW;}

"\\dots" |
"\\ldots"  {yylval=itex2MML_copy_string("&hellip;"); return MI;}
"\\cdots"   {yylval=itex2MML_copy_string("&ctdot;"); return MI;}
"\\ddots"   {yylval=itex2MML_copy_string("&dtdot;"); return MI;}
"\\udots"   {yylval=itex2MML_copy_string("&utdot;"); return MI;}
"\\vdots"   {yylval=itex2MML_copy_string("&vellip;"); return MI;}
"\\colon"   {yylval=itex2MML_copy_string("&colon;"); return MOR;}

"\\cup"  |
"\&union;" |
"\\union"          {yylval=itex2MML_copy_string("&cup;"); return MOL;}

"\\bigcup" |
"\\Union"  |
"\&Union;"      {yylval=itex2MML_copy_string("&Union;"); return MOB;}

"\\cap"  |
"\\intersection"          {yylval=itex2MML_copy_string("&cap;"); return MOL;}

"\\bigcap" |
"\\Intersection"       {yylval=itex2MML_copy_string("&Intersection;"); return MOB;}

"\\in"           {yylval=itex2MML_copy_string("&Element;"); return MOL;}

 /* For some reason, Firefox does not put in the right spacing around some of these operators
  * unless we ask for it, explicitly.
  */
"\\coloneqq"     {yylval=itex2MML_copy_string("&colone;"); return MOL;}
"\\Coloneqq"     {yylval=itex2MML_copy_string("&Colone;"); return MOS;}
"\\coloneq"      {yylval=itex2MML_copy_string("&#x2236;&#x2212;"); return MOS;}
"\\Coloneq"      {yylval=itex2MML_copy_string("&#x2237;&#x2212;"); return MOS;}
"\\eqqcolon"     {yylval=itex2MML_copy_string("&ecolon;"); return MOS;}
"\\Eqqcolon"     {yylval=itex2MML_copy_string("&#x003d;&#x2237;"); return MOS;}
"\\eqcolon"      {yylval=itex2MML_copy_string("&#x2239;"); return MOS;}
"\\Eqcolon"      {yylval=itex2MML_copy_string("&#x2212;&#x2237;"); return MOS;}
"\\colonapprox"  {yylval=itex2MML_copy_string("&#x2236;&#x2248;"); return MOS;}
"\\Colonapprox"  {yylval=itex2MML_copy_string("&#x2237;&#x2248;"); return MOS;}
"\\colonsim"     {yylval=itex2MML_copy_string("&#x2236;&#x223C;"); return MOS;}
"\\Colonsim"     {yylval=itex2MML_copy_string("&#x2237;&#x223C;"); return MOS;}
"\\dblcolon"     {yylval=itex2MML_copy_string("&Colon;"); return MOL;}

"\\ast"  |
"\\Cap"  |
"\\Cup"  |
"\\circledast"  |
"\\circledcirc" |
"\\curlyvee"    |
"\\curlywedge"  |
"\\divideontimes" |
"\\dotplus" |
"\\leftthreetimes" |
"\\rightthreetimes" |
"\\veebar" |
"\\gt"   |
"\\lt"   |
"\\approxeq"   |
"\\backsim"   |
"\\backsimeq"   |
"\\barwedge"    |
"\\doublebarwedge" |
"\\subset"  |
"\\subseteq" |
"\\subseteqq" |
"\\subsetneq" |
"\\subsetneqq" |
"\\varsubsetneq" |
"\\varsubsetneqq" |
"\\prec"     |
"\\parallel"  |
"\\nparallel" |
"\\shortparallel" |
"\\nshortparallel" |
"\\perp"  |
"\\eqslantgtr" |
"\\eqslantless" |
"\\gg" |
"\\ggg" |
"\\geq" |
"\\geqq" |
"\\geqslant" |
"\\gneq" |
"\\gneqq" |
"\\gnapprox" |
"\\gnsim" |
"\\gtrapprox" |
"\\ge"  |
"\\le"  |
"\\leq" |
"\\leqq" |
"\\leqslant" |
"\\lessapprox" |
"\\lessdot" |
"\\lesseqgtr" |
"\\lesseqqgtr" |
"\\lessgtr" |
"\\lneq" |
"\\lneqq" |
"\\lnsim" |
"\\lvertneqq" |
"\\gtrsim" |
"\\gtrdot" |
"\\gtreqless" |
"\\gtreqqless" |
"\\gtrless" |
"\\gvertneqq" |
"\\lesssim" |
"\\lnapprox" |
"\\nsubset" |
"\\nsubseteq" |
"\\nsubseteqq" |
"\\notin" |
"\\ni" |
"\\notni" |
"\\nmid" |
"\\nshortmid" |
"\\preceq" |
"\\npreceq" |
"\\ll" |
"\\ngeq" |
"\\ngeqq" |
"\\ngeqslant" |
"\\nleq" |
"\\nleqq" |
"\\nleqslant" |
"\\nless" |
"\\supset" |
"\\supseteq" |
"\\supseteqq" |
"\\supsetneq" |
"\\supsetneqq" |
"\\varsupsetneq" |
"\\varsupsetneqq" |
"\\approx" |
"\\asymp" |
"\\bowtie" |
"\\dashv" |
"\\Vdash" |
"\\vDash" |
"\\VDash" |
"\\vdash" |
"\\Vvdash" |
"\\models" |
"\\sim" |
"\\simeq" |
"\\nsim" |
"\\smile" |
"\\triangle" |
"\\triangledown" |
"\\triangleleft" |
"\\cong" |
"\\succ" |
"\\nsucc" |
"\\ngtr" |
"\\nsupset" |
"\\nsupseteq" |
"\\propto" |
"\\equiv" |
"\\nequiv" |
"\\frown" |
"\\triangleright" |
"\\ncong" |
"\\succeq" |
"\\succapprox" |
"\\succnapprox" |
"\\succcurlyeq" |
"\\succsim" |
"\\succnsim" |
"\\nsucceq" |
"\\nvDash" |
"\\nvdash" |
"\\nVDash" |
"\\amalg" |
"\\pm" |
"\\mp" |
"\\bigcirc" |
"\\wr" |
"\\odot" |
"\\uplus" |
"\\clubsuit" |
"\\spadesuit" |
"\\Diamond" |
"\\diamond" |
"\\sqcup" |
"\\sqcap" |
"\\sqsubset" |
"\\sqsubseteq" |
"\\sqsupset" |
"\\sqsupseteq" |
"\\Subset" |
"\\Supset" |
"\\ltimes" |
"\\div" |
"\\rtimes" |
"\\bot" |
"\\therefore" |
"\\thickapprox" |
"\\thicksim" |
"\\varpropto" |
"\\varnothing" |
"\\flat" |
"\\vee" |
"\\because" |
"\\between" |
"\\Bumpeq" |
"\\bumpeq" |
"\\circeq" |
"\\curlyeqprec" |
"\\curlyeqsucc" |
"\\doteq" |
"\\doteqdot" |
"\\eqcirc" |
"\\fallingdotseq" |
"\\multimap" |
"\\pitchfork" |
"\\precapprox" |
"\\precnapprox" |
"\\preccurlyeq" |
"\\precsim" |
"\\precnsim" |
"\\risingdotseq" |
"\\sharp" |
"\\bullet" |
"\\nexists" |
"\\dagger" |
"\\ddagger" |
"\\not" |
"\\top" |
"\\natural" |
"\\angle" |
"\\measuredangle" |
"\\backprime" |
"\\bigstar" |
"\\blacklozenge" |
"\\lozenge" |
"\\blacksquare" |
"\\blacktriangle" |
"\\blacktriangleleft" |
"\\blacktriangleright" |
"\\blacktriangledown" |
"\\ntriangleleft" |
"\\ntriangleright" |
"\\ntrianglelefteq" |
"\\ntrianglerighteq" |
"\\trianglelefteq" |
"\\trianglerighteq" |
"\\triangleq" |
"\\vartriangleleft" |
"\\vartriangleright" |
"\\forall" |
"\\bigtriangleup" |
"\\bigtriangledown" |
"\\nprec"  {yylval=itex2MML_copy2(yytext, ";"); if (yylval != itex2MML_empty_string) yylval[0]='&'; return MOL;}

"\\aleph" |
"\\beth" |
"\\eth" |
"\\ell" |
"\\hbar" |
"\\Im" |
"\\imath" |
"\\jmath" |
"\\wp" |
"\\Re" {yylval=itex2MML_copy2(yytext, ";"); if (yylval != itex2MML_empty_string) yylval[0]='&'; return MI;}

"\\Perp" |
"\\Vbar" {yylval=itex2MML_copy_string("&Vbar;"); return MOL;}
"\\boxdot" {yylval=itex2MML_copy_string("&sdotb;"); return MOL;}
"\\Box" |
"\\square" {yylval=itex2MML_copy_string("&square;"); return MOL;}
"\\emptyset" |
"\\empty" {yylval=itex2MML_copy_string("&emptyv;"); return MI;}
"\\exists" {yylval=itex2MML_copy_string("&Exists;"); return MOL;}
"\\circ" {yylval=itex2MML_copy_string("&SmallCircle;"); return MOL;}
"\\rhd" {yylval=itex2MML_copy_string("&RightTriangle;"); return MOL;}
"\\lhd" {yylval=itex2MML_copy_string("&LeftTriangle;"); return MOL;}
"\\lll" {yylval=itex2MML_copy_string("&Ll;"); return MOL;}
"\\unrhd" {yylval=itex2MML_copy_string("&RightTriangleEqual;"); return MOL;}
"\\unlhd" {yylval=itex2MML_copy_string("&LeftTriangleEqual;"); return MOL;}
"\\Del" |
"\\nabla" {yylval=itex2MML_copy_string("&Del;"); return MOL;}
"\\sphericalangle" {yylval=itex2MML_copy_string("&angsph;"); return MOL;}

"\\heartsuit" {yylval=itex2MML_copy_string("&#x2661;"); return MOL;}
"\\diamondsuit" {yylval=itex2MML_copy_string("&#x2662;"); return MOL;}

"\\partial" {yylval=itex2MML_copy_string("&PartialD;"); return MOL;}

"\\qed" {yylval=itex2MML_copy_string("&squf;"); return MO;}

"\\mod" {yylval=itex2MML_copy_string("mod"); return MOS;}
"\\bmod" {yylval=itex2MML_copy_string("mod"); return MOS;}
"\\pmod" {return PMOD;}

"\\bottom" {yylval=itex2MML_copy_string("&perp;"); return MOL;}

"\\neg" {yylval=itex2MML_copy_string("&not;"); return MOL;}

"\\neq" |
"\\ne"  |
"\\not =" |
"\\not=" {yylval=itex2MML_copy_string("&ne;"); return MOL;}

"\\not\\in" |
"\\not \\in"  {yylval=itex2MML_copy_string("&notin;"); return MOL;}

"\\shortmid" |
"\\mid"  {yylval=itex2MML_copy_string("&VerticalBar;"); return MOS;}

"\\int"    |
"\\integral"     {return LARGERINT;}

"\\iint"   |
"\\doubleintegral" {yylval=itex2MML_copy_string("&Int;"); return MOL;}

"\\iiint"   |
"\\tripleintegral" {yylval=itex2MML_copy_string("&tint;"); return MOL;}

"\\iiiint"   |
"\\quadrupleintegral" {yylval=itex2MML_copy_string("&qint;"); return MOL;}

"\\oint"    |
"\\conint"  |
"\\contourintegral"   {yylval=itex2MML_copy_string("&conint;"); return MOL;}

"\\times"   {yylval=itex2MML_copy_string("&times;"); return MOL;}
"\\star"   {yylval=itex2MML_copy_string("&sstarf;"); return MOL;}
"\\circleddash" |
"\\odash"   {yylval=itex2MML_copy_string("&odash;"); return MOL;}

"\\intercal"   {yylval=itex2MML_copy_string("&intcal;"); return MOL;}
"\\smallfrown"   {yylval=itex2MML_copy_string("&sfrown;"); return MOL;}
"\\smallsmile"   {yylval=itex2MML_copy_string("&ssmile;"); return MOL;}

"\\boxminus" |
"\\minusb"   {yylval=itex2MML_copy_string("&boxminus;"); return MOL;}
"\\boxplus" |
"\\plusb"   {yylval=itex2MML_copy_string("&boxplus;"); return MOL;}
"\\boxtimes" |
"\\timesb"   {yylval=itex2MML_copy_string("&boxtimes;"); return MOL;}

"\\sum"          {yylval=itex2MML_copy_string("&Sum;"); return MOB;}

"\\prod" |
"\\product"      {yylval=itex2MML_copy_string("&prod;"); return MOB;}

"\\coprod"  |
"\\coproduct"    {yylval=itex2MML_copy_string("&coprod;"); return MOB;}

"\\otimes"       {yylval=itex2MML_copy_string("&otimes;"); return MOL;}
"\\Otimes"       {yylval=itex2MML_copy_string("&Otimes;"); return MOL;}
"\\bigotimes"     {yylval=itex2MML_copy_string("&bigotimes;"); return MOL;}

"\\ominus"       {yylval=itex2MML_copy_string("&ominus;"); return MOL;}
"\\oslash"       {yylval=itex2MML_copy_string("&osol;"); return MOL;}

"\\oplus"       {yylval=itex2MML_copy_string("&oplus;"); return MOL;}
"\\Oplus"   |
"\\bigoplus"    {yylval=itex2MML_copy_string("&bigoplus;"); return MOB;}

"\\bigodot"    {yylval=itex2MML_copy_string("&bigodot;"); return MOB;}
"\\bigsqcup"    {yylval=itex2MML_copy_string("&bigsqcup;"); return MOB;}
"\\biguplus"    {yylval=itex2MML_copy_string("&biguplus;"); return MOB;}

"\\wedge"       {yylval=itex2MML_copy_string("&wedge;"); return MOL;}
"\\Wedge"  |
"\\bigwedge"       {yylval=itex2MML_copy_string("&xwedge;"); return MOB;}

"\\Vee"  |
"\\bigvee"       {yylval=itex2MML_copy_string("&bigvee;"); return MOB;}

"\\invamp"  |
"\\parr"       {yylval=itex2MML_copy_string("&#8523;"); return MOL;}

"\\frac"         {return FRAC;}
"\\tfrac"         {return TFRAC;}
"\\dfrac"         {return DFRAC;}
"\\sfrac"   {return SFRAC;}
"\\binom"   {return BINOM;}
"\\choose"  {return BINOM2;}
"\\tbinom"        {return TBINOM;}

"\\tensor"       {return TENSOR;}

"\\multiscripts" {return MULTI;}

"\\overbrace"     {return OVERBRACE;}

"\\underbrace"   {return UNDERBRACE;}

"\\underline"   {return UNDERLINE;}

"\\bar"          {return BAR;}
"\\overline" |
"\\closure" |
"\\widebar"      {return WIDEBAR;}

"\\vec"       {return VEC;} 
"\\widevec"   {return WIDEVEC;}
"\\limits"  {/* Ignore  */ ;}

"\\overrightarrow"    {yylval = itex2MML_copy_string("&rightarrow;");     return OVERARROW;}
"\\overleftarrow"         {yylval = itex2MML_copy_string("&leftarrow;");      return OVERARROW;}
"\\overleftrightarrow"    {yylval = itex2MML_copy_string("&leftrightarrow;"); return OVERARROW;}
"\\overrightharpoonup"    {yylval = itex2MML_copy_string("&#x21C0;");     return OVERARROW;}
"\\overrightharpoondown"  {yylval = itex2MML_copy_string("&#x21C1;");     return OVERARROW;}

"\\underrightarrow"       {yylval = itex2MML_copy_string("&rightarrow;");     return UNDERARROW;}
"\\underleftarrow"    {yylval = itex2MML_copy_string("&leftarrow;");      return UNDERARROW;}
"\\underleftrightarrow"   {yylval = itex2MML_copy_string("&leftrightarrow;"); return UNDERARROW;}
"\\underrightharpoonup"   {yylval = itex2MML_copy_string("&#x21C0;");     return UNDERARROW;}
"\\underrightharpoondown" {yylval = itex2MML_copy_string("&#x21C1;");     return UNDERARROW;}

"\\dot"       {return DOT;}
"\\ddot"      {return DDOT;}
"\\dddot"      {return DDDOT;}
"\\ddddot"      {return DDDDOT;}

"\\tilde"       {return TILDE;} 
"\\P"  {yylval=itex2MML_copy_string("&para;"); return MI;}
"\\copyright" {yylval=itex2MML_copy_string("&#169;"); return MI;}/* copyright*/
"\\deg" {yylval=itex2MML_copy_string("&#176;"); return MI;}/* not in wims latex: high small round o */
"\\Celcius" {yylval=itex2MML_copy_string("&#8451;"); return MI;} /* not in wims latex: degree Celcius */
"\\Fahrenheit" {yylval=itex2MML_copy_string("&#8457;"); return MI;} /* not in wims latex: degree Fahrenheit */
"\\i" {yylval=itex2MML_copy_string("&#305;"); return MI;} /* dotless i*/
"\\j" {yylval=itex2MML_copy_string("&#567;"); return MI;} /* dotless j*/
"\\"[~\^\"`'kl=bdruvtoOHct\.] { /* " accents , some are already in other syntax:  \\ddot{i} etc */
yylval = itex2MML_copy_string(yytext+1);
if ((yyleng > 1) && (yylval != itex2MML_empty_string)) yylval[yyleng+1]='\0';
return ACCENTS;
}
"\\widetilde"   {return WIDETILDE;}


"\\check"       {return CHECK;} 
"\\widecheck"   {return WIDECHECK;}


"\\hat"       {return HAT;} 
"\\widehat"   {return WIDEHAT;}

"\\underset"     {return UNDER;}

"\\stackrel" |
"\\overset"      {return OVER;}

"\\over"         {return TEXOVER;}
"\\atop"         {return TEXATOP;}

"\\underoverset"  {return UNDEROVER;}

"\\sqrt"         {BEGIN(OPTARG); return SQRT;}

"\\root"         {return ROOT;}
"\\of"
"\\nonumber"        {yylval=itex2MML_copy_string("&nbsp;"); return MI;}

"\\space"        {BEGIN(INT1); return SPACE;}
"\\*"      {yylval=itex2MML_copy_string("&InvisibleTimes;"); return MI;}

"\\text" |
"\\textrm" |
"\\mbox"         {BEGIN(PLAINTEXT); return TEXTBOX;}

"\\statusline"    {BEGIN(PLAINTEXT); return STATLINE;}
"\\tooltip"       {BEGIN(PLAINTEXT); return TOOLTIP;}

"\\toggle"        {return TOGGLE;}

"\\mathraisebox"  {BEGIN(RAISEBOX1); return RAISEBOX;}

"\\fghilight" |
"\\fghighlight"   {BEGIN(ATTRIBUTELIST); return FGHIGHLIGHT;}

"\\bghilight" |
"\\bghighlight"   {BEGIN(ATTRIBUTELIST); return BGHIGHLIGHT;}

"\\special" {BEGIN(FINDARG); return SPECIAL;}

"\\color"  |
"\\textcolor" {BEGIN(ATTRIBUTELIST); return COLOR;}
"\\bgcolor"        {BEGIN(ATTRIBUTELIST); return BGCOLOR;}

"\\displaystyle"  {itex2MML_displaymode=1; itex2MML_rowposn=2; return DISPLAY;}

"\\textstyle"     {itex2MML_displaymode=0; itex2MML_rowposn=2; return TEXTSTY;}

"\\textsize"     {return TEXTSIZE;}

"\\scriptsize"     {return SCSIZE;}

"\\scriptscriptsize"     {return SCSCSIZE;}

"\\mathit" |
"\\it" |
"\\emph"      {return ITALICS;}

"\\boldsymbol" |
"\\bf" |
"\\Bf" |
"\\mathbf"       {return BOLD;}
"\\mathrm"     |
"\\rm"  {BEGIN(ROMAN); return RM;}
"\\rm " { return WIMSROMAN;}

"\\mathbb"       {BEGIN(BBOLD); return BB;}

"\\mathfrak" |
"\\mathfr"       {BEGIN(FRAKTUR); return FRAK;}

"\\slash"       {return SLASHED;}

"\\boxed"       {return BOXED;}

"\\mathcal"       {BEGIN(CALLIGRAPHIC); return CAL;}

"\\begin"        {itex2MML_env_start = 1; BEGIN(MATHENV); return BEGINENV;}
"\\end"        {BEGIN(MATHENV); return ENDENV;}

"\\substack"     {return SUBSTACK;}

"\\array"        {return ARRAY;}

"\\arrayopts"    {return ARRAYOPTS;}

"\\colalign"     {BEGIN(ATTRIBUTELIST); return COLALIGN;}

"\\collayout"   {BEGIN(ATTRIBUTELIST); return COLLAYOUT;}

"\\rowalign"     {BEGIN(ATTRIBUTELIST); return ROWALIGN;}

"\\align"     {BEGIN(ATTRIBUTELIST); return ALIGN;}

"\\equalrows"     {BEGIN(ATTRIBUTELIST); return EQROWS;}

"\\equalcols"     {BEGIN(ATTRIBUTELIST); return EQCOLS;}

"\\rowlines"     {BEGIN(ATTRIBUTELIST); return ROWLINES;}

"\\collines"     {BEGIN(ATTRIBUTELIST); return COLLINES;}

"\\frame"     {BEGIN(ATTRIBUTELIST); return FRAME;}

"\\padding"     {BEGIN(ATTRIBUTELIST); return PADDING;}

"\\rowopts"    {return ROWOPTS;}

"\\cellopts"   {return CELLOPTS;}

"\\rowspan"     {BEGIN(ATTRIBUTELIST); return ROWSPAN;}

"\\colspan"     {BEGIN(ATTRIBUTELIST); return COLSPAN;}


"\\," |
"\\thinspace"   {return THINSPACE;}

"\\:" |
"\\medspace"    {return MEDSPACE;}

"\\;" |
"\\thickspace"  {return THICKSPACE;}

"\\quad"        {return QUAD;}
"\\qquad"       {return QQUAD;}

"\\!" |
"\\negspace"    {return NEGSPACE;}

"\\phantom" |
"\\vphantom"     {return PHANTOM;}

"\\href"        {BEGIN(PLAINTEXT); return HREF;}

"\\operatorname"  {BEGIN(PLAINTEXT); return OPERATORNAME;}
"\\mathop"        {BEGIN(PLAINTEXT); return MATHOP;}
"\\mathbin"       {BEGIN(PLAINTEXT); return MATHBIN;}
"\\mathrel"       {BEGIN(PLAINTEXT); return MATHREL;}
"\\itexnum"       {BEGIN(PLAINTEXT); return ITEXNUM;}

"\\char32" {yylval = itex2MML_copy_string("&#x2423;"); return MI;}
"\\char44" {yylval = itex2MML_copy_string("&#44;"); return MI;}
"\\exclam" {yylval = itex2MML_copy_string("&#x0021;"); return MI;}
"\\octothorpe" {yylval = itex2MML_copy_string("&#x0023;"); return MI;}
"\\mathdollar" {yylval = itex2MML_copy_string("&#x0024;"); return MI;}
"\\percent" {yylval = itex2MML_copy_string("&#x0025;"); return MI;}
"\\ampersand" {yylval = itex2MML_copy_string("&#x0026;"); return MI;}
"\\lparen" {yylval = itex2MML_copy_string("&#x0028;"); return LEFTDELIM;}
"\\rparen" {yylval = itex2MML_copy_string("&#x0029;"); return RIGHTDELIM;}
"\\plus" {yylval = itex2MML_copy_string("&#x002B;"); return MO;}
"\\period" {yylval = itex2MML_copy_string("&#x002E;"); return MOP;}
"\\mathslash" {yylval = itex2MML_copy_string("&#x002F;"); return MO;}
"\\mathcolon" {yylval = itex2MML_copy_string("&#x003A;"); return MOP;}
"\\semicolon" {yylval = itex2MML_copy_string("&#x003B;"); return MOP;}
"\\less" {yylval = itex2MML_copy_string("&#x003C;"); return MO;}
"\\equal" {yylval = itex2MML_copy_string("&#x003D;"); return MO;}
"\\greater" {yylval = itex2MML_copy_string("&#x003E;"); return MO;}
"\\question" {yylval = itex2MML_copy_string("&#x003F;"); return MOP;}
"\\atsign" {yylval = itex2MML_copy_string("&#x0040;"); return MI;}
"\\sterling" {yylval = itex2MML_copy_string("&#x00A3;"); return MI;}
"\\yen" {yylval = itex2MML_copy_string("&#x00A5;"); return MI;}
"\\cdotp" {yylval = itex2MML_copy_string("&#x00B7;"); return MO;}
"\\matheth" {yylval = itex2MML_copy_string("&#x00F0;"); return MI;}
"\\Zbar" {yylval = itex2MML_copy_string("&#x01B5;"); return MI;}
"\\grave" {yylval = itex2MML_copy_string("&#x0300;"); return MI;}
"\\acute" {yylval = itex2MML_copy_string("&#x0301;"); return MI;}
"\\overbar" {yylval = itex2MML_copy_string("&#x0305;"); return MI;}
"\\breve" {yylval = itex2MML_copy_string("&#x0306;"); return MI;}
"\\ovhook" {yylval = itex2MML_copy_string("&#x0309;"); return MI;}
"\\ocirc" {yylval = itex2MML_copy_string("&#x030A;"); return MI;}
"\\candra" {yylval = itex2MML_copy_string("&#x0310;"); return MI;}
"\\oturnedcomma" {yylval = itex2MML_copy_string("&#x0312;"); return MI;}
"\\ocommatopright" {yylval = itex2MML_copy_string("&#x0315;"); return MI;}
"\\droang" {yylval = itex2MML_copy_string("&#x031A;"); return MI;}
"\\wideutilde" {yylval = itex2MML_copy_string("&#x0330;"); return MI;}
"\\underbar" {yylval = itex2MML_copy_string("&#x0331;"); return MI;}
"\\upAlpha" {yylval = itex2MML_copy_string("&#x0391;"); return MI;}
"\\upBeta" {yylval = itex2MML_copy_string("&#x0392;"); return MI;}
"\\upGamma" {yylval = itex2MML_copy_string("&#x0393;"); return MI;}
"\\upDelta" {yylval = itex2MML_copy_string("&#x0394;"); return MI;}
"\\upEpsilon" {yylval = itex2MML_copy_string("&#x0395;"); return MI;}
"\\upZeta" {yylval = itex2MML_copy_string("&#x0396;"); return MI;}
"\\upEta" {yylval = itex2MML_copy_string("&#x0397;"); return MI;}
"\\upTheta" {yylval = itex2MML_copy_string("&#x0398;"); return MI;}
"\\upIota" {yylval = itex2MML_copy_string("&#x0399;"); return MI;}
"\\upKappa" {yylval = itex2MML_copy_string("&#x039A;"); return MI;}
"\\upLambda" {yylval = itex2MML_copy_string("&#x039B;"); return MI;}
"\\upMu" {yylval = itex2MML_copy_string("&#x039C;"); return MI;}
"\\upNu" {yylval = itex2MML_copy_string("&#x039D;"); return MI;}
"\\upXi" {yylval = itex2MML_copy_string("&#x039E;"); return MI;}
"\\upOmicron" {yylval = itex2MML_copy_string("&#x039F;"); return MI;}
"\\upPi" {yylval = itex2MML_copy_string("&#x03A0;"); return MI;}
"\\upRho" {yylval = itex2MML_copy_string("&#x03A1;"); return MI;}
"\\upSigma" {yylval = itex2MML_copy_string("&#x03A3;"); return MI;}
"\\upTau" {yylval = itex2MML_copy_string("&#x03A4;"); return MI;}
"\\upUpsilon" {yylval = itex2MML_copy_string("&#x03A5;"); return MI;}
"\\upPhi" {yylval = itex2MML_copy_string("&#x03A6;"); return MI;}
"\\upChi" {yylval = itex2MML_copy_string("&#x03A7;"); return MI;}
"\\upPsi" {yylval = itex2MML_copy_string("&#x03A8;"); return MI;}
"\\upOmega" {yylval = itex2MML_copy_string("&#x03A9;"); return MI;}
"\\upalpha" {yylval = itex2MML_copy_string("&#x03B1;"); return MI;}
"\\upbeta" {yylval = itex2MML_copy_string("&#x03B2;"); return MI;}
"\\upgamma" {yylval = itex2MML_copy_string("&#x03B3;"); return MI;}
"\\updelta" {yylval = itex2MML_copy_string("&#x03B4;"); return MI;}
"\\upepsilon" {yylval = itex2MML_copy_string("&#x03B5;"); return MI;}
"\\upzeta" {yylval = itex2MML_copy_string("&#x03B6;"); return MI;}
"\\upeta" {yylval = itex2MML_copy_string("&#x03B7;"); return MI;}
"\\uptheta" {yylval = itex2MML_copy_string("&#x03B8;"); return MI;}
"\\upiota" {yylval = itex2MML_copy_string("&#x03B9;"); return MI;}
"\\upkappa" {yylval = itex2MML_copy_string("&#x03BA;"); return MI;}
"\\uplambda" {yylval = itex2MML_copy_string("&#x03BB;"); return MI;}
"\\upmu" {yylval = itex2MML_copy_string("&#x03BC;"); return MI;}
"\\upnu" {yylval = itex2MML_copy_string("&#x03BD;"); return MI;}
"\\upxi" {yylval = itex2MML_copy_string("&#x03BE;"); return MI;}
"\\upomicron" {yylval = itex2MML_copy_string("&#x03BF;"); return MI;}
"\\uppi" {yylval = itex2MML_copy_string("&#x03C0;"); return MI;}
"\\uprho" {yylval = itex2MML_copy_string("&#x03C1;"); return MI;}
"\\upvarsigma" {yylval = itex2MML_copy_string("&#x03C2;"); return MI;}
"\\upsigma" {yylval = itex2MML_copy_string("&#x03C3;"); return MI;}
"\\uptau" {yylval = itex2MML_copy_string("&#x03C4;"); return MI;}
"\\upupsilon" {yylval = itex2MML_copy_string("&#x03C5;"); return MI;}
"\\upvarphi" {yylval = itex2MML_copy_string("&#x03C6;"); return MI;}
"\\upchi" {yylval = itex2MML_copy_string("&#x03C7;"); return MI;}
"\\uppsi" {yylval = itex2MML_copy_string("&#x03C8;"); return MI;}
"\\upomega" {yylval = itex2MML_copy_string("&#x03C9;"); return MI;}
"\\upvarbeta" {yylval = itex2MML_copy_string("&#x03D0;"); return MI;}
"\\upvartheta" {yylval = itex2MML_copy_string("&#x03D1;"); return MI;}
"\\upphi" {yylval = itex2MML_copy_string("&#x03D5;"); return MI;}
"\\upvarpi" {yylval = itex2MML_copy_string("&#x03D6;"); return MI;}
"\\upoldKoppa" {yylval = itex2MML_copy_string("&#x03D8;"); return MI;}
"\\upoldkoppa" {yylval = itex2MML_copy_string("&#x03D9;"); return MI;}
"\\upStigma" {yylval = itex2MML_copy_string("&#x03DA;"); return MI;}
"\\upstigma" {yylval = itex2MML_copy_string("&#x03DB;"); return MI;}
"\\upDigamma" {yylval = itex2MML_copy_string("&#x03DC;"); return MI;}
"\\updigamma" {yylval = itex2MML_copy_string("&#x03DD;"); return MI;}
"\\upKoppa" {yylval = itex2MML_copy_string("&#x03DE;"); return MI;}
"\\upkoppa" {yylval = itex2MML_copy_string("&#x03DF;"); return MI;}
"\\upSampi" {yylval = itex2MML_copy_string("&#x03E0;"); return MI;}
"\\upsampi" {yylval = itex2MML_copy_string("&#x03E1;"); return MI;}
"\\upvarkappa" {yylval = itex2MML_copy_string("&#x03F0;"); return MI;}
"\\upvarrho" {yylval = itex2MML_copy_string("&#x03F1;"); return MI;}
"\\upvarTheta" {yylval = itex2MML_copy_string("&#x03F4;"); return MI;}
"\\upvarepsilon" {yylval = itex2MML_copy_string("&#x03F5;"); return MI;}
"\\upbackepsilon" {yylval = itex2MML_copy_string("&#x03F6;"); return MI;}
"\\horizbar" {yylval = itex2MML_copy_string("&#x2015;"); return MI;}
"\\twolowline" {yylval = itex2MML_copy_string("&#x2017;"); return MI;}
"\\enleadertwodots" {yylval = itex2MML_copy_string("&#x2025;"); return MI;}
"\\unicodeellipsis" {yylval = itex2MML_copy_string("&#x2026;"); return MI;}
"\\dprime" {yylval = itex2MML_copy_string("&#x2033;"); return MI;}
"\\trprime" {yylval = itex2MML_copy_string("&#x2034;"); return MI;}
"\\backdprime" {yylval = itex2MML_copy_string("&#x2036;"); return MI;}
"\\backtrprime" {yylval = itex2MML_copy_string("&#x2037;"); return MI;}
"\\caretinsert" {yylval = itex2MML_copy_string("&#x2038;"); return MI;}
"\\Exclam" {yylval = itex2MML_copy_string("&#x203C;"); return MI;}
"\\tieconcat" {yylval = itex2MML_copy_string("&#x2040;"); return MO;}
"\\hyphenbullet" {yylval = itex2MML_copy_string("&#x2043;"); return MI;}
"\\fracslash" {yylval = itex2MML_copy_string("&#x2044;"); return MO;}
"\\Question" {yylval = itex2MML_copy_string("&#x2047;"); return MI;}
"\\qprime" {yylval = itex2MML_copy_string("&#x2057;"); return MI;}
"\\euro" |
"\\Euro" |
"\\EUR" {yylval = itex2MML_copy_string("&#x20AC;"); return MI;}
"\\leftharpoonaccent" {yylval = itex2MML_copy_string("&#x20D0;"); return MI;}
"\\rightharpoonaccent" {yylval = itex2MML_copy_string("&#x20D1;"); return MI;}
"\\vertoverlay" {yylval = itex2MML_copy_string("&#x20D2;"); return MI;}
"\\enclosecircle" {yylval = itex2MML_copy_string("&#x20DD;"); return MI;}
"\\enclosesquare" {yylval = itex2MML_copy_string("&#x20DE;"); return MI;}
"\\enclosediamond" {yylval = itex2MML_copy_string("&#x20DF;"); return MI;}
"\\enclosetriangle" {yylval = itex2MML_copy_string("&#x20E4;"); return MI;}
"\\annuity" {yylval = itex2MML_copy_string("&#x20E7;"); return MI;}
"\\threeunderdot" {yylval = itex2MML_copy_string("&#x20E8;"); return MI;}
"\\widebridgeabove" {yylval = itex2MML_copy_string("&#x20E9;"); return MI;}
"\\asteraccent" {yylval = itex2MML_copy_string("&#x20F0;"); return MI;}
"\\BbbC" {yylval = itex2MML_copy_string("&#x2102;"); return MI;}
"\\Eulerconst" {yylval = itex2MML_copy_string("&#x2107;"); return MI;}
"\\mscrg" {yylval = itex2MML_copy_string("&#x210A;"); return MI;}
"\\mscrH" {yylval = itex2MML_copy_string("&#x210B;"); return MI;}
"\\mfrakH" {yylval = itex2MML_copy_string("&#x210C;"); return MI;}
"\\BbbH" {yylval = itex2MML_copy_string("&#x210D;"); return MI;}
"\\Planckconst" {yylval = itex2MML_copy_string("&#x210E;"); return MI;}
"\\hslash" {yylval = itex2MML_copy_string("&#x210F;"); return MI;}
"\\mscrI" {yylval = itex2MML_copy_string("&#x2110;"); return MI;}
"\\mscrL" {yylval = itex2MML_copy_string("&#x2112;"); return MI;}
"\\BbbN" {yylval = itex2MML_copy_string("&#x2115;"); return MI;}
"\\BbbP" {yylval = itex2MML_copy_string("&#x2119;"); return MI;}
"\\BbbQ" {yylval = itex2MML_copy_string("&#x211A;"); return MI;}
"\\mscrR" {yylval = itex2MML_copy_string("&#x211B;"); return MI;}
"\\BbbR" {yylval = itex2MML_copy_string("&#x211D;"); return MI;}
"\\BbbZ" {yylval = itex2MML_copy_string("&#x2124;"); return MI;}
"\\mfrakZ" {yylval = itex2MML_copy_string("&#x2128;"); return MI;}
"\\turnediota" {yylval = itex2MML_copy_string("&#x2129;"); return MI;}
"\\Angstrom" {yylval = itex2MML_copy_string("&#x212B;"); return MI;}
"\\mscrB" {yylval = itex2MML_copy_string("&#x212C;"); return MI;}
"\\mfrakC" {yylval = itex2MML_copy_string("&#x212D;"); return MI;}
"\\mscre" {yylval = itex2MML_copy_string("&#x212F;"); return MI;}
"\\mscrE" {yylval = itex2MML_copy_string("&#x2130;"); return MI;}
"\\mscrF" {yylval = itex2MML_copy_string("&#x2131;"); return MI;}
"\\Finv" {yylval = itex2MML_copy_string("&#x2132;"); return MI;}
"\\mscrM" {yylval = itex2MML_copy_string("&#x2133;"); return MI;}
"\\mscro" {yylval = itex2MML_copy_string("&#x2134;"); return MI;}
"\\gimel" {yylval = itex2MML_copy_string("&#x2137;"); return MI;}
"\\daleth" {yylval = itex2MML_copy_string("&#x2138;"); return MI;}
"\\Bbbpi" {yylval = itex2MML_copy_string("&#x213C;"); return MI;}
"\\Bbbgamma" {yylval = itex2MML_copy_string("&#x213D;"); return MI;}
"\\BbbGamma" {yylval = itex2MML_copy_string("&#x213E;"); return MI;}
"\\BbbPi" {yylval = itex2MML_copy_string("&#x213F;"); return MI;}
"\\Bbbsum" {yylval = itex2MML_copy_string("&#x2140;"); return MI;}
"\\Game" {yylval = itex2MML_copy_string("&#x2141;"); return MI;}
"\\sansLturned" {yylval = itex2MML_copy_string("&#x2142;"); return MI;}
"\\sansLmirrored" {yylval = itex2MML_copy_string("&#x2143;"); return MI;}
"\\Yup" {yylval = itex2MML_copy_string("&#x2144;"); return MI;}
"\\mitBbbD" {yylval = itex2MML_copy_string("&#x2145;"); return MI;}
"\\mitBbbd" {yylval = itex2MML_copy_string("&#x2146;"); return MI;}
"\\mitBbbe" {yylval = itex2MML_copy_string("&#x2147;"); return MI;}
"\\mitBbbi" {yylval = itex2MML_copy_string("&#x2148;"); return MI;}
"\\mitBbbj" {yylval = itex2MML_copy_string("&#x2149;"); return MI;}
"\\PropertyLine" {yylval = itex2MML_copy_string("&#x214A;"); return MI;}
"\\upand" {yylval = itex2MML_copy_string("&#x214B;"); return MI;}
"\\leftwavearrow" {yylval = itex2MML_copy_string("&#x219C;"); return MO;}
"\\rightwavearrow" {yylval = itex2MML_copy_string("&#x219D;"); return MO;}
"\\twoheaduparrow" {yylval = itex2MML_copy_string("&#x219F;"); return MO;}
"\\twoheaddownarrow" {yylval = itex2MML_copy_string("&#x21A1;"); return MO;}
"\\mapsfrom" {yylval = itex2MML_copy_string("&#x21A4;"); return MO;}
"\\mapsup" {yylval = itex2MML_copy_string("&#x21A5;"); return MO;}
"\\mapsdown" {yylval = itex2MML_copy_string("&#x21A7;"); return MO;}
"\\updownarrowbar" {yylval = itex2MML_copy_string("&#x21A8;"); return MO;}
"\\Ldsh" {yylval = itex2MML_copy_string("&#x21B2;"); return MO;}
"\\Rdsh" {yylval = itex2MML_copy_string("&#x21B3;"); return MO;}
"\\linefeed" {yylval = itex2MML_copy_string("&#x21B4;"); return MI;}
"\\carriagereturn" {yylval = itex2MML_copy_string("&#x21B5;"); return MI;}
"\\barovernorthwestarrow" {yylval = itex2MML_copy_string("&#x21B8;"); return MI;}
"\\barleftarrowrightarrow" {yylval = itex2MML_copy_string("&#x21B9;"); return MI;}
"\\acwopencirclearrow" {yylval = itex2MML_copy_string("&#x21BA;"); return MO;}
"\\cwopencirclearrow" {yylval = itex2MML_copy_string("&#x21BB;"); return MO;}
"\\updownarrows" {yylval = itex2MML_copy_string("&#x21C5;"); return MO;}
"\\Nwarrow" {yylval = itex2MML_copy_string("&#x21D6;"); return MO;}
"\\Nearrow" {yylval = itex2MML_copy_string("&#x21D7;"); return MO;}
"\\Searrow" {yylval = itex2MML_copy_string("&#x21D8;"); return MO;}
"\\Swarrow" {yylval = itex2MML_copy_string("&#x21D9;"); return MO;}
"\\nHuparrow" {yylval = itex2MML_copy_string("&#x21DE;"); return MO;}
"\\nHdownarrow" {yylval = itex2MML_copy_string("&#x21DF;"); return MO;}
"\\leftdasharrow" {yylval = itex2MML_copy_string("&#x21E0;"); return MO;}
"\\updasharrow" {yylval = itex2MML_copy_string("&#x21E1;"); return MO;}
"\\rightdasharrow" {yylval = itex2MML_copy_string("&#x21E2;"); return MO;}
"\\downdasharrow" {yylval = itex2MML_copy_string("&#x21E3;"); return MO;}
"\\barleftarrow" {yylval = itex2MML_copy_string("&#x21E4;"); return MO;}
"\\rightarrowbar" {yylval = itex2MML_copy_string("&#x21E5;"); return MO;}
"\\leftwhitearrow" {yylval = itex2MML_copy_string("&#x21E6;"); return MO;}
"\\upwhitearrow" {yylval = itex2MML_copy_string("&#x21E7;"); return MO;}
"\\rightwhitearrow" {yylval = itex2MML_copy_string("&#x21E8;"); return MO;}
"\\downwhitearrow" {yylval = itex2MML_copy_string("&#x21E9;"); return MO;}
"\\whitearrowupfrombar" {yylval = itex2MML_copy_string("&#x21EA;"); return MI;}
"\\circleonrightarrow" {yylval = itex2MML_copy_string("&#x21F4;"); return MO;}
"\\downuparrows" {yylval = itex2MML_copy_string("&#x21F5;"); return MO;}
"\\rightthreearrows" {yylval = itex2MML_copy_string("&#x21F6;"); return MO;}
"\\nvleftarrow" {yylval = itex2MML_copy_string("&#x21F7;"); return MO;}
"\\nvrightarrow" {yylval = itex2MML_copy_string("&#x21F8;"); return MO;}
"\\nvleftrightarrow" {yylval = itex2MML_copy_string("&#x21F9;"); return MO;}
"\\nVleftarrow" {yylval = itex2MML_copy_string("&#x21FA;"); return MO;}
"\\nVrightarrow" {yylval = itex2MML_copy_string("&#x21FB;"); return MO;}
"\\nVleftrightarrow" {yylval = itex2MML_copy_string("&#x21FC;"); return MO;}
"\\leftarrowtriangle" {yylval = itex2MML_copy_string("&#x21FD;"); return MO;}
"\\rightarrowtriangle" {yylval = itex2MML_copy_string("&#x21FE;"); return MO;}
"\\leftrightarrowtriangle" {yylval = itex2MML_copy_string("&#x21FF;"); return MO;}
"\\complement" {yylval = itex2MML_copy_string("&#x2201;"); return MO;}
"\\increment" {yylval = itex2MML_copy_string("&#x2206;"); return MO;}
"\\smallin" {yylval = itex2MML_copy_string("&#x220A;"); return MO;}
"\\nni" {yylval = itex2MML_copy_string("&#x220C;"); return MO;}
"\\smallni" {yylval = itex2MML_copy_string("&#x220D;"); return MO;}
"\\QED" {yylval = itex2MML_copy_string("&#x220E;"); return MI;}
"\\minus" {yylval = itex2MML_copy_string("&#x2212;"); return MO;}
"\\divslash" {yylval = itex2MML_copy_string("&#x2215;"); return MO;}
"\\vysmwhtcircle" {yylval = itex2MML_copy_string("&#x2218;"); return MO;}
"\\vysmblkcircle" {yylval = itex2MML_copy_string("&#x2219;"); return MO;}
"\\cuberoot" {yylval = itex2MML_copy_string("&#x221B;"); return MI;}
"\\rightangle" {yylval = itex2MML_copy_string("&#x221F;"); return MI;}
"\\intclockwise" {yylval = itex2MML_copy_string("&#x2231;"); return MI;}
"\\mathratio" {yylval = itex2MML_copy_string("&#x2236;"); return MO;}
"\\Colon" {yylval = itex2MML_copy_string("&#x2237;"); return MO;}
"\\dotminus" {yylval = itex2MML_copy_string("&#x2238;"); return MO;}
"\\dashcolon" {yylval = itex2MML_copy_string("&#x2239;"); return MO;}
"\\dotsminusdots" {yylval = itex2MML_copy_string("&#x223A;"); return MO;}
"\\kernelcontraction" {yylval = itex2MML_copy_string("&#x223B;"); return MO;}
"\\invlazys" {yylval = itex2MML_copy_string("&#x223E;"); return MO;}
"\\sinewave" {yylval = itex2MML_copy_string("&#x223F;"); return MI;}
"\\eqsim" {yylval = itex2MML_copy_string("&#x2242;"); return MO;}
"\\nsime" {yylval = itex2MML_copy_string("&#x2244;"); return MO;}
"\\simneqq" {yylval = itex2MML_copy_string("&#x2246;"); return MO;}
"\\napprox" {yylval = itex2MML_copy_string("&#x2249;"); return MO;}
"\\approxident" {yylval = itex2MML_copy_string("&#x224B;"); return MO;}
"\\backcong" {yylval = itex2MML_copy_string("&#x224C;"); return MO;}
"\\Doteq" {yylval = itex2MML_copy_string("&#x2251;"); return MO;}
"\\arceq" {yylval = itex2MML_copy_string("&#x2258;"); return MO;}
"\\wedgeq" {yylval = itex2MML_copy_string("&#x2259;"); return MO;}
"\\veeeq" {yylval = itex2MML_copy_string("&#x225A;"); return MO;}
"\\stareq" {yylval = itex2MML_copy_string("&#x225B;"); return MO;}
"\\eqdef" {yylval = itex2MML_copy_string("&#x225D;"); return MO;}
"\\measeq" {yylval = itex2MML_copy_string("&#x225E;"); return MO;}
"\\questeq" {yylval = itex2MML_copy_string("&#x225F;"); return MO;}
"\\Equiv" {yylval = itex2MML_copy_string("&#x2263;"); return MO;}
"\\nlessgtr" {yylval = itex2MML_copy_string("&#x2278;"); return MO;}
"\\ngtrless" {yylval = itex2MML_copy_string("&#x2279;"); return MO;}
"\\cupleftarrow" {yylval = itex2MML_copy_string("&#x228C;"); return MO;}
"\\cupdot" {yylval = itex2MML_copy_string("&#x228D;"); return MO;}
"\\circledequal" {yylval = itex2MML_copy_string("&#x229C;"); return MO;}
"\\assert" {yylval = itex2MML_copy_string("&#x22A6;"); return MO;}
"\\nVdash" {yylval = itex2MML_copy_string("&#x22AE;"); return MO;}
"\\prurel" {yylval = itex2MML_copy_string("&#x22B0;"); return MO;}
"\\scurel" {yylval = itex2MML_copy_string("&#x22B1;"); return MO;}
"\\origof" {yylval = itex2MML_copy_string("&#x22B6;"); return MO;}
"\\imageof" {yylval = itex2MML_copy_string("&#x22B7;"); return MO;}
"\\hermitmatrix" {yylval = itex2MML_copy_string("&#x22B9;"); return MO;}
"\\barvee" {yylval = itex2MML_copy_string("&#x22BD;"); return MO;}
"\\measuredrightangle" {yylval = itex2MML_copy_string("&#x22BE;"); return MI;}
"\\varlrtriangle" {yylval = itex2MML_copy_string("&#x22BF;"); return MI;}
"\\smwhtdiamond" {yylval = itex2MML_copy_string("&#x22C4;"); return MO;}
"\\eqless" {yylval = itex2MML_copy_string("&#x22DC;"); return MO;}
"\\eqgtr" {yylval = itex2MML_copy_string("&#x22DD;"); return MO;}
"\\npreccurlyeq" {yylval = itex2MML_copy_string("&#x22E0;"); return MO;}
"\\nsucccurlyeq" {yylval = itex2MML_copy_string("&#x22E1;"); return MO;}
"\\nsqsubseteq" {yylval = itex2MML_copy_string("&#x22E2;"); return MO;}
"\\nsqsupseteq" {yylval = itex2MML_copy_string("&#x22E3;"); return MO;}
"\\sqsubsetneq" {yylval = itex2MML_copy_string("&#x22E4;"); return MO;}
"\\sqsupsetneq" {yylval = itex2MML_copy_string("&#x22E5;"); return MO;}
"\\unicodecdots" {yylval = itex2MML_copy_string("&#x22EF;"); return MO;}
"\\adots" {yylval = itex2MML_copy_string("&#x22F0;"); return MO;}
"\\disin" {yylval = itex2MML_copy_string("&#x22F2;"); return MO;}
"\\longdivision" {yylval = itex2MML_copy_string("&#x27CC;"); return MI;}
"\\leftouterjoin" {yylval = itex2MML_copy_string("&#x27D5;"); return MI;}
"\\rightouterjoin" {yylval = itex2MML_copy_string("&#x27D6;"); return MI;}
"\\fullouterjoin" {yylval = itex2MML_copy_string("&#x27D7;"); return MI;}
"\\lBrack" {yylval = itex2MML_copy_string("&#x27E6;"); return LEFTDELIM;}
"\\rBrack" {yylval = itex2MML_copy_string("&#x27E7;"); return RIGHTDELIM;}
"\\lAngle" {yylval = itex2MML_copy_string("&#x27EA;"); return LEFTDELIM;}
"\\rAngle" {yylval = itex2MML_copy_string("&#x27EB;"); return RIGHTDELIM;}
"\\longrightsquigarrow" {yylval = itex2MML_copy_string("&#x27FF;");return MOL;}
"\\nvtwoheadrightarrow" {yylval = itex2MML_copy_string("&#x2900;");return MOL;}
"\\nVtwoheadrightarrow" {yylval = itex2MML_copy_string("&#x2901;");return MOL;}
"\\nvLeftarrow" {yylval = itex2MML_copy_string("&#x2902;");return MOL;}
"\\nvRightarrow" {yylval = itex2MML_copy_string("&#x2903;");return MOL;}
"\\nvLeftrightarrow" {yylval = itex2MML_copy_string("&#x2904;");return MOL;}
"\\twoheadmapsto" {yylval = itex2MML_copy_string("&#x2905;");return MOL;}
"\\Mapsfrom" {yylval = itex2MML_copy_string("&#x2906;");return MOL;}
"\\rightdotarrow" {yylval = itex2MML_copy_string("&#x2911;");return MOL;}
"\\baruparrow" {yylval = itex2MML_copy_string("&#x2912;");return MOL;}
"\\downarrowbar" {yylval = itex2MML_copy_string("&#x2913;");return MOL;}
"\\nvrightarrowtail" {yylval = itex2MML_copy_string("&#x2914;");return MOL;}
"\\nVrightarrowtail" {yylval = itex2MML_copy_string("&#x2915;");return MOL;}
"\\twoheadrightarrowtail" {yylval = itex2MML_copy_string("&#x2916;");return MOL;}
"\\nvtwoheadrightarrowtail" {yylval = itex2MML_copy_string("&#x2917;");return MOL;}
"\\nVtwoheadrightarrowtail" {yylval = itex2MML_copy_string("&#x2918;");return MOL;}
"\\lefttail" {yylval = itex2MML_copy_string("&#x2919;");return MOL;}
"\\righttail" {yylval = itex2MML_copy_string("&#x291A;");return MOL;}
"\\leftdbltail" {yylval = itex2MML_copy_string("&#x291B;");return MOL;}
"\\rightdbltail" {yylval = itex2MML_copy_string("&#x291C;");return MOL;}
"\\diamondleftarrow" {yylval = itex2MML_copy_string("&#x291D;");return MOL;}
"\\rightarrowdiamond" {yylval = itex2MML_copy_string("&#x291E;");return MOL;}
"\\diamondleftarrowbar" {yylval = itex2MML_copy_string("&#x291F;");return MOL;}
"\\barrightarrowdiamond" {yylval = itex2MML_copy_string("&#x2920;");return MOL;}
"\\nwsearrow" {yylval = itex2MML_copy_string("&#x2921;");return MOL;}
"\\neswarrow" {yylval = itex2MML_copy_string("&#x2922;");return MOL;}
"\\hknwarrow" {yylval = itex2MML_copy_string("&#x2923;");return MOL;}
"\\hknearrow" {yylval = itex2MML_copy_string("&#x2924;");return MOL;}
"\\hksearow" {yylval = itex2MML_copy_string("&#x2925;");return MOL;}
"\\hkswarow" {yylval = itex2MML_copy_string("&#x2926;");return MOL;}
"\\tona" {yylval = itex2MML_copy_string("&#x2927;");return MOL;}
"\\toea" {yylval = itex2MML_copy_string("&#x2928;");return MOL;}
"\\tosa" {yylval = itex2MML_copy_string("&#x2929;");return MOL;}
"\\towa" {yylval = itex2MML_copy_string("&#x292A;");return MOL;}
"\\rdiagovfdiag" {yylval = itex2MML_copy_string("&#x292B;");return MOL;}
"\\fdiagovrdiag" {yylval = itex2MML_copy_string("&#x292C;");return MOL;}
"\\seovnearrow" {yylval = itex2MML_copy_string("&#x292D;");return MOL;}
"\\neovsearrow" {yylval = itex2MML_copy_string("&#x292E;");return MOL;}
"\\fdiagovnearrow" {yylval = itex2MML_copy_string("&#x292F;");return MOL;}
"\\rdiagovsearrow" {yylval = itex2MML_copy_string("&#x2930;");return MOL;}
"\\neovnwarrow" {yylval = itex2MML_copy_string("&#x2931;");return MOL;}
"\\nwovnearrow" {yylval = itex2MML_copy_string("&#x2932;");return MOL;}
"\\rightcurvedarrow" {yylval = itex2MML_copy_string("&#x2933;");return MOL;}
"\\uprightcurvearrow" {yylval = itex2MML_copy_string("&#x2934;");return MOL;}
"\\downrightcurvedarrow" {yylval = itex2MML_copy_string("&#x2935;");return MOL;}
"\\leftdowncurvedarrow" {yylval = itex2MML_copy_string("&#x2936;");return MOL;}
"\\rightdowncurvedarrow" {yylval = itex2MML_copy_string("&#x2937;");return MOL;}
"\\cwrightarcarrow" {yylval = itex2MML_copy_string("&#x2938;");return MOL;}
"\\acwleftarcarrow" {yylval = itex2MML_copy_string("&#x2939;");return MOL;}
"\\acwoverarcarrow" {yylval = itex2MML_copy_string("&#x293A;");return MOL;}
"\\acwunderarcarrow" {yylval = itex2MML_copy_string("&#x293B;");return MOL;}
"\\curvearrowrightminus" {yylval = itex2MML_copy_string("&#x293C;");return MOL;}
"\\curvearrowleftplus" {yylval = itex2MML_copy_string("&#x293D;");return MOL;}
"\\cwundercurvearrow" {yylval = itex2MML_copy_string("&#x293E;");return MOL;}
"\\ccwundercurvearrow" {yylval = itex2MML_copy_string("&#x293F;");return MOL;}
"\\acwcirclearrow" {yylval = itex2MML_copy_string("&#x2940;");return MOL;}
"\\cwcirclearrow" {yylval = itex2MML_copy_string("&#x2941;");return MOL;}
"\\rightarrowshortleftarrow" {yylval = itex2MML_copy_string("&#x2942;");return MOL;}
"\\leftarrowshortrightarrow" {yylval = itex2MML_copy_string("&#x2943;");return MOL;}
"\\shortrightarrowleftarrow" {yylval = itex2MML_copy_string("&#x2944;");return MOL;}
"\\rightarrowplus" {yylval = itex2MML_copy_string("&#x2945;");return MOL;}
"\\leftarrowplus" {yylval = itex2MML_copy_string("&#x2946;");return MOL;}
"\\rightarrowx" {yylval = itex2MML_copy_string("&#x2947;");return MOL;}
"\\leftrightarrowcircle" {yylval = itex2MML_copy_string("&#x2948;");return MOL;}
"\\twoheaduparrowcircle" {yylval = itex2MML_copy_string("&#x2949;");return MOL;}
"\\leftrightharpoonupdown" {yylval = itex2MML_copy_string("&#x294A;");return MOL;}
"\\leftrightharpoondownup" {yylval = itex2MML_copy_string("&#x294B;");return MOL;}
"\\updownharpoonrightleft" {yylval = itex2MML_copy_string("&#x294C;");return MOL;}
"\\updownharpoonleftright" {yylval = itex2MML_copy_string("&#x294D;");return MOL;}
"\\leftrightharpoonupup" {yylval = itex2MML_copy_string("&#x294E;");return MOL;}
"\\updownharpoonrightright" {yylval = itex2MML_copy_string("&#x294F;");return MOL;}
"\\leftrightharpoondowndown" {yylval = itex2MML_copy_string("&#x2950;");return MOL;}
"\\updownharpoonleftleft" {yylval = itex2MML_copy_string("&#x2951;");return MOL;}
"\\barleftharpoonup" {yylval = itex2MML_copy_string("&#x2952;");return MOL;}
"\\rightharpoonupbar" {yylval = itex2MML_copy_string("&#x2953;");return MOL;}
"\\barupharpoonright" {yylval = itex2MML_copy_string("&#x2954;");return MOL;}
"\\lParen" {yylval = itex2MML_copy_string("&#x2985;"); return LEFTDELIM;}
"\\rParen" {yylval = itex2MML_copy_string("&#x2986;"); return RIGHTDELIM;}
"\\llparenthesis" {yylval = itex2MML_copy_string("&#x2987;"); return LEFTDELIM;}
"\\rrparenthesis" {yylval = itex2MML_copy_string("&#x2988;"); return RIGHTDELIM;}
"\\lbrackubar" {yylval = itex2MML_copy_string("&#x298B;"); return LEFTDELIM;}
"\\rbrackubar" {yylval = itex2MML_copy_string("&#x298C;"); return RIGHTDELIM;}
"\\lbrackultick" {yylval = itex2MML_copy_string("&#x298D;"); return LEFTDELIM;}
"\\rbracklrtick" {yylval = itex2MML_copy_string("&#x298E;"); return RIGHTDELIM;}
"\\lbracklltick" {yylval = itex2MML_copy_string("&#x298F;"); return LEFTDELIM;}
"\\rbrackurtick" {yylval = itex2MML_copy_string("&#x2990;"); return RIGHTDELIM;}
"\\langledot" {yylval = itex2MML_copy_string("&#x2991;"); return LEFTDELIM;}
"\\rangledot" {yylval = itex2MML_copy_string("&#x2992;"); return RIGHTDELIM;}
"\\lparenless" {yylval = itex2MML_copy_string("&#x2993;"); return LEFTDELIM;}
"\\rparengtr" {yylval = itex2MML_copy_string("&#x2994;"); return RIGHTDELIM;}
"\\Lparengtr" {yylval = itex2MML_copy_string("&#x2995;"); return LEFTDELIM;}
"\\Rparenless" {yylval = itex2MML_copy_string("&#x2996;"); return RIGHTDELIM;}
"\\lblkbrbrak" {yylval = itex2MML_copy_string("&#x2997;"); return LEFTDELIM;}
"\\rblkbrbrak" {yylval = itex2MML_copy_string("&#x2998;"); return RIGHTDELIM;}
"\\fourvdots" {yylval = itex2MML_copy_string("&#x2999;"); return OTHERDELIM;}
"\\vzigzag" {yylval = itex2MML_copy_string("&#x299A;"); return OTHERDELIM;}
"\\measuredangleleft" {yylval = itex2MML_copy_string("&#x299B;"); return MI;}
"\\rightanglesqr" {yylval = itex2MML_copy_string("&#x299C;"); return MI;}
"\\rightanglemdot" {yylval = itex2MML_copy_string("&#x299D;"); return MI;}
"\\angles" {yylval = itex2MML_copy_string("&#x299E;"); return MI;}
"\\angdnr" {yylval = itex2MML_copy_string("&#x299F;"); return MI;}
"\\gtlpar" {yylval = itex2MML_copy_string("&#x29A0;"); return MI;}
"\\sphericalangleup" {yylval = itex2MML_copy_string("&#x29A1;"); return MI;}
"\\turnangle" {yylval = itex2MML_copy_string("&#x29A2;"); return MI;}
"\\revangle" {yylval = itex2MML_copy_string("&#x29A3;"); return MI;}
"\\angleubar" {yylval = itex2MML_copy_string("&#x29A4;"); return MI;}
"\\revangleubar" {yylval = itex2MML_copy_string("&#x29A5;"); return MI;}
"\\wideangledown" {yylval = itex2MML_copy_string("&#x29A6;"); return MI;}
"\\wideangleup" {yylval = itex2MML_copy_string("&#x29A7;"); return MI;}
"\\measanglerutone" {yylval = itex2MML_copy_string("&#x29A8;"); return MI;}
"\\measanglelutonw" {yylval = itex2MML_copy_string("&#x29A9;"); return MI;}
"\\measanglerdtose" {yylval = itex2MML_copy_string("&#x29AA;"); return MI;}
"\\measangleldtosw" {yylval = itex2MML_copy_string("&#x29AB;"); return MI;}
"\\measangleurtone" {yylval = itex2MML_copy_string("&#x29AC;"); return MI;}
"\\measangleultonw" {yylval = itex2MML_copy_string("&#x29AD;"); return MI;}
"\\measangledrtose" {yylval = itex2MML_copy_string("&#x29AE;"); return MI;}
"\\measangledltosw" {yylval = itex2MML_copy_string("&#x29AF;"); return MI;}
"\\revemptyset" {yylval = itex2MML_copy_string("&#x29B0;"); return MI;}
"\\emptysetobar" {yylval = itex2MML_copy_string("&#x29B1;"); return MI;}
"\\emptysetocirc" {yylval = itex2MML_copy_string("&#x29B2;"); return MI;}
"\\emptysetoarr" {yylval = itex2MML_copy_string("&#x29B3;"); return MI;}
"\\emptysetoarrl" {yylval = itex2MML_copy_string("&#x29B4;"); return MI;}
"\\circlehbar" {yylval = itex2MML_copy_string("&#x29B5;"); return MI;}
"\\circledvert" {yylval = itex2MML_copy_string("&#x29B6;"); return MO;}
"\\circledparallel" {yylval = itex2MML_copy_string("&#x29B7;"); return MO;}
"\\obslash" {yylval = itex2MML_copy_string("&#x29B8;"); return MO;}
"\\operp" {yylval = itex2MML_copy_string("&#x29B9;"); return MO;}
"\\obot" {yylval = itex2MML_copy_string("&#x29BA;"); return MI;}
"\\olcross" {yylval = itex2MML_copy_string("&#x29BB;"); return MI;}
"\\odotslashdot" {yylval = itex2MML_copy_string("&#x29BC;"); return MI;}
"\\uparrowoncircle" {yylval = itex2MML_copy_string("&#x29BD;"); return MI;}
"\\circledwhitebullet" {yylval = itex2MML_copy_string("&#x29BE;"); return MI;}
"\\circledbullet" {yylval = itex2MML_copy_string("&#x29BF;"); return MI;}
"\\olessthan" {yylval = itex2MML_copy_string("&#x29C0;"); return MO;}
"\\ogreaterthan" {yylval = itex2MML_copy_string("&#x29C1;"); return MO;}
"\\cirscir" {yylval = itex2MML_copy_string("&#x29C2;"); return MI;}
"\\cirE" {yylval = itex2MML_copy_string("&#x29C3;"); return MI;}
"\\boxdiag" {yylval = itex2MML_copy_string("&#x29C4;"); return MO;}
"\\boxbslash" {yylval = itex2MML_copy_string("&#x29C5;"); return MO;}
"\\boxast" {yylval = itex2MML_copy_string("&#x29C6;"); return MO;}
"\\boxcircle" {yylval = itex2MML_copy_string("&#x29C7;"); return MO;}
"\\boxbox" {yylval = itex2MML_copy_string("&#x29C8;"); return MO;}
"\\boxonbox" {yylval = itex2MML_copy_string("&#x29C9;"); return MI;}
"\\triangleodot" {yylval = itex2MML_copy_string("&#x29CA;"); return MI;}
"\\triangleubar" {yylval = itex2MML_copy_string("&#x29CB;"); return MI;}
"\\triangles" {yylval = itex2MML_copy_string("&#x29CC;"); return MI;}
"\\triangleserifs" {yylval = itex2MML_copy_string("&#x29CD;"); return MI;}
"\\rtriltri" {yylval = itex2MML_copy_string("&#x29CE;"); return MOL;}
"\\ltrivb" {yylval = itex2MML_copy_string("&#x29CF;"); return MOL;}
"\\vbrtri" {yylval = itex2MML_copy_string("&#x29D0;"); return MOL;}
"\\lfbowtie" {yylval = itex2MML_copy_string("&#x29D1;"); return MOL;}
"\\rfbowtie" {yylval = itex2MML_copy_string("&#x29D2;"); return MOL;}
"\\fbowtie" {yylval = itex2MML_copy_string("&#x29D3;"); return MOL;}
"\\lftimes" {yylval = itex2MML_copy_string("&#x29D4;"); return MOL;}
"\\rftimes" {yylval = itex2MML_copy_string("&#x29D5;"); return MOL;}
"\\hourglass" {yylval = itex2MML_copy_string("&#x29D6;"); return MO;}
"\\blackhourglass" {yylval = itex2MML_copy_string("&#x29D7;"); return MO;}
"\\lvzigzag" {yylval = itex2MML_copy_string("&#x29D8;"); return LEFTDELIM;}
"\\rvzigzag" {yylval = itex2MML_copy_string("&#x29D9;"); return RIGHTDELIM;}
"\\Lvzigzag" {yylval = itex2MML_copy_string("&#x29DA;"); return LEFTDELIM;}
"\\Rvzigzag" {yylval = itex2MML_copy_string("&#x29DB;"); return RIGHTDELIM;}
"\\iinfin" {yylval = itex2MML_copy_string("&#x29DC;"); return MI;}
"\\tieinfty" {yylval = itex2MML_copy_string("&#x29DD;"); return MI;}
"\\nvinfty" {yylval = itex2MML_copy_string("&#x29DE;"); return MI;}
"\\dualmap" {yylval = itex2MML_copy_string("&#x29DF;"); return MOL;}
"\\laplac" {yylval = itex2MML_copy_string("&#x29E0;"); return MI;}
"\\lrtriangleeq" {yylval = itex2MML_copy_string("&#x29E1;"); return MOL;}
"\\shuffle" {yylval = itex2MML_copy_string("&#x29E2;"); return MO;}
"\\eparsl" {yylval = itex2MML_copy_string("&#x29E3;"); return MOL;}
"\\smeparsl" {yylval = itex2MML_copy_string("&#x29E4;"); return MOL;}
"\\eqvparsl" {yylval = itex2MML_copy_string("&#x29E5;"); return MOL;}
"\\gleichstark" {yylval = itex2MML_copy_string("&#x29E6;"); return MOL;}
"\\thermod" {yylval = itex2MML_copy_string("&#x29E7;"); return MI;}
"\\downtriangleleftblack" {yylval = itex2MML_copy_string("&#x29E8;"); return MI;}
"\\downtrianglerightblack" {yylval = itex2MML_copy_string("&#x29E9;"); return MI;}
"\\blackdiamonddownarrow" {yylval = itex2MML_copy_string("&#x29EA;"); return MI;}
"\\mdlgblklozenge" {yylval = itex2MML_copy_string("&#x29EB;"); return MO;}
"\\circledownarrow" {yylval = itex2MML_copy_string("&#x29EC;"); return MI;}
"\\blackcircledownarrow" {yylval = itex2MML_copy_string("&#x29ED;"); return MI;}
"\\errbarsquare" {yylval = itex2MML_copy_string("&#x29EE;"); return MI;}
"\\errbarblacksquare" {yylval = itex2MML_copy_string("&#x29EF;"); return MI;}
"\\errbardiamond" {yylval = itex2MML_copy_string("&#x29F0;"); return MI;}
"\\errbarblackdiamond" {yylval = itex2MML_copy_string("&#x29F1;"); return MI;}
"\\errbarcircle" {yylval = itex2MML_copy_string("&#x29F2;"); return MI;}
"\\errbarblackcircle" {yylval = itex2MML_copy_string("&#x29F3;"); return MI;}
"\\ruledelayed" {yylval = itex2MML_copy_string("&#x29F4;"); return MOL;}
"\\dsol" {yylval = itex2MML_copy_string("&#x29F6;"); return MO;}
"\\rsolbar" {yylval = itex2MML_copy_string("&#x29F7;"); return MO;}
"\\xsol" {yylval = itex2MML_copy_string("&#x29F8;"); return MI;}
"\\xbsol" {yylval = itex2MML_copy_string("&#x29F9;"); return MI;}
"\\handleft" {yylval=itex2MML_copy_string("&#x261C;"); return MI;}
"\\handright" {yylval=itex2MML_copy_string("&#x261E;"); return MI;}
"\\handup" {yylval=itex2MML_copy_string("&#x261D;"); return MI;}
"\\handdown" {yylval=itex2MML_copy_string("&#x261F;"); return MI;}
"\\OK" {yylval=itex2MML_copy_string("&#x2611;"); return MI;}
"\\NOK" {yylval=itex2MML_copy_string("&#x2612;"); return MI;}
"\\poison" {yylval=itex2MML_copy_string("&#x2620;"); return MI;}
"\\blitz" {yylval=itex2MML_copy_string("&#x26A1;"); return MI;}
"\\attention" {yylval=itex2MML_copy_string("&#x26A0;"); return MI;}
"\\nsmile" {yylval=itex2MML_copy_string("&#x2639;"); return MI;}
"\\vvvert" {yylval=itex2MML_copy_string("&#x2AFC;"); return OTHERDELIM;}
"\\ointclockwise" |
"\\varointclockwise" {yylval=itex2MML_copy_string("&#x2A10;"); return MO;}
"\\ointctrclockwise" |
"\\varointctrclockwise" {yylval=itex2MML_copy_string("&#x2A11;"); return MO;}
"\\sqint" {yylval=itex2MML_copy_string("&#x2A16;"); return MO;}
"\\fint" {yylval=itex2MML_copy_string("&#x2AOF;"); return MO;}
"\\diagup"  {yylval=itex2MML_copy_string("&#x2571;"); return OTHERDELIM;}
"\\diagdown"    {yylval=itex2MML_copy_string("&#x2572;"); return OTHERDELIM;}
"\\bigint"    |
"\\bigintegral"     {return BIGINT;}
"\\biggint"    |
"\\biggintegral"     {return BIGGINT;}
"\\bigggint"   |
"\\bigggintegral"    {return BIGGGINT;}
"\\input{"\ {0,5}[0-9]{1,3}\ {0,5}"}{"[0-9]{1,3}\ {0,5}"}{"\ {0,5}[a-z0-9#\ :\-;.*?]{0,250}\ {0,5}"}{"\ {0,5}[a-zA-Z0-9#\ :\-\_\+\=\(\)\[\]\@\~\!\#\$\%\^\&\|\/\,;.*\^\?]{0,250}\ {0,5}"}{"\ {0,3}[0-1]\ {0,3}"}" {yylval=itex2MML_copy_string(yytext); return INPUT;}
"\\\\ \\\\"          {itex2MML_rowposn=2; yylval="\\\\ \\: \\\\";return ROWSEP;}
"\\\\"          {itex2MML_rowposn=2;return ROWSEP;}
"\\tabularnewline"       {itex2MML_rowposn=2; return ROWSEP;}
"\\hline"          {yylval=itex2MML_copy_string(" ");; return MOP; }
"\\cr"          {itex2MML_rowposn=2; return ROWSEP;}
"\\ "         {return THICKSPACE;}
"\\lbrack"             {yylval=itex2MML_copy_string("["); return OTHERDELIM;}
"\\rbrack"             {yylval=itex2MML_copy_string("]"); return OTHERDELIM;}
"\\RR" {yylval=itex2MML_copy_string("&Ropf;"); return MI;}
"\\QQ" {yylval=itex2MML_copy_string("&Qopf;"); return MI;}
"\\CC" {yylval=itex2MML_copy_string("&Copf;"); return MI;}
"\\ZZ" {yylval=itex2MML_copy_string("&Zopf;"); return MI;}
"\\NN" {yylval=itex2MML_copy_string("&Nopf;"); return MI;}
"\\size["[0-9]{1,4}"]" {yylval=itex2MML_copy_string(yytext+6);int len=strlen(yylval);if (yylval != itex2MML_empty_string) { yylval[len-1]='%'; itex2MML_env_start = 1; return TMP_FONTSIZE;}}
"\\large" { yylval=itex2MML_copy_string("120%");itex2MML_env_start = 1; return TMP_FONTSIZE;}
"\\Large" { yylval=itex2MML_copy_string("140%");itex2MML_env_start = 1; return TMP_FONTSIZE;}
"\\huge"  { yylval=itex2MML_copy_string("200%");itex2MML_env_start = 1; return TMP_FONTSIZE;}
"\\Huge"  { yylval=itex2MML_copy_string("250%");itex2MML_env_start = 1; return TMP_FONTSIZE;}
"\\cline{"\ {0,5}[0-9]{1,3}\ {0,5}-\ {0,5}[0-9]{1,3}\ {0,5}"}"
"\\'(" {yylval=itex2MML_copy_string("&grave;("); return MI;}
"\\includegraphics"(\[[^\]]*\])?\{[^}]*\};

"\\"[a-zA-Z]+    {yylval=itex2MML_copy_string(yytext+1); return MOP;}

"\&"[a-zA-Z_][a-zA-Z0-9_]*";" |
"\&#"[0-9]+";" |
"\&#x"[a-fA-F0-9]+";"  {yylval=itex2MML_copy_string(yytext); return MI;}

"\n"             itex2MML_lineno++;
[\r\t ]+           ;


.              {return UNKNOWNCHAR;}
}

<ATTRIBUTELIST>"{"[ \t\n\r #a-zA-Z0-9.\-]*"}"  {BEGIN(MATH); yylval=itex2MML_copy_string(yytext); if (yylval != itex2MML_empty_string) { yylval[0]='"'; yylval[yyleng-1]='"'; } return ATTRLIST;}


<FINDARG>"{color="*[a-zA-Z]*"}"  {BEGIN(MATH); yylval=itex2MML_copy_string(yytext+6);int len=strlen(yylval);if (yylval != itex2MML_empty_string) { yylval[0]='"'; yylval[len-1]='"'; } return ATTRLIST;}


<OPTARG>{
"[" {if(itex2MML_optarg_ind < itex2MML_optarg_depth - 1 && itex2MML_inoptarg[itex2MML_optarg_ind] !=1 ){itex2MML_optarg_ind++; itex2MML_inoptarg[itex2MML_optarg_ind]=1;}; BEGIN(MATH); return OPTARGOPEN;}
[\n\r\t ]+    ;
.   {BEGIN(MATH); unput(yytext[0]);}
}

<RAISEBOX1>{
\{[\n\r\t ]*- {BEGIN(RAISEBOX2); return NEG;}
\{[\n\r\t ]* {BEGIN(RAISEBOX2);}
}

<RAISEBOX2>{
[^\}]*?\}  {yylval=itex2MML_copy_string(yytext); if ((yyleng > 1) && (yylval != itex2MML_empty_string)) yylval[yyleng-1]='\0'; BEGIN(TEXTOPTARG1); return TEXTSTRING;}
}


<TEXTOPTARG1>{
\[[^\]]*?\] {yylval=itex2MML_copy_string(yytext+1); if ((yyleng > 1) && (yylval != itex2MML_empty_string)) yylval[yyleng-2]='\0'; BEGIN(TEXTOPTARG); return TEXTSTRING;}
. {BEGIN(MATH); unput(yytext[0]);}
}

<TEXTOPTARG>{
\[[^\]]*?\] {yylval=itex2MML_copy_string(yytext+1); if ((yyleng > 1) && (yylval != itex2MML_empty_string)) yylval[yyleng-2]='\0'; BEGIN(MATH); return TEXTSTRING;}
. {BEGIN(MATH); unput(yytext[0]);}
}

<MATHENV>{
"\{matrix\}" {itex2MML_env_start = 0; BEGIN(MATH); return MATRIX;}
"\{pmatrix\}" {itex2MML_env_start = 0; BEGIN(MATH); return PMATRIX;}
"\{bmatrix\}" {itex2MML_env_start = 0; BEGIN(MATH); return BMATRIX;}
"\{Bmatrix\}" {itex2MML_env_start = 0; BEGIN(MATH); return BBMATRIX;}
"\{vmatrix\}" {itex2MML_env_start = 0; BEGIN(MATH); return VMATRIX;}
"\{Vmatrix\}" {itex2MML_env_start = 0; BEGIN(MATH); return VVMATRIX;}
"\{smallmatrix\}" {itex2MML_env_start = 0; BEGIN(MATH); return SMALLMATRIX;}
"\{cases\}" |
"\{dcases\}" {itex2MML_env_start = 0; BEGIN(MATH); return CASES;}
"\{align*\}" |
"\{align\}" |
"\{aligned\}" {itex2MML_env_start = 0; BEGIN(MATH); return ALIGNED;}
"\{gathered\}" {itex2MML_env_start = 0; BEGIN(MATH); return GATHERED;}
"\{split\}" {itex2MML_env_start = 0; BEGIN(MATH); return ALIGNED;}
"\{array\}" |
"\{alignat\}" {if (itex2MML_env_start == 1) BEGIN(ARRAYOPTIONS); else BEGIN(MATH); return ARRAY;}
"\{svg\}" {itex2MML_env_start = 0; BEGIN(SVGENV); return SVG;}
"\{html\}" {itex2MML_env_start = 0; BEGIN(HTMLENV); return HTML;}
"\{equation\}"  {itex2MML_env_start = 0; BEGIN(MATH); return EQUATION;}
"\{eqnarray\}" {itex2MML_env_start = 0; BEGIN(MATH); return MATRIX;}

}

<ARRAYOPTIONS>{
"[t]" {yylval=itex2MML_copy_string("axis 1"); return ARRAYALIGN;}
"[c]" {yylval=itex2MML_copy_string("center"); return ARRAYALIGN;}
"[b]" {yylval=itex2MML_copy_string("axis -1"); return ARRAYALIGN;}
"\{"  {BEGIN(COLOPTS); return ST;}
[\t\n\r ]+       ;
}

<COLOPTS>{
"\}"  {itex2MML_env_start = 0; BEGIN(MATH); return END;}
[0-99rlc|.:_\-\ ]{0,99} {
    itex2MML_env_start=0;
    int p;
    // yyleng is length of last matched token eg "{ c |ccc|c }
    // 8 is max length of tag " center " ; 14 is length " columnalign=\"" 14+1 '\0'
    // {----c|c|c}
    int len = yyleng*8+15;
    char C[len];
    char M[len];
    char H[len];
    memset(C,'\0',len);// fill memory with null
    memset(M,'\0',len);
    memset(H,'\0',len);
    strncat(C," columnalign=\"",14);
    strncat(M," columnlines=\"",14);
    strncat(H," rowlines=\"",11);
    /* {c|c|c|c---}*/
    for( p = 0; p < yyleng ; p++){
    if( strlen(C) < (len - 8) && strlen(M) < (len - 8)){
    /* in case of trouble...array M[len] or C[len] will be too small */
        switch( yytext[p] ){
            case 'c' : strncat(C," center ",8);break;
        case 'r' : strncat(C," right ",7);break;
            case 'l' : strncat(C," left ",6); break;
        case '|' : strncat(M," solid ",7);break;
            case ':' : strncat(M," dashed ",8);break;
            case '-' : strncat(H," solid ",7);break;
            case '_' : strncat(H," dashed ",8);break;
            case '.' : strncat(H," none ",6);break;
            case ' ' : break;
        default  : strncat(M," none ",6);strncat(H," none ",6);break;
        }
    }
    }
     /* 31/5/2017 bug in MathJax :  rowlines="" will show rowlines */
    if( strlen(M) < 16 ){  strncat(M," none ",6); }
    if( strlen(H) < 16 ){  strncat(H," none ",6); }
    strncat(C,"\" ",2);
    strncat(M,"\" ",2);
    strncat(H,"\" ",2);

    yylval=itex2MML_copy3(C,M,H);
    return TEX_OPTIONS;
  }
}

<SVGENV>{
"\\end\{svg" {
    yylval = itex2MML_copy_string(yytext);
    replace_str(yylval,"\\lt ","<");
    replace_str(yylval,"\\gt ",">");
    yyleng = strlen(yylval);
    yylval[yyleng-8]=0; BEGIN(SVGEND); return XMLSTRING;}
(.|\n) {yymore();}
}

<SVGEND>{
"\}" {BEGIN(MATH); return ENDSVG;}
}

<HTMLENV>{
"\\end\{html" {
    yylval = itex2MML_copy_string(yytext);
    replace_str(yylval,"\\lt ","<");
    replace_str(yylval,"\\gt ",">");
    yyleng = strlen(yylval);
    yylval[yyleng-9]=0; BEGIN(HTMLEND); return XMLSTRING;}
(.|\n) {yymore();}
}

<HTMLEND>{
"\}" {BEGIN(MATH); return ENDHTML;}
}

<ROMAN>{
"\{"  {return ST;}
"\}"  {BEGIN(MATH); return END;}
[a-zA-Z]   {yylval=itex2MML_copy_string(yytext); return RMCHAR;}
[\t\n\r ]+       ;
.           {return yytext[0];}
}

<BBOLD>{
"\{"  {return ST;}
"\}"  {BEGIN(MATH); return END;}
[a-z] {yylval=itex2MML_copy_string(yytext); return BBLOWERCHAR;}
[A-Z]   {yylval=itex2MML_copy_string(yytext); return BBUPPERCHAR;}
[0-9]   {yylval=itex2MML_copy_string(yytext); return BBDIGIT;}
[\t\n\r ]+       ;
.           {return yytext[0];}
}

<CALLIGRAPHIC>{
"\{"  {return ST;}
"\}"  {BEGIN(MATH); return END;}
[a-zA-Z]   {yylval=itex2MML_copy_string(yytext); return CALCHAR;}
[\t\n\r ]+       ;
.           {return yytext[0];}
}

<FRAKTUR>{
"\{"  {return ST;}
"\}"  {BEGIN(MATH); return END;}
[a-zA-Z]   {yylval=itex2MML_copy_string(yytext); return FRAKCHAR;}
[\t\n\r ]+       ;
.           {return yytext[0];}
}

<PLAINTEXT>{
\{[^\}]*?\}  {yylval=itex2MML_copy_string(yytext+1); if ((yyleng > 1) && (yylval != itex2MML_empty_string)) yylval[yyleng-2]='\0'; BEGIN(MATH); return TEXTSTRING;}
}

<INT1>{ 
"\{"      {return ST;}
"\}"      {BEGIN(INT2); return END;}
[0-9]+    {yylval=itex2MML_copy_string_extra(yytext, 1); if (yyleng && (yylval != itex2MML_empty_string)) { yylval[yyleng]=yylval[yyleng-1]; yylval[yyleng-1]='.'; yylval[yyleng+1]='\0'; } return INTONE;}
[\t\n\r ]+   ;
.         {return yytext[0];}
}

<INT2>{
"\{"      {return ST;}
"\}"      {BEGIN(INT3); return END;}
[0-9]+    {yylval=itex2MML_copy_string_extra(yytext, 1); if (yyleng && (yylval != itex2MML_empty_string)) { yylval[yyleng]=yylval[yyleng-1]; yylval[yyleng-1]='.'; yylval[yyleng+1]='\0'; } return INTTWO;}
[\t\n\r ]+   ;
.         {return yytext[0];}
}

<INT3>{
"\{"      {return ST;}
"\}"      {BEGIN(MATH); return END;}
[0-9]+    {yylval=itex2MML_copy_string_extra(yytext, 1); if (yyleng && (yylval != itex2MML_empty_string)) { yylval[yyleng]=yylval[yyleng-1]; yylval[yyleng-1]='.'; yylval[yyleng+1]='\0'; } return INTTHREE;}
[\t\n\r ]+   ;
.         {return yytext[0];}
}



%%

void itex2MML_restart ()
{
	BEGIN(INITIAL);
}

static const char *  s_itex2MML_buffer = 0;
static unsigned long s_itex2MML_length = 0;

void itex2MML_setup (const char * buffer, unsigned long length)
{
	yy_flush_buffer( YY_CURRENT_BUFFER );

	s_itex2MML_buffer = buffer;
	s_itex2MML_length = length;
}

static int s_itex2MML_read (char * buffer, int max_size)
{
	int result = 0;

	if (max_size < s_itex2MML_length)
	{
		result = max_size;

		memcpy (buffer, s_itex2MML_buffer, max_size);

		s_itex2MML_buffer += max_size;
		s_itex2MML_length -= max_size;
	}
	else
	{
		result = s_itex2MML_length;

		memcpy (buffer, s_itex2MML_buffer, s_itex2MML_length);

		s_itex2MML_buffer = 0;
		s_itex2MML_length = 0;
	}
	return result;
}
