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
error_id [a-zA-Z][a-zA-Z0-9]*[^a-zA-Z0-9\ \n\t;,()/*+-]+[a-zA-Z0-9]*
error_sym [^a-zA-Z0-9\ \t;,()\/\*\+\-]
%%
"inicio"					{ return INICIO; }
"fin"						{ return FIN; }
"leer"						{ return LEER; }
"escribir"					{ return ESCRIBIR; }
{letra}({letra}|{digito})*			{ yylval = strdup(yytext);
						  return IDENTIFICADOR; }
{digito}+					{ yylval = strdup(yytext); 
						  return CONSTANTE; }
":="						{ return ASIGNACION; }
-						{ return '-'; }
\+						{ return '+'; }
\*						{ return '*'; }
\/						{ return '/'; }
\(						{ return '('; }
\)						{ return ')'; }
,						{ return ','; }
;						{ return ';'; }
{digito}+{letra}+				{ nerrlex++;
		  				  yyerror("Error léxico: constante con sufijo inválido\n"); }
{error_id}					{ nerrlex++;
						  yyerror("Error léxico: identificador inválido\n"); }
{error_sym}					{ nerrlex++;
	 					  yyerror("Error léxico: cadena desconocida\n"); }
.|\n						|
"//".*						;
%%

