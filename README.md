# TP Nro 2 - Flex & Bison
Trabajo Práctico de un compilador desarrollado usando las herramientas Flex y Bison.


##INVESTIGACIÓN
Al terminar el desarrollo del compilador, se ha descubierto que Bison advierte con el siguiente aviso:
```
parser.y: aviso: 4 conflictos desplazamiento/reducción [-Wconflicts-sr]
```
<br />
Luego de investigar sobre dicho error, se descubrió el siguiente comando:
```
bison -v parser.y
```
<br />
El mismo tiene como objetivo soltar un archivo `parser.output` que nos indica en lenguaje humano cómo está conformado nuestro código y dónde están dichas advertencias.

<br />
Resultó que esas advertencias existen porque Bison automáticamente se encarga de optimizar el código, aunque podríamos haberlo hecho nosotros mismos.
<br />
Por lo que se llegó al siguiente [ENLACE](https://efxa.org/2014/05/17/techniques-for-resolving-common-grammar-conflicts-in-parsers/).

El mismo nos explica cómo solucionar problemas típicos a la hora de diseñar nuestro `parser` y llegado el primer ejemplo está nuestro caso.


>Bison can recognize two type of conflicts:
>
>    **shift/reduce:** situation where a token can be shifted and a grammar rule can be reduced
>
>    **reduce/reduce:** situation where two grammar rules can be reduced

<br />
##Conflicts in Expression Grammars

>Let’s start with conflicts that usually occur when designing the expression grammar of a programming language. In an expression grammar the most common conflicts occur when we forget to implement the associativity property and the precedence of the various tokens.
>
>There are two ways to specify precedence and associativity in a grammar, implicitly and explicitly. When we specify the expression grammar implicitly we have to implement nonterminal symbols for each precedence level. This is perfectly reasonable way to write a grammar, and if Bison didn’t have explicit precedence rules, it would be the only way.
>
>This is how an expression grammar could be designed implicitly for supporting arithmetic expressions:

```
%%
... more grammar rules ...

exp: factor
  | exp '+' factor { $$ = new_ast_node ('+', $1, $3); }
  | exp '-' factor { $$ = new_ast_node ('-', $1, $3); }
;

factor: term
  | factor '*' term { $$ = new_ast_node ('*', $1, $3); }
  | factor '/' term { $$ = new_ast_node ('/', $1, $3); }
;

term: NUMBER    { $$ = new_ast_number_node ($1); }
  | '(' exp ')' { $$ = $2; }
  | '-' term    { $$ = new_ast_node ('M', $2, NULL); }
;

... more grammar rules ...
%%
```

>However, when there are many precedence levels with various tokens and more complicated expression syntaxes, is very hard to maintain a grammar based in this old fashion structure which implements for each precedence level a different nonterminal symbol (“exp”, “factor”, “term”, etc).
>
>Another better approach for designing an expression grammar could be the following:

```
%%
... more grammar rules ...

exp
  : exp RELATIONAL exp    { $$ = new_ast_relational_node ($2, $1, $3); }
  | exp EQUALITY exp      { $$ = new_ast_equality_node ($2, $1, $3); }
  | exp '+' exp           { $$ = new_ast_node ('+', $1, $3); }
  | exp '-' exp           { $$ = new_ast_node ('-', $1, $3);}
  | exp '*' exp           { $$ = new_ast_node ('*', $1, $3); }
  | exp '/' exp           { $$ = new_ast_node ('/', $1, $3); }
  | '(' exp ')'           { $$ = $2; }
  | '-' exp %prec UMINUS  { $$ = new_ast_node ('M', $2, NULL); }
  | NUMBER                { $$ = new_ast_number_node ($1); }
  | NAME                  { $$ = new_ast_symbol_reference_node ($1); }
  | NAME '(' ')'          { $$ = new_ast_function_node ($1, NULL); }
  | NAME '(' exp_list ')' { $$ = new_ast_function_node ($1, $3); }
;

... more grammar rules ...
%%
```

>This expression grammar is more elegant and promises evolvable recursive expression syntaxes. However, Bison produces many shift/reduce conflicts due to the fact that we have not provided instructions about the associativity property and the precedence level of the tokens. So, for example the following expression as input “exp – exp – exp” has a shift/reduce conflict since Bison cannot decide the way that input will be parsed. There are two possible ways of parsing:

```
Case 1: (exp - exp) - exp

Case 2: exp - (exp - exp)
```

>This shift/reduce conflict can be resolved by instructing Bison the associativity property of the ‘-‘ token. Also, the expression “exp – exp * exp” produces a similar conflict but now we have to care also about the precedence level of the tokens ‘-‘ and ‘*’. Again, this conflict can also be resolved by instructing Bison the precedence of the tokens.
>
>So, in order to resolve shift/reduce conflicts that occur in the above grammar we can use the precedence declarations of Bison. By using “%left”, “%right” or “%nonassoc” declarations we can support associativity and complex precedence levels:

```
%left <operator> EQUALITY
%left <operator> RELATIONAL
%left '+' '-'
%left '*' '/'
%right UMINUS
```

>For the above expression grammar we support five precedence levels from lowest to highest. Each precedence declaration describes both the precedence level of related grouped tokens and their associativity property. Also for the EQUALITY and RELATIONAL tokens we specify their value.
>
>If we want to reuse a token in an alternative syntax and give it a different meaning we can do it without restrictions. But, we should know that the precedence level or the associativity property of the token might not be the appropriate. For example, in our grammar we reuse the ‘-‘ token as a unary operator to support negative expressions. However, the ‘-‘ unary operator has right associativity and a higher precedence. In order to override both properties we use the “%prec” declaration and a fake token UMINUS.

<br />
##CONCLUSIÓN

Debido a esta inquietud se decidió separar el proyecto en 2 partes:
- La primera llamada `original` que contiene el parser tal y como aparece en el documento con las instrucciones del trabajo práctico.
- La segunda llamada `optimizado` que contiene el parser con los cambios aplicados.

Para nuestro asombro, una vez aplicado los cambios propuestos por el sitio antes citado, Bison dejó de avisarnos con sus advertencias.

<br />
##EJECUCIÓN

Para mayor comodidad a la hora de corregir ambas ramas del trabajo, se creó un archivo `compilador.sh` que al ser ejecutado desde una consola de comandos en Linux nos permitirá interactuar con nuestro trabajo de forma eficiente y cómoda.
