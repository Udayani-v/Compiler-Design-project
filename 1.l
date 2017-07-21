%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include <string.h>
#include "sym_table.h"
#define TYPE_COMMENT 0
#define TYPE_STRING_CONST 1
//#define TYPE_KEYWORD 2
#define TYPE_IDENTIFIER 2
#define TYPE_OPERATOR 3
#define TYPE_DIGIT 4
FILE *fd2;
void preload();
int line_number = 1;
int sym_table_length = 0;
int prev,prev2;
int p;
char* t;
char* o; 
int ftype=-1;
int next,next2;
int checkTable();
int getIndex(char* tyytext);
int compareValue(char* tyytext);
int getValue(char* tyytext);
int checkType(int g,char* tyytext);
void updateTable(char* tyytext);
sym_table table[100];
%}
%%
"#include" {return HINCLUDE;}
stdio.h|stdlib.h {return LIBNAME;}

; 	{ printf("SPECIAL_SYMBOL,%s\n",yytext);return SEMI;}
\{ 	{ installID(TYPE_OPERATOR, yytext); return CBO;}
\} 	{ installID(TYPE_OPERATOR, yytext);return CBC;}
\( 	{ printf("SPECIAL_SYMBOL,%s\n",yytext);installID(TYPE_OPERATOR, yytext); return SBO;}
\) 	{ installID(TYPE_OPERATOR, yytext);return SBC;}
\&  	{ printf("SPECIAL_SYMBOL,%s\n",yytext);return AMP;}

"int"		{ strcpy(yylval.string,yytext);ftype=1;printf("KEYWORD,%s\n",yytext);return INT;}
"float"		{ strcpy(yylval.string,yytext);ftype=2;printf("KEYWORD,%s\n",yytext);return FLOAT;}
"char"		{ strcpy(yylval.string,yytext);ftype=0;printf("KEYWORD,%s\n",yytext);return CHAR;}
"double"		{ strcpy(yylval.string,yytext);ftype=3;printf("KEYWORD,%s\n",yytext);return DOUBLE;}
"while"		{ printf("KEYWORD,%s\n",yytext);return WHILE;}
"else"          	{ printf("KEYWORD,%s\n",yytext);return ELSE;}
"if"		{  printf("KEYWORD,%s\n",yytext);return IF;}
"main"		{printf("IDENTIFIER,%s\n",yytext);return MAIN;}
"printf"		{strcpy(yylval.string,yytext);return PRINTF;}
"scanf"		{strcpy(yylval.string,yytext);return SCANF;}
, 		{ printf("KEYWORD,%s\n",yytext);return COMMA;}

\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/|\/\/.* {fprintf(yyout,"%s","");}
\".*\" {printf("in string\n"); strcpy(yylval.string,yytext);printf("STRING_CONSTANT,%s\n",yytext);/*fprintf(yyout,"%s",yytext);*/ installID(TYPE_STRING_CONST, yytext);return STRING;}
[a-zA-Z_][a-zA-Z0-9_]* {strcpy(yylval.string,yytext);printf("IDENTIFIER,%s\n",yytext);/*fprintf(yyout,"%s",yytext);/*printf(" : iden\n");*/installID(TYPE_IDENTIFIER, yytext); return ID;}
[0-9]+[.]?[0-9]* { strcpy(yylval.string,yytext);printf("NO_CONSTANT,%s\n",yytext);/*fprintf(yyout,"%s",yytext);*/installID(TYPE_DIGIT, yytext);return NUM;}

"++" 	{ installID(TYPE_OPERATOR, yytext); return INCOP;}
"+"	{ installID(TYPE_OPERATOR, yytext);return PLUS;}
"--"	{ installID(TYPE_OPERATOR, yytext);return DECOP;}
"*"     	{ installID(TYPE_OPERATOR, yytext);return MUL;}
"/"     	{ installID(TYPE_OPERATOR, yytext);return DIV;}
"-"	{ installID(TYPE_OPERATOR, yytext);return MINUS;}
"<"	{ installID(TYPE_OPERATOR, yytext); return LT;}
"<="	{ installID(TYPE_OPERATOR, yytext); return LEQ;}
">"	{ installID(TYPE_OPERATOR, yytext);return GT; }
">="	{ installID(TYPE_OPERATOR, yytext);return GEQ;}
"=="	{ installID(TYPE_OPERATOR, yytext);return DEQ;}
"="	{ installID(TYPE_OPERATOR, yytext);return EQ;}

