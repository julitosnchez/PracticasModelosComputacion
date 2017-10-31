/*----- Sección de Declaraciones --------------*/
%{



#include <stdio.h>
#include <string.h>

#define N_MAX_PALABRAS 100

int np;
char cifrado[N_MAX_PALABRAS] = "";
int p = 0;

void daLaVuelta(const char * text); 

%}

%%
	/*----- Sección de Reglas ----------------*/
[^ \t\n]+	{np++;daLaVuelta(yytext);}

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

	np = 0;
	yylex();
	printf("Numero de palabras=%d\n",np);
	printf("Texto cifrado:%s\n\n",cifrado);
	return 0;
}

void daLaVuelta(const char * text)
{
	for(int i=strlen(text);i>0;i--)
		cifrado[p++] = text[i-1];
	cifrado[p++] = ' ';
}