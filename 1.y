%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sym_table.h"
int yylex(void);
void printSymbol(void) ;
void preload();
extern int yylineno,yychar;
extern int sym_table_length;
char *errno;
extern int line_number;
void yyerror(char* s);
void set_type(char []);
void add_id(char []);
void check_type(char [], int );
int eval (char [] , char [] , int);
int getIn(char []);
int getL(char []);
int sym[26];
FILE *yyin;
char c[10];
int temp_var=0;
int Index=0;
int sym_cnt=0;
void addQuadruple(char [],char [],char [],char []);
void display_Quadruple();
void push(char*);
char* pop();


extern sym_table table[];
 
struct Quadruple
{
    char operator[5];
    char operand1[10];
    char operand2[10];
    char result[10];
}QUAD[25];

struct Stack
{
    char *items[10];
    int top;
}Stk;

%}
%token HINCLUDE LIBNAME IF THEN LT LEQ GEQ DEQ GT EQ NE OR AND ELSE SEMI CBO CBC SBO SBC COMMA INT MAIN  AMP WHILE INCOP PLUS DECOP MINUS CHAR DOUBLE FLOAT OCB MUL DIV PRINTF SCANF 
%union
{
	//int index1;
	//int typeval;
	int ival;
	int dval;
	char  string[10];
}
%token <string> STRING
%token <string> ID
%token <string> NUM
%type <string> type
%type <string> E
%type <string> pstmt

%right EQ
%left PLUS MINUS
%left MUL DIV
%nonassoc IF  
%nonassoc ELSE 
%left '<' '>' LT GT NE
%left AND OR
%right UMINUS
%left '!'

%%
start: header  main ;
 	
header: HINCLUDE LT LIBNAME GT ;

main:INT MAIN SBO SBC CBO body 			{errno="NO_M_RCBRACE";printf("Syntax error:Missing Right brace\n");} 
         |INT MAIN SBO SBC CBO body CBC 		{/*printf("after main");*/}
         ; 

body: stmt T   
          ;

T: body 
  |
  ;
	
ST: 	IF SBO E2 SBC CBO body CBC %prec IF 	    {printf("Input Accepted-111\n");}
	|IF SBO E2 SBC CBO body %prec IF 	    	    {errno="NO_RCBRACE";}
	||IF E2 SBC CBO body CBC %prec IF 	    	    {errno="NO_LPARAN";printf("Syntax error:Missing left paranthesis\n");}
	|IF SBO E2 SBC CBO body  CBC ELSE CBO body CBC {printf("Input Accepted-222\n");}
	|IF SBO E2 SBC CBO body ELSE body		    {errno="NO_RCBRACE";printf("Input Accepted-333\n");}
	|IF SBO E2 SBC E  %prec IF			    {printf("Input Accepted-444.\n");}
	|IF SBO E2 SBC E ELSE CBO body  CBC	                    {printf("Input Accepted-555\n");}
	|IF SBO E2 SBC CBO body CBC ELSE E 		    {printf("Input Accepted-666\n");}
	;  

