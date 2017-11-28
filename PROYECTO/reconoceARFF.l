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
char correspondencia[MAX][MAX]; //TIPO ATRIBUTO - NOMBRE TIPO ATRIBUTO


int linea;
int formatoFecha[MAX];
int iteradorFecha;

void comienzaLectura();
void relacion(char * nombreRelacion);
void atributo(char * nuevoAtributo);
void compruebaSiToca(char  d);
char * corresponde(char tipo,int i);

/*
	FALTAN FECHAS
*/

%}

Comentario	"%"(.+)

FormatoFecha	"yyyy-MM-dd HH:mm:ss"|"dd-MM-yyyy HH:mm:ss"
Anio	\2\0\0[0-9]|\2\0\1[0-7]|[01][0-9][0-9][0-9]
Mes	\0[1-9]|\1[12]
Dia	[012][0-9]|\3[01]

Caracter	.
SaltoLinea	\n
Relacion	"@RELATION"|"@relation"
Atributo	"@ATTRIBUTE"|"@attribute"
Espacio	[\ ]+
String	\'({Caracter}+{Espacio}?)+\'|[a-zA-Z]+
Digito	[0-9]
Numero	{Digito}+|{Digito}+\.{Digito}+
Nominal	[a-zA-Z]+
NominalEspecificacion	({Nominal}\-{String}\,?)
TipoDato	"NUMERIC"|"numeric"|"string"|"STRING"|"DATE"|"date"|\{({NominalEspecificacion}+)\}
Datos	"@data"|"@DATA"

%%
	/*----- Sección de Reglas ----------------*/
{Comentario}
{SaltoLinea}	{linea++;iteradorDatos=0;iteradorFecha=0;}
{Relacion}{Espacio}{String}	{relacion(yytext);}
{Atributo}{Espacio}{String}{Espacio}{TipoDato}({Espacio}{FormatoFecha})?	{atributo(yytext);}
{Datos}	{comienzaLectura();}
{Numero}\,?	{compruebaSiToca('n');}
{String}\,?	{compruebaSiToca('s');}
{NominalEspecificacion}\,?	{compruebaSiToca('{');compruebaNominalCorrecto(yytext);}
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
	leyendoDatos = iterador_atributos = iteradorDatos = iteradorFecha = 0;

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

	if(nuevoAtributo[i] == 'd' || nuevoAtributo[i] == 'D') //DATE --- VEMOS QUE FORMATO SE HA USADO 1 o 2
	{
		while(nuevoAtributo[i] != '"') i++;
		i++;
		if(nuevoAtributo[i] == 'y')
			formatoFecha[iteradorFecha++] = 1;
		else 
			formatoFecha[iteradorFecha++] = 0;
		
	}
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
	atributos_nominales[iterador_atributos] = an;
	}


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
		printf("Error: Se esperaba %s y se ha recibido %s en linea %i\n",corresponde(tipo_atributo[iteradorDatos],0),corresponde(d,1),linea);
		exit(-1);
	}
	else
		iteradorDatos++;
}

void compruebaNominalCorrecto(char * cadena)
{
	unsigned c = 0;
	AtributosNominales an;an.nAtributos = 0;

	//QUITAMOS LA , final para poder comprobar bien
	if(cadena[strlen(cadena)-1] == ',')
		cadena[strlen(cadena)-1] = '\0';

	for(int i=0;i<MAX && c == 0;i++)
	{
		an = atributos_nominales[i];
		for(int j=0;j<an.nAtributos && c == 0;j++)
			if(!strcmp(an.nominalEspecificacion[j],cadena))
				c++;
	}

	if(c == 0)
	{
		printf("Error: Se ha recibido el atributo nominal %s NO reconocible en linea %i\n",cadena,linea);
		exit(-1);
	}
}

char * corresponde(char tipo,int i)
{
	if(tipo == '{')
		strcpy(correspondencia[i],"NOMINAL");
	else if (tipo == 'n' || tipo == 'N')
	{
		strcpy(correspondencia[i],"NUMERIC");
	}
	else if (tipo == 's' || tipo == 'S')
	{
		strcpy(correspondencia[i],"STRING");
	}

	return correspondencia[i];
}

