%option case-insensitive

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include "token.h"

#define MAX_LENGTH 1000

char s[MAX_LENGTH];
int isvar[MAX_LENGTH];
int string_index=0;
	
extern int yycolumn, yylength, yyline;
int yylval;

void ReportError(const char*);
int idexists();

%}

/* regular definitions */

letter			[a-zA-Z]
digit			[0-9]
id				{letter}[a-zA-Z0-9]*
wrongid			{digit}+{letter}+.*
iconst			{digit}+
newline			[\n]
delim			[ \t]
ws				{delim}+
sconst			'[^'\n]*'
wrongstr		'[^'\n]*

%x C_COMMENT

%%

"/*"	       		{BEGIN(C_COMMENT);}
<C_COMMENT>"*/" 	{yycolumn+=yyleng;BEGIN(INITIAL);}
<C_COMMENT>.		{yycolumn+=yyleng;}
<C_COMMENT>\n		{yyline++;yycolumn = 0;}
<C_COMMENT><<EOF>>	{ReportError("Not ending comment");yyterminate();}


declarations		{yycolumn+=yyleng;return DECLARATIONSnum;}
enddeclarations		{yycolumn+=yyleng;return ENDDECLARATIONSnum;}
method				{yycolumn+=yyleng;return METHODnum;}
program				{yycolumn+=yyleng;return PROGRAMnum;}
int					{yycolumn+=yyleng;return INTnum;}
val					{yycolumn+=yyleng;return VALnum;}
else				{yycolumn+=yyleng;return ELSEnum;}
while				{yycolumn+=yyleng;return WHILEnum;}
class				{yycolumn+=yyleng;return CLASSnum;}
if					{yycolumn+=yyleng;return IFnum;}
return				{yycolumn+=yyleng;return RETURNnum;}
void				{yycolumn+=yyleng;return VOIDnum;}
"&&"       			{yycolumn+=yyleng;return ANDnum;}
":="				{yycolumn+=yyleng;return ASSGNnum;}
"."					{yycolumn+=yyleng;return DOTnum;}
"="					{yycolumn+=yyleng;return EQUALnum;}
">"					{yycolumn+=yyleng;return GTnum;}
"["					{yycolumn+=yyleng;return LBRACnum;}
"("					{yycolumn+=yyleng;return LPARENnum;}
"!="				{yycolumn+=yyleng;return NEnum;}
"||"				{yycolumn+=yyleng;return ORnum;}
"]"					{yycolumn+=yyleng;return RBRACnum;}
")"					{yycolumn+=yyleng;return RPARENnum;}
";"					{yycolumn+=yyleng;return SEMInum;}
","					{yycolumn+=yyleng;return COMMAnum;}
"/"					{yycolumn+=yyleng;return DIVIDEnum;}
"=="				{yycolumn+=yyleng;return EQnum;}
">="				{yycolumn+=yyleng;return GEnum;}
"{"					{yycolumn+=yyleng;return LBRACEnum;}
"}"					{yycolumn+=yyleng;return RBRACEnum;}
"<="				{yycolumn+=yyleng;return LEnum;}
"<"					{yycolumn+=yyleng;return LTnum;}
"-"					{yycolumn+=yyleng;return MINUSnum;}
"!"					{yycolumn+=yyleng;return NOTnum;}
"+"					{yycolumn+=yyleng;return PLUSnum;}
"*"					{yycolumn+=yyleng;return TIMESnum;}
"\t"				{yycolumn+=1;}
"\\"				{yycolumn+=1;}
"\'"				{yycolumn+=1;}
{id}				{
					 yycolumn+=yyleng;
					 int x = idexists();
					 if(x!=-1)
					 {
					 	yylval = x;
					 	return IDnum;
					 }
                     yylval=string_index;
                     isvar[string_index]=1;
					 strcpy(s+string_index,yytext);
					 string_index+=strlen(yytext)+1;
					 return IDnum;
					}
{wrongid}			{ReportError("Wrong id!");}
{iconst}			{yylval=atoi(yytext); yycolumn+=yyleng; return ICONSTnum;}
{sconst}			{
					 if(string_index>MAX_LENGTH-1-strlen(yytext)){ReportError("String Table Full!");}
                     if(strlen(yytext)>MAX_LENGTH-1){ReportError("String Too Long!");}
                     //printf("!!! %s !!!\n",yytext);
                     yylval=string_index;
                     isvar[string_index]=0;
					 strcpy(s+string_index,yytext+1); /* Eliminate the left ' */
					 string_index+=strlen(yytext)-1; 
					 s[string_index-1]='\0'; /* Eliminate the right ' */
					 return SCONSTnum;
					}
{wrongstr}			{ReportError("Wrong string!");}
{newline}			{yycolumn=0; yyline++;}
{ws}				{yycolumn+=yyleng;}
.					{yycolumn += yyleng;ReportError("Wrong character!");}
 

%%

int yyline = 1;
int yycolumn = 0;


void ReportError(const char *a)
{
	printf("Line %d, Column %d: %s\n",yyline,yycolumn,a);
}

int idexists()
{
	int i;
	for(i=0;i<string_index;i+=strlen(s+i)+1)
	{
		if(strcasecmp(s+i,yytext)==0 && isvar[i]==1)
		{
			return i;
		}
	}
	return -1;
}

char* namearray[40]={"ANDnum", "ASSGNnum", "DECLARATIONSnum", "DOTnum", "ENDDECLARATIONSnum", "EQUALnum", "GTnum", "IDnum", "INTnum", "LBRACnum", "LPARENnum", "METHODnum",
		     "NEnum", "ORnum", "PROGRAMnum", "RBRACnum", "RPARENnum", "SEMInum", "VALnum", "WHILEnum", "CLASSnum", "COMMAnum", "DIVIDEnum", "ELSEnum", "EQnum",
		     "GEnum", "ICONSTnum", "IFnum", "LBRACEnum", "LEnum", "LTnum", "MINUSnum", "NOTnum", "PLUSnum", "RBRACEnum", "RETURNnum", "SCONSTnum", "TIMESnum",
		     "VOIDnum", "EOFnum"};

int main()
{
	printf("The output of Lexical Analyzer\n");
	printf("Line\tColumn\tToken\t\tIndex_in_String_table\n");

	int lexReturn;
	do
	{
		lexReturn = yylex(); // fetch a new token
		switch(lexReturn)
		{
			case EOFnum: printf("\t\tEOFnum\t\n"); continue;
			case IDnum: case ICONSTnum: case SCONSTnum: printf("%d\t%d\t%s\t\t%d\n", yyline, yycolumn, namearray[lexReturn-257], yylval); continue;
			default: printf("%d\t%d\t%s\n", yyline, yycolumn, namearray[lexReturn-257]);
		}
	} while (lexReturn != 0);
	
	printf("String Table: ");
	int i;
	for(i=0;i<string_index;i+=strlen(s+i)+1)
	{
		printf("(%d)",i);
		printf("%s ",s+i);
	}
	printf("\n");
	return 0;
}