E :ID EQ E        	{       char *s=pop();
	      		//printf("THE POPPPEDD ELEMETNJKEFUh IS:%s",s)
	            		addQuadruple("=","",s,$1);
	      		//printf("\nID === E %s %s  \n" , $1 , $3);
              		int g = getIn($1);
	      		//printf("GGGGGGGGGGGGG is %d %s  \n" ,g , table[g].name); 
                            		strcpy(table[g].value , $3); 
	    	} 
      /*|ID EQ ID          {addQuadruple("=","",$3,$1);int g = getIn($1);int g1=getIn($3);strcpy(table[g].value ,table[g1].value); }*/
      |ID EQ NUM      { {add_id($1);} char temp[10];snprintf(temp,"%d",$3);addQuadruple("=","",temp,$1);}
      |  E PLUS E        { //printf("\nE + E values are  %s %s %s \n" ,$$ , $1 , $3);
		       char * a = pop(); 
		       char * b = pop();
		              strcpy($1,a);strcpy($3 , b);
		       int out = eval($1,$3,1); char r[10];
		              sprintf(r , "%d" , out);
		       //int g = getIn($$);
		       // printf("GGGGGGGGGGGGG is %d %s  \n" ,g , table[g].name); 
                       // strcpy(table[g].value , r); 
		              strcpy($$ , r);  
		       //printf("$$ VALUE IS %s \n" , $$); 
		       char str[5],str1[5]="t";sprintf(str,"%d",temp_var);strcat(str1,str);temp_var++;
		              addQuadruple("+",a,b,str1);
		              push(str1);
               }
      | E MINUS E     {    	//printf("\nE - E values are  %s %s %s \n" ,$$ , $1 , $3);
			//char str[5],str1[5]="t";
			char * a = pop();
			char * b = pop();
		       	strcpy($1,a);strcpy($3 , b);
			int out = eval($1,$3,2); 
			char r[10];
		       	sprintf(r , "%d" , out);
		        //int g = getIn($$);
		        // printf("GGGGGGGGGGGGG is %d %s  \n" ,g , table[g].name); 
                        // strcpy(table[g].value , r); 
		       	strcpy($$ , r);  
		       	//printf("$$ VALUE IS %s \n" , $$); 
		       	char str[5],str1[5]="t";sprintf(str,"%d",temp_var);strcat(str1,str);temp_var++;
		       	addQuadruple("-",a,b,str1);
			push(str1);
		}
      | E MUL E           {
                        //printf("\nE * E values are  %s %s %s \n" ,$$ , $1 , $3);
			//char str[5],str1[5]="t";
			char * a = pop(); 
			char * b = pop();
		                strcpy($1,a);
			strcpy($3 , b);
			int out = eval($1,$3,3); char r[10];
		       	sprintf(r , "%d" , out);
		        //int g = getIn($$);
		        //printf("GGGGGGGGGGGGG is %d %s  \n" ,g , table[g].name); 
                        //strcpy(table[g].value , r); 
		                strcpy($$ , r);  
		        //printf("$$ VALUE IS %s \n" , $$); 
		        char str[5],str1[5]="t";sprintf(str,"%d",temp_var);strcat(str1,str);temp_var++;
		                 addQuadruple("*",a,b,str1);
		                 push(str1);
		}
      | E DIV E             {
			//printf("\nE / E values are  %s %s %s \n" ,$$ , $1 , $3);
			//char str[5],str1[5]="t";
			char * a = pop(); 
			char * b = pop();
		      	 strcpy($1,a);strcpy($3 , b);
			int out = eval($1,$3,4); char r[10];
		      	sprintf(r , "%d" , out);
		       	//int g = getIn($$);
		       	//printf("GGGGGGGGGGGGG is %d %s  \n" ,g , table[g].name); 
                       	//strcpy(table[g].value , r); 
		              	strcpy($$ , r);  
		       	//printf("$$ VALUE IS %s \n" , $$); 
		       	char str[5],str1[5]="t";sprintf(str,"%d",temp_var);strcat(str1,str);temp_var++;
		              	addQuadruple("/",a,b,str1);
			push(str1);
		}
      |NUM          	{
		strcpy($$ , $1); 
		//printf("in num of yacc %s  \n", $1);
		char temp[10];
		snprintf(temp,10,"%s",$1);
		push(temp);
	    	}
      |ID  { {add_id($1);}//printf("in ID checking %s %s \n" , $$ , $1);strcpy($$ , $1);//add_id($1);$$=atoi(table[$1-1].value);printf("id for check %d  value %d  table %s\n" , $$, $1-1 ,table[$1-1].name );
	 push($1);
	//printf("\nThe value of $1 is:%s",$1);
      }    
      |SEMI                  
      ;

stmt: decl SEMI	
        |pstmt SEMI
        |pstmt  {errno="NO_SEMI";printf("Syntax Error:Missing Semi-Colon\n");} 
        |ST 
        |E   {/*printf("WOOOOOHO  %s \n" , $1);*/}
         ;

pstmt:PRINTF SBO STRING COMMA ID SBC  {//printf("IN PRINTF $3 , $5 %s %s \n",$3 ,$5);
      			int g = getIn($5);
            		//printf("in is !!!!!!!!!!!!!!!!!!!! %d \n " , g);
            			check_type($3, g);
            		//printf("in printf\n");
				    }
    //     |PRINTF SBO STRING SBC
         ;

