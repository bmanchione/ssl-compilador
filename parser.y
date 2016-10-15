%code top {
#include <stdio.h>
#include "scanner.h"
#define YYERROR_VERBOSE
void yyerror(const char *);

void comenzar(void);
void terminar(void);
void verificar(void);
void asignar(const char *, const char *);
void leer_id(const char *);
const char *chequear(const char *);
void escribir_exp(const char *);
const char *gen_infijo(const char *, const char, const char *);
}

%code provides {
void yyerror(const char *s);
extern int nerrlex;
}

%token IDENTIFICADOR CONSTANTE INICIO FIN LEER ESCRIBIR ASIGNACION
%define api.value.type {char *}
%right IDENTIFICADOR
%left '+' '-'
%left '*' '/'

%%

programa		: { comenzar(); } INICIO sentencias FIN { terminar(); }
			;
listaSentencias		: sentencia
			| listaSentencias sentencia
			;
sentencia		: identificador ASIGNACION expresion ';' { asignar($1, $3); }
			| LEER '(' listaIdentificadores ')' ';'
			| ESCRIBIR '(' listaExpresiones ')' ';'
			| error ';' { yyerrok; }
			;
listaIdentificadores	: identificador { leer_id($1); }
			| listaIdentificador ',' identificador { leer_id($3); }
			;
identificador		: IDENTIFICADOR { $$ = chequear($1); }
			;
listaExpresiones	: expresion { escribir_exp($1); }
			| listaExpresiones ',' expresion
			;
expresion		: termino
			| expresion operadorAditivo termino { $$ = gen_infijo($1, $2, $3); }
			;
operadorAditivo		: '+'
			| '-'
termino			: primaria
			| termino operadorMultiplicativo primaria { $$ = gen_infijo($1, $2, $3); }
operadorAditivo		: '*'
			| '/'
			;
primaria		: identificador
			| CONSTANTE
			| '(' expresion ')'
			| '-' expresion { $$ = gen_infijo($2, $1, NULL); }
			;

%%

struct definiciones {
	char **vars;
	int v_size = 0;
	int t_size = 0;
} defs;
int nerrlex = 0;

const char *declarar_temporal() {
	char *t_str;
	defs.t_size++;
	printf("Declare Temp&%d,Integer,", defs.t_size);

	sscanf(defs.t_size, "Temp&%d", t_str);
	
	return t_str;
}

const char *declarar_variable(const char *id) {
	char **new_vars = realloc(defs.vars, defs.v_size + 1);

	if(new_vars != NULL) {
		new_vars[defs.v_size] = (char *) malloc(sizeof id);
		defs.vars = new_vars;
		defs.v_size++;
	}

	printf("Declare %c,Integer,", id);

	return id;
}

void escribir_exp(const char *val) {
	printf("Write %s,Integer,", val);
}

void leer_id(const char *val) {
	printf("Read %s,Integer,", val);
}

void asignar(const char *val1, const char *val2) {
	printf("Store %s,%s,", val1, val2);
}

const char *gen_infijo(const char *val1, const char op, const char *val2) {
	const char *temp = declarar_temporal();
	char *op_str[4];

	switch(op) {
	case '-':
		op_str = "SUBS";
	break;
	case '*':
		op_str = "MULT";
	break;
	case '/':
		op_str = "DIV";
	break;
	case '+':
		op_str = "ADD";
	break;
	}
	
	printf("%s %s,%s,%s", op_str, val1, val2, temp);
	return temp;
}

const char *gen_infijo(const char *val) {
	const char *temp = declarar_temporal();

	printf("INV %s,,%s", val, temp);

	return temp;
}

void chequear(const char *id) {
	int ya_definido = 0;

	for (int i = 0; i < defs.v_size; i++) {
		if(strcmp(defs.vars[i], id) == 0) {
			ya_definido = 1;
			break;
		}
	}

	if(!ya_definido) {
		declarar_variable(id);
	}
}

void verificar() {
	if (nerrlex) YYABORT;
	else YYACCEPT;
}

void terminar(void) {
	puts("Stop ,,");
	verificar();
}

void comenzar(void) {
	puts("Load rtlib,,");
}

int main() {
	int value = yyparse();

	switch( value ){
	case 0:
		puts("Compilación terminada con éxito");
		break;
	case 1:
		puts("Errores de compilación");
		break;
	case 2:
		puts("Memoria insuficiente");
		break;
	}

	printf("Errores sintácticos: %d - Errores léxicos: %d", yynerrs, nerrlex);
	return 0;
}

void yyerror(const char *s){
	printf("línea #%d - %s", yylineno, s);
	return;
}

