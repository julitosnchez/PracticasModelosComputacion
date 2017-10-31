/*----- Sección de Declaraciones --------------*/
%{
#include <stdio.h>
%}

servidor "hotmail.es"|"correo.ugr.es"|"hotmail.com"|"yahoo.es"

%%
	/*----- Sección de Reglas ----------------*/
[0-4][0-9][0-9][0-9][0-9]	{printf("Codigo Postal:""%s\n",yytext);}
[0-9]{8,8}\-[A-Z]	{printf("NIF:""%s\n",yytext);}
[0-9]{4,4}\-([BCDFGHIJKLMNPRSTVWXYZ]){3,3}	{printf("MATRICULA:""%s\n",yytext);} //"https://es.wikipedia.org/wiki/Matr%C3%ADculas_automovil%C3%ADsticas_de_Espa%C3%B1a#Sistema_nacional"
[967][0-9][0-9][\-\ ][0-9][0-9][\-\ ][0-9][0-9][\-\ ][0-9][0-9]	{printf("NUMERO TLF:""%s\n",yytext);}
[0123][0-9][\/\-][01][0-9][\/\-][0-9][0-9][0-9][0-9]	{printf("FECHA:""%s\n",yytext);}
"https://|""http://"|"www."[A-Za-z0-9~/.]{1,}	{printf("PAGINA WEB:""%s\n",yytext);}
[A-Za-z0-9._]{1,}\@{servidor}	{printf("CORREO:""%s\n",yytext);}
.	{}
%%

/*----- Sección de Procedimientos --------*/

int main(int argc,char *argv[])
{
	if(argc == 2)
	{
		yyin = fopen(argv[1],"rt");
		if (yyin == NULL)
		{
			printf ("El fichero %s no se puede abrir\n", argv[1]);
			exit (-1);
		}
	}
	else yyin = stdin;
	yylex();
	return 0;
}