decl : type names {set_type($1);}; 
      
type : INT{strcpy($$,"0");}|FLOAT{strcpy($$,"1");}|DOUBLE{strcpy($$,"2");}|CHAR{strcpy($$,"3");};
        
names : E COMMA E | E
    ;    
E2  : E LT E
     | E GT E    {/*printf("ENTERED GT\n");*/}
     | E LEQ E
     | E GEQ E
     | E NE E
     | E OR E
     | E AND E
     | E DEQ E   {/*printf("ENTERED DEQ\n");*/}
     |"true"
     |"false"
     ;     
%%

void display_Quadruple()
{
 int i;
  printf("\n\nINTERMEDIATE CODE GENERATION: \n");
  printf("\n\t\tQUADRUPLE TABLE\n");
  printf("\nSl.No   Result     Operator     Operand1      Operand2  ");
  for(i=0;i<Index;i++)
    printf("\n %d       %s          %s          %s              %s",i,QUAD[i].result,QUAD[i].operator,QUAD[i].operand1,QUAD[i].operand2);
}

void push(char *str)
{
   Stk.top++;
   Stk.items[Stk.top]=(char *)malloc(strlen(str)+1);
   strcpy(Stk.items[Stk.top],str);
}

char * pop()
{
  int i;
  if(Stk.top==-1)
    {
     printf("\nStack Empty!! \n");
     exit(0);
    }
  char *str=(char *)malloc(strlen(Stk.items[Stk.top])+1);;
    strcpy(str,Stk.items[Stk.top]);
    Stk.top--;
  return(str);
}

void addQuadruple(char op[10],char op2[10],char op1[10],char res[10])
{
                                        strcpy(QUAD[Index].operator,op);
		    //printf("THE VALUE OF OPERAND 1 IS:%s",op1);
                                        strcpy(QUAD[Index].operand2,op2);
                                        strcpy(QUAD[Index].operand1,op1);
                                        strcpy(QUAD[Index].result,res);
                    	        Index++;
}

int eval(char * a , char * b , int t)
{
 // printf("In EVAL\n");
  int i , j , t1 , t2 , n , m;
  //char r[10] ;
   for(i=0 ; i < sym_table_length ; i++)
  {
    //printf("table[i].value %s %s \n" , table[i].value , a);
    if(strcmp(table[i].value,a)==0)
      {
    //   printf("okokook\n");
               t1=i;
       break;
      }
 }
   for(i=0 ; i < sym_table_length ; i++)
  {
    //printf("table[i].value %s %s \n" , table[i].name, b);
    if(strcmp(table[i].name,b)==0)
   {
     //  printf("okokook\n");
              t2=i;
       break;
   }

 }
       n = atoi(table[t1].value);
       m = atoi(table[t2].value);
   // printf("the value of N M are %d %d " , n , m );
  switch(t)
  {
    int res;
     case 1: res = n + m ;
             return res;
	     break;
  
     case 2: res = m - n ;
             return res;
	     break;
	
     case 3: res = m * n ;
             return res;
	     break;
 
     case 4: res = m / n ;
             return res;
	     break;
  }

}

int getIn(char q [])
{    int p ;
    //printf("IN GETIN WITH PARAM:%s\n",q);
    for(int i=0 ; i < sym_table_length ; i++)
  {
   // printf("table[i].value %s %s \n" , table[i].name, q);
    if(strcmp(table[i].name,q)==0)
   {
      // printf("okokook\n");
      //printf("UYEAA WE FOUND %s \n " , table[i].name);
        return i;
   }

   }
  return 0;
}


int getL(char q [])
{
    int p ;
    //printf("IN GETIN WITH PARAM:%s\n",q);
    for(int i=0 ; i < sym_table_length ; i++)
  {
   // printf("table[i].value %s %s \n" , table[i].name, q);
    if(strcmp(table[i].value,q)==0)
   {
      // printf("okokook\n");
      //printf("UYEAA WE FOUND %s \n " , table[i].name);
        return i;
   }

   }
  return 0;
}


int iDs[1024];
int iDIndex=0;

