/*----- Sección de Declaraciones --------------*/
%{
#define	MAX 100

typedef struct AN
{
	int nAtributos;
	char nominalEspecificacion[MAX][MAX];
} AtributosNominales;

#include <stdio.h>
#include <string.h>


int leyendoDatos;
int iteradorDatos;
char  nombre_relacion[MAX];

AtributosNominales atributos_nominales[MAX];
char tipo_atributo[MAX];
int iterador_atributos;


int linea;

void comienzaLectura();
void relacion(char * nombreRelacion);
void atributo(char * nuevoAtributo);
void compruebaSiToca(char  d);

/*
	FECHAS FORMATO---¿TODAS LAS COMBINACIONES SON POSIBLES? SIEMPRE HEMOS DE INDICAR yyyy MM dd HH mm ss?
*/

%}

Comentario	"%"(.+)
SaltoLinea	\n
Relacion	"@RELATION"|"@relation"
Atributo	"@ATTRIBUTE"|"@attribute"
String	[a-zA-Z]+|\'([a-zA-Z][\ ]*)+\'
Digito	[0-9]
Numero	{Digito}+|{Digito}+\.{Digito}+
Espacio	[\ ]+
Nominal	[a-zA-Z]+
NominalEspecificacion	({Nominal}\-{String}\,?)+
TipoDato	"NUMERIC"|"numeric"|"string"|"STRING"|"DATE"|"date"|\{({NominalEspecificacion})\}	  
Datos	"@data"|"@DATA"

%%
	/*----- Sección de Reglas ----------------*/
{Comentario}
{SaltoLinea}	{linea++;iteradorDatos=0;}
{Relacion}{Espacio}{String}	{relacion(yytext);}
{Atributo}{Espacio}{String}{Espacio}{TipoDato}	{atributo(yytext);}
{Datos}	{comienzaLectura();}
{Numero}\,?	{compruebaSiToca('n');}
{String}\,?	{compruebaSiToca('s');}
{NominalEspecificacion}\,?	{compruebaSiToca('{');}
\?,?	{iteradorDatos++;}
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

	linea = 1;
	leyendoDatos = iterador_atributos = iteradorDatos = 0;

	yylex();
	return 0;
}

void comienzaLectura()
{
	if(leyendoDatos == 0)
		leyendoDatos = 1;
	else
	{
		printf("\n\nError en linea %i, seccion @data ya se había leído\n",linea);
		exit(-1);
	}
}

void relacion(char * nombreRelacion)
{

	if(strlen(nombre_relacion) == 0)
	{	//Nos quitamos @relation
		int i = 0;	
		while(nombreRelacion[i] != ' ') i++;
		//NOs quitamos espacios
		while(nombreRelacion[i] == ' ') i++;
	
		int j = 0;
		while(nombreRelacion[i] != '\0')
			nombre_relacion[j++] = nombreRelacion[i++];
		nombre_relacion[j] = '\0';
	}
	else
	{
		printf("\nError: Redeclaracion de seccion @RELATION en linea %i\n",linea);
		exit(-1);
	}
}

void atributo(char * nuevoAtributo)
{
	//printf("NUEVO ATRIBUTO: %s\n",nuevoAtributo);
	//Nos quitamos @relation
	int i = 0;
	while(nuevoAtributo[i] != ' ') i++;
	//Nos quitamos espacios
	while(nuevoAtributo[i] == ' ') i++;
	//nombre atributo
	while(nuevoAtributo[i] != ' ') i++;
	while(nuevoAtributo[i] == ' ') i++;
	//Tipo Atributo
	tipo_atributo[iterador_atributos] = nuevoAtributo[i];

	//comprobamos que todos los nominales sean iguales
	char nominal[MAX];
	nominal[0] = '\0';

	AtributosNominales an;an.nAtributos = 0;
	if(nuevoAtributo[i] == '{') //Especificacion nominales
	{
		i++;
		while(nuevoAtributo[i] != '}')
		{
			int j = 0;
			int in = 0;
			//NOs quedamos con nominal
			char aux_nominal[MAX];
			while(nuevoAtributo[i] != '-')
			{
				an.nominalEspecificacion[an.nAtributos][j++] = nuevoAtributo[i];
				aux_nominal[in++] = nuevoAtributo[i++];
			}
			aux_nominal[in] = '\0';

			//COmprobamos que todos tienen mismo nominal
			if(strlen(nominal) == 0)
				strcpy(nominal,aux_nominal);
			else if(strcmp(nominal,aux_nominal))
				{
					printf("Error: El valor nominal difiere en linea %i\n",linea);
					exit(-1);
				}

			while(nuevoAtributo[i] != ',' && nuevoAtributo[i] != '}')
			{
				an.nominalEspecificacion[an.nAtributos][j++] = nuevoAtributo[i++];
			}
			if(nuevoAtributo[i] == ',') i++;
			an.nominalEspecificacion[an.nAtributos][j] = '\0';
			an.nAtributos++;
		}
	}
	atributos_nominales[iterador_atributos] = an;

	iterador_atributos++;
}

void compruebaSiToca(char  d)
{
	if(leyendoDatos == 0)
	{
		printf("Se ha recibido dato y no se ha declarado seccion @data en linea %i\n",linea);
		exit(-1);
	}

	char dMayus = d-32;
	if(d != tipo_atributo[iteradorDatos] && dMayus != tipo_atributo[iteradorDatos])
	{
		printf("Error: Se esperaba %c y se ha recibido %c en linea %i\n",tipo_atributo[iteradorDatos],d,linea);
		exit(-1);
	}
	else
		iteradorDatos++;
}





