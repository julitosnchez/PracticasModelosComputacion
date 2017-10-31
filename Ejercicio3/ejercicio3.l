/*----- Sección de Declaraciones --------------*/
%{
#include <stdio.h>
#include <stdlib.h>
int nMayusc,nMinus,nMezcla,nEnteros,nReales;
double sumaReales;
int sumaEnteros;

void sumaEntero(char * entero);
void sumaReal(char * real);
%}

Mayuscula [A-Z]
Minuscula [a-z]
Letra [A-Za-z]
Digito [0-9]
Entero (\+|\-)?({Digito})+
Real1 (\+|\-)?({Digito})+\.({Digito})+
Real2 {Entero}["e""E"]{Entero}
 

%%
	/*----- Sección de Reglas ----------------*/
{Mayuscula}+	{nMayusc++;}
{Minuscula}+	{nMinus++;}
{Letra}+	{nMezcla++;}
{Entero}	{nEnteros++;sumaEntero(yytext);}
{Real1}	{nReales++;sumaReal(yytext);}
{Real2}	{nReales++;sumaReal(yytext);}
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

	nMayusc = nMinus = nMezcla = nEnteros = nReales = sumaEnteros = 0;
	sumaReales = 0.0;

	yylex();
	printf("MAYUSCULAS:%i\n",nMayusc);
	printf("MINUSCULAS:%i\n",nMinus);
	printf("MEZCLA:%i\n",nMezcla);
	printf("NUMERO ENTEROS:%i\n",nEnteros);
	printf("NUMERO REALES:%i\n",nReales);
	printf("SUMA ENTEROS:%i\n",sumaEnteros);
	printf("SUMA REALES:%f\n",sumaReales);
	return 0;
}

void sumaEntero(char * entero)
{
	sumaEnteros += atoi(entero);
}

void sumaReal(char * real)
{
	sumaReales += atof(real);
}

