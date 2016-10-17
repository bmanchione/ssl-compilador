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
error_id [a-zA-Z][a-zA-Z0-9]*[@#]+[a-zA-Z0-9]*
error_sym [@#]+
error_cons [0-9][a-zA-Z0-9]+
%%
"inicio"					{ return INICIO; }
"fin"						{ return FIN; }
"leer"						{ return LEER; }
"escribir"					{ return ESCRIBIR; }
{letra}({letra}|{digito})*			{ yylval = strdup(yytext);
						  return ID; }
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
{error_cons}					{ nerrlex++;
		  				  yyerror("Error léxico: constante con sufijo inválido"); }
{error_id}					{ nerrlex++;
						  yyerror("Error léxico: identificador inválido"); }
{error_sym}					{ nerrlex++;
	 					  yyerror("Error léxico: cadena desconocida"); }
.|\n						|
"//".*						;
%%