void add_id(char * s)
{
        int y = atoi(s);
	iDs[iDIndex] = y;
	iDIndex++;
    	//printf("in add %d %d \n",iDs[iDIndex], iDIndex);
}


void set_type(char *type)
{
	//printf("setting type:%d\n", type);
	int i;
	
	for (i=0; i < iDIndex; i++)
	 {
              	// int y = atoi(iDs[i]);
		strcpy(table[iDs[i]].type , type);
		//printf("in set id y table[y] %d %d %s \n" , iDs[i] , i , table[iDs[i]].type); 
	}
	iDIndex=0;
}

void check_type(char * x, int g)
{
	//printf("%d %d\n", s_id, i_id);
        //printf("IN CHECK _TYPE \n");
        int l = getL(x);
        //printf("THE LINE NUMBER IS %d , %s \n" , l,table[l].value); 
        //printf("THE VALUES OF arg1 , arg2 ARE %s %d \n" , x , g);
	//printf("%d %d\n", s_id, i_id);
	//printf("table[g].type %s \n", table[g].type);
        //printf("IN checkingggggg %d %d \n" , strcmp(table[g].type ,"int") , (strcmp("\"%d\"", x)));
	if(strcmp("\"%d\"", x) == 0) 
	{
		if((strcmp(table[g].type , "int"))!=0) 
	{
                //printf("IN TESTINGGGGGGGGG table[g].type %s , %s \n" , table[g].type , x);
		printf("Expecting %%d but got %s at line %d\n", table[g].type, table[l].line_number);
		//exit(-1);
	}
        else
	{
                 return;
	}
	}
        // printf("IN checkingggggg1111111111 %d %d \n" , strcmp(table[g].type ,"float") , (strcmp("\"%d\"", x)));
	if (strcmp("\"%f\"", x) ==0)
	{
		if((strcmp(table[g].type , "float"))!=0) 
	{
                //printf("IN TESTINGGGGGGGGG float table[g].type %s , %s \n" , table[g].type , x);
		printf("Expecting %%f but got %s at line %d\n", table[g].type , table[l].line_number);
		//exit(-1);
	}
	else	
	{ return; }
	}

	if (strcmp("\"%e\"", x) == 0)
	{
		if((strcmp(table[g].type , "double"))!=0)
	{
		printf("expecting %%e but got %s at line %d\n", table[g].type, table[l].line_number);
		//exit(-1);
	}
	else	
	{return ;}
	}

	if (strcmp("\"%s\"", x) == 0)
	{
		if((strcmp(table[g].type , "char"))!=0)
	{
		printf("expecting %%s but got %s at line %d\n", table[g].type, table[l].line_number);
		//exit(-1);
	}
	else
	{return ;}
	}
}

int main()
{
 	// printf("Enter the exp: ");
                line_number=1;
	//printf("TOKENS GENERATED\n");
	//printf("****************\n");
   	yyin=fopen("labin.txt","r");
 	preload();
  	yyparse();
	Stk.top=-1;
	//printf("comingn here\n ");  
	//printf("\n\t\t\t\tSYMBOL TABLE\n");
	for(int i=0;i<80;i++)
	{printf("*");}
	printf("\n");
	//printSymbol();
	
	//printf("and here\n");
       	//printf("\nSuccessfully parsed the given program\n");
        for(int i=0;i<60;i++)
	{printf("*");}
	printf("\n\n");
	display_Quadruple();
 	printf("\n\n");
        return 0;
}

void yyerror(char *s)
{
	
	//printf("Called YYEROR WITH ERRNO:%s\n",errno);
	//fprintf(stderr, "line %d: %s\n", line_number-1, s);
	if(errno=="NO_RCBRACE")
	{
                    printf("SYNTAX ERROR:Missing Right Brace\n");
	}
	if(errno=="NO_LPARAN")
	{
                    printf("SYNTAX ERROR:Missing Left paranthesis\n");
	}
	else if(errno=="NO_SEMI")
	{
                    printf("SYNTAX ERROR:Missing Semicolon\n");
	}
	else if(errno=="NO_M_RCBRACE")
	{
                    printf("SYNTAX ERROR:Missing Right Brace of Main function \n");
	}
}


        
