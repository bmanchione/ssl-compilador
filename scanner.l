%{
#include <stdio.h>
#include <strings.h>
#include "parser.h"
%}
%option header-file="scanner.h"
%option outfile="scanner.c"
%option yylineno

digito [0-9]
letra [a-zA-Z]
%%
{letra}({letra}|{digito})*			{ yylval = strdup(yytext);
						  return IDENTIFICADOR; }
{digito}+					{ yylval = strdup(yytext); 
						  return CONSTANTE; }
"inicio"					{ return INICIO; }
"fin"						{ return FIN; }
"leer"						{ return LEER; }
"escribir"					{ return ESCRIBIR; }
":="						{ return ASIGNACION; }
-						{ return '-'; }
\+						{ return '+'; }
\*						{ return '*'; }
\/						{ return '/'; }
\(						{ return '('; }
\)						{ return ')'; }
,						{ return ','; }
;						{ return ';'; }
{dig}+{letra}+					{ nerrlex++;
		  				  yyerror("Error léxico: constante con sufijo inválido\n"); }
{letra}({letra}|{digito})*[^{letra}{digito}]	{ nerrlex++;
						  yyerror("Error léxico: identificador inválido\n"); }
.						{ nerrlex++;
	 					  yyerror("Error léxico: cadena desconocida\n"); }
.|\n						|
\\{2}.*\n					;
%%