\n 	{++line_number;}
. 	{/*fprintf(yyout,"%s",yytext);*/}
%%
int installID (int type, char* tmp_yytext)
{
	//ftype=-1;
	char* tmp=tmp_yytext;
	
switch (type) 
{
		case 1:
			 
                        		printf("\n");
			int found=checkTable(tmp);
			if(!found)
			{                      
                                                 strcpy (table[sym_table_length].n, "STRING CONSTANT");
			 strcpy (table[sym_table_length].name, "STRING CONSTANT");		
			 strcpy (table[sym_table_length].value, tmp_yytext);
			 table[sym_table_length].line_number = line_number;
			}
			else
			{
			      
                                                              printf("Already in symbol table \n");
			       //sym_table_length--;
 			}							 
			break;
		case 2:
 			//printf("Entered Identifier\n");
			//char *str;
			//str="IDENTIFIER"+yytext;
			found=checkTable(tmp);
			//printf("Found:%d\n",found);
			if(!found)
			{
			
                                                strcpy (table[sym_table_length].n, "IDENTIFIER");
			//For type we need to go one step behind and check if its a int|float|char|double|long.
			//tback=sym_table_length-1;
			if(ftype==0)
			{
				strcpy(table[sym_table_length].type,"char");
				//ftype=-1;	
			}
			else if(ftype==1)
			{
				strcpy(table[sym_table_length].type,"int");
				//ftype=-1;
			}
			else if(ftype==2)
			{
				strcpy(table[sym_table_length].type,"float");
				//ftype=-1;
			}
			else if(ftype==3)
			{
				strcpy(table[sym_table_length].type,"double");
				//ftype=-1;
			}
                        		strcpy (table[sym_table_length].n, "IDENTIFIER");
 			strcpy (table[sym_table_length].name, tmp_yytext);		
			strcpy (table[sym_table_length].value, "0");
			table[sym_table_length].line_number = line_number;
			//printf(" LINE NUMBER OF A IS:%d\n",table[sym_table_length].line_number);
			table[sym_table_length].index = sym_table_length;
			t=table[sym_table_length].name;
			//printf(" t is %s \n" , t);
			}
			else
			{             // printf("Already in symbol table\n"); 
				int i = getIndex(tmp);
				if(ftype==0)
			{
				strcpy(table[i].type,"char");
				//ftype=-1;	
			}
			else if(ftype==1)
			{
				strcpy(table[i].type,"int");
				printf("XOXOXOX :%s\n",table[i].type);
				//ftype=-1;
			}
			else if(ftype==2)
			{
				strcpy(table[i].type,"float");
				//ftype=-1;
			}
			else if(ftype==3)
			{
				strcpy(table[i].type,"double");
				//ftype=-1;
			}
                                
				t = table[i].name;
				table[i].line_number = line_number;
				//printf(" t is %s \n" , t);
                                		sym_table_length=sym_table_length-1;
                                 	}

			break;
		case 3:
			//printf("Entered operator VAL:%s\n",tmp); 
			if(strcmp(tmp_yytext,")")==0)
				printf("SPECIAL_SYMBOL,%s\n",tmp_yytext);
			else if(strcmp(tmp_yytext,"{")==0)
				printf("SPECIAL_SYMBOL,%s\n",tmp_yytext);
			else if(strcmp(tmp_yytext,"}")==0)
				printf("SPECIAL_SYMBOL,%s\n",tmp_yytext);
 			strcpy (table[sym_table_length].n, "OPERATOR");
			if(strcmp(tmp_yytext,"=")==0)
			{
			
			found=checkTable("AssignmentOp");
			//printf("Found:%d\n",found);
			if(!found)
			{
			//printf("inside = operator when not found\n");
			strcpy (table[sym_table_length].name, "AssignmentOp");		
			strcpy (table[sym_table_length].value, tmp_yytext);
			table[sym_table_length].line_number = line_number;
			o = table[sym_table_length].value;
			}
			else
			{
			//printf("inside = operator when  found\n");
			  int k = getIndex("AssignmentOp");
			    table[k].line_number = line_number;
			//printf("inside jdjhd %s \n" , table[k].value);
			    o = table[k].value;
			    sym_table_length=sym_table_length-1;
			}
			
			}
			else if(strcmp(tmp_yytext,"+")==0)
			{
			     found=checkTable("AdditionOp");
			   //printf("Found:%d\n",found);
			  if(!found)
		 	 {
			 	strcpy (table[sym_table_length].name, "AdditionOp");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
			}
			else
			{
			  	int k = getIndex("AdditionOp");
			 	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}
			else if(strcmp(tmp_yytext,"-")==0)
			{
				found=checkTable("SubtractionOp");
				if(!found)
				{
				strcpy (table[sym_table_length].name, "SubtractionOp");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
				}
			else
			{
			  	int k = getIndex("SubtractionOp");
			  	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}
			else if(strcmp(tmp_yytext,"*")==0)
			{
				found=checkTable("MultiplicationOp");
				if(!found)
				{
				strcpy (table[sym_table_length].name, "MultiplicationOp");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
			}
			else
			{
			 	int k = getIndex("MultiplicationOp");
				table[k].line_number = line_number;
			      	sym_table_length=sym_table_length-1;
			}
			o = " ";
			}

			else if(strcmp(tmp_yytext,"/")==0)
			{
				found=checkTable("DivisionOp");
				if(!found)
				{
				strcpy (table[sym_table_length].name, "DivisionOp");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
				}
			else
			{
			  	int k = getIndex("DivisionOp");
			  	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}
			else if(strcmp(tmp_yytext,"<")==0)
			{
				found=checkTable("LesserThanOp");
				if(!found)
				{
				strcpy (table[sym_table_length].name, "LesserThanOp");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
				}
			else
			{
			  	int k = getIndex("LesserThanOp");
			  	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}
			else if(strcmp(tmp_yytext,">")==0)
			{
				found=checkTable("GreaterThanOp");
				if(!found)
				{
				strcpy (table[sym_table_length].name, "GreaterThanOp");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
				}
			else
			{
			  	int k = getIndex("GreaterThanOp");
			  	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}
			else if(strcmp(tmp_yytext,">=")==0)
			{
				found=checkTable("GreaterThanEqOp");
				if(!found)
				{
				strcpy (table[sym_table_length].name, "GreaterThanEqOp");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
				}
			else
			{
			  	int k = getIndex("GreaterThanEqOp");
			  	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}
			else if(strcmp(tmp_yytext,"<=")==0)
			{
				found=checkTable("LesserThanWqOp");
				if(!found)
			{
				strcpy (table[sym_table_length].name, "LesserThanWqOp");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
			}
			else
			{
			  	int k = getIndex("LesserThanWqOp");
			  	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}
			else if(strcmp(tmp_yytext,"==")==0)
			{
				found=checkTable("DoubleEqualsOp");
				if(!found)
				{
				strcpy (table[sym_table_length].name, "DoubleEqualsOp");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
				}
			else
			{
			  	int k = getIndex("DoubleEqualsOp");
			  	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}
 			else if(strcmp(tmp_yytext,"&&")==0)
			{
				found=checkTable("AndOp");
				if(!found)
				{
				strcpy (table[sym_table_length].name, "AndOp");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
				}
			else
			{
			  	int k = getIndex("AndOp");
			  	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}
			else if(strcmp(tmp_yytext,"||")==0)
			{
				found=checkTable("OrOp");
				if(!found)
				{
				strcpy (table[sym_table_length].name, "OrOp");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
				}
			else
			{
			  	int k = getIndex("OrOp");
			  	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}
			else if(strcmp(tmp_yytext,"(")==0)
			{
				found=checkTable("OpeningParan");
				if(!found)
				{
				strcpy (table[sym_table_length].name, "OpeningParan");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
				}
			else
			{
			  	int k = getIndex("OpeningParan");
			  	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}
			else if(strcmp(tmp_yytext,")")==0)
			{
				found=checkTable("ClosingParan");
				if(!found)
				{
				strcpy (table[sym_table_length].name, "ClosingParan");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
				}
			else
			{
			  	int k = getIndex("ClosingParan");
			  	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}
			else if(strcmp(tmp_yytext,"{")==0)
			{
				found=checkTable("OpeningBrac");
				if(!found)
				{
				strcpy (table[sym_table_length].name, "OpeningBrac");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
				}
			else
			{
			  	int k = getIndex("OpeningBrac");
			  	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}
			else if(strcmp(tmp_yytext,"}")==0)
			{
				found=checkTable("ClosingBrac");
				if(!found)
				{
				strcpy (table[sym_table_length].name, "ClosingBrac");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
				}
			else
			{
			  	int k = getIndex("ClosingBrac");
			  	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}
			else if(strcmp(tmp_yytext,";")==0)
			{
				found=checkTable("Semicolon");
				if(!found)
				{
				strcpy (table[sym_table_length].name, "Semicolon");		
				strcpy (table[sym_table_length].value, tmp_yytext);
				table[sym_table_length].line_number = line_number;
				}
			else
			{
			  	int k = getIndex("Semicolon");
			  	table[k].line_number = line_number;
				sym_table_length=sym_table_length-1;
			}
			o = " ";
			}

			break;
	case 4:
                       //printf("Entered Digit\n");
			printf("Entered Digit\n");
			//printf("tmp is %s \n" ,tmp_yytext);
			int k = compareValue(tmp_yytext);
			if(!k)
			{
			strcpy (table[sym_table_length].n, "DIGIT");
			strcpy (table[sym_table_length].name, "DIGIT");	
	                
			strcpy (table[sym_table_length].value, tmp_yytext);
                        		
			table[sym_table_length].line_number = line_number;
			updateTable(tmp_yytext);
			}
			else
			{
			printf("Already in sym table\n");
			int l = getValue(tmp_yytext);
                        		 table[l].line_number = line_number; 
			//sym_table_length=sym_table_length-1;    
			updateTable(tmp_yytext);   
			sym_table_length=sym_table_length-1;
			}			
			break;
}
sym_table_length++;
}

int checkType(int ind,char*tyytext)
{ 	int i=0;
	//printf("Type is:%s\n",table[ind].type);
	//printf("Type checking entered:\n");
	int tmp=atoi(tyytext);
	//printf("Converted Value is:%d\n",tmp);
	int num=tmp;
	int lenc=0;
	int count=0;

	if(strcmp(table[ind].type,"int")==0)
	{
		for(i=0;i<yyleng;i++)
		{
					if(yytext[i]=='.')
					{
						printf("Error in float\n");
						return 1;
					}
					else
					{
						while(tmp!=0)
						{	
							int d=tmp%10;
							if(d>=0&&d<=9)
							{
								lenc++;
							}
							tmp=tmp/10;
							count++;
						}
						if(lenc==count)
						{
							//printf("Hi\n");	
				
						}
						else
							printf("Error in string\n");				

					}
		}
	   	
	}
	return 0;
     
}

/**int main(int argc, char *argv[10])
{
	line_number = 1;
	preload();
	yyin = fopen(argv[1],"r");
	yyout = fopen(argv[2],"w");
	//{ fprintf(myfd, "%s: is a verb", yytext); }
	yylex();
	fclose(yyout);

	//int i;
	
	return 0;

}*/

void printSymbol()
{
  	int i;
	printf("Sr. num\tIdentification\tType\tName\t\tValue\tLine number");
	printf("\n");
	for (i = 0; i < sym_table_length;++i) 
         	{
               
                if(strcmp(table[i].n,"KEYWORD")==0)
                                {
                                 printf("%d\t%s\t\t%s\t%s\t\t%s\t%s",(i+1),table[i].n,"-",table[i].name, table[i].value,"-" );
		printf("\n");
               	}
		else
                                {
                               printf("%d\t%s\t%s\t%s\t%s\t%d",(i+1),table[i].n,table[i].type,table[i].name, table[i].value,table[i].line_number);
		printf("\n");
                                 }
	}	
}

int yywrap()
{
return 1;
}
int checkTable(char* tyytext)
{
        int i;
        int f=0;
	for(i=0;i<=sym_table_length;i++)
	{
		// printf("IN Check:%s %s\n",tyytext,table[i].name);
		if(strcmp(table[i].name,tyytext)==0 )
                   {
                     	f=1;
		next = i;
		//printf("LALALAL%s %s %s \n" ,table[i].n , table[i].name , table[i].value);
                return f;
		
                   }
	}
	return f;

}

void updateTable(char* tyytext)
{
  
  			//printf("t is %s\n" , t);
			//printf("After difigit \n");
			int j = getIndex(t);
                       	//printf("j and o value is %d %s \n" , j , o);
			if(strcmp(o , "=")==0)
			{		
			      //printf("inside checking ====\n");	
                           if(strcmp(table[j].n,"IDENTIFIER")==0)
			   {
                          
			    //printf("p  %d  %s\n" , j , table[j].name); 
			  if(checkTable(table[j].name))
			  {
                           // printf("called checkTable");
			
                              //  printf("index is %d\n" , j);
				//printf("called Update Table-Now performing checking\n");
			        //printf("TYPE IN CONDITION:%s\n",table[j].type);
                              //  printf("index is %d\n" , j);
				
                        	int g = table[j].index ;
				//int k = table[p-1].index ;
				//If the token is found.
				int l=checkType(g,tyytext);
				if(l==0)
					strcpy (table[g].value, tyytext);

                             	else if(l==1)
					strcpy (table[g].value, "0");
                           
                                                 }
		          }
		}
			
		else
		        {      
                       if(strcmp(o , "=")==0)
			{
                           if(strcmp(table[j].n,"IDENTIFIER")==0)
			   {
			     //int k = table[p].index ;
                             // printf("k value is %d\n" , k);
			     //printf("called else of Update Table\n");
				int l=checkType(j,tyytext);
				if(l==0)
					strcpy (table[j].value, tyytext);

                             	else if(l==1)
					strcpy (table[j].value, "0");

                               		  
			   }                                    
		        }
		    }

}

int getIndex(char* tyytext)
{
        int j;
        int ind=0;
	for(j=0;j<sym_table_length;j++)
	{
		// printf("IN Check:%s %s\n",tyytext,table[j].name);
		if(strcmp(table[j].name,tyytext)==0 )
                   {
                    	      ind=j;
		 //  printf(" ind valur %d \n" , ind);
                   return ind;
			//printf("%s %s %s " ,table[j].n , table[j].name , table[j].value);
                   }
	}
	return ind;
}

int getValue(char* tyytext)
{
        int j;
        int ind=0;
	for(j=0;j<sym_table_length;j++)
	{
		//printf("IN Check:%s %s\n",tyytext,table[j].value);
		if(strcmp(table[j].value,tyytext)==0 )
                   {
                    ind=j;
		 //  printf(" ind valur %d \n" , ind);
                    	return ind;
			//printf("%s %s %s " ,table[j].n , table[j].name , table[j].value);
                   }
	}
	return ind;

}

int compareValue(char* tyytext)
{
     int i;
        int f=0;
	for(i=0;i<=sym_table_length;i++)
	{
		 //printf("IN Check:%s %s\n",tyytext,table[i].value);
		if(strcmp(table[i].value,tyytext)==0 )
                   {
                    	        f=1;
		        next = i;
                    return f;
		    //  printf("%s %s %s " ,table[i].n , table[i].name , table[i].value);
                   }
	}
	return f;
}

void preload()
{
  int i=0;
  char res[11][10]={"if","else","for","while","do","switch","break","extern","long","char","int"};
  for(int i=0;i<11;i++)
  {
      strcpy (table[sym_table_length].n, "KEYWORD");
      strcpy (table[sym_table_length].name,res[i]);		
      strcpy (table[sym_table_length].value, res[i]);
      sym_table_length++;
  }
}

