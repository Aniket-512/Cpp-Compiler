%{
#include<stdio.h>
#include<stdlib.h>
#include"structs.h"
#include<string.h>
#include<stdarg.h>
//#include "y.tab.h"
nodeType *oper(char opr);
nodeType *id(value val,char* name,typeEnum type);
nodeType *key(char* keyword);
nodeType** symbolTable;
int yyerror(char *msg);
int end=0;
nodeType* check_symbol_table(char *a,nodeType** symTable ,int end);
void print_symbol_table(nodeType** symTable, int end);
value* createValueUnion(typeEnum type);
void declare(typeEnum type,char* idName,value* newVal,nodeType** symbolTable);
extern int yylineno;
extern char *yytext;
node *mknode(char *token); 
void printTree(node* parent);
void insertChildren(struct node* parent,int no_children, ...);
char* inttostring(int a);
#define YYDEBUG_LEXER_TEXT yytext
#define mal (node*)malloc(sizeof(node))

%}

%union{
struct node *nd;	
}


%token  HEADER1 HEADER2 HEADER3 DO WHILE SWITCH CASE DEFAULT BREAK ID arrayID STRING NUM LE NE GE EQ OR AND unN unP cout openOut cin openIn initInt initChar initFloat initDouble CHARACTER

%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'

%%
//Change check and print funcitons for symbol table
//change union int value to a different datatype that can store all values
S:	
	START DECLARE2 LOOP END 
{
		$<nd>$ = (node*)malloc(sizeof(node));
		//$<nd>2 = (node*)malloc(sizeof(node));
		//$<nd>3 = (node*)malloc(sizeof(node));
		$<nd->token>$ = strdup("S");
		//$<nd->token>2 = strdup("DECLARE2");
		//$<nd->token>3= strdup("LOOP");
		$<nd->token>4 = strdup("END");
		$<nd->arrayEnd>4 = -1;
		insertChildren($<nd>$,4,$<nd>1,$<nd>2,$<nd>3,$<nd>4);

		printf("do-while statement\n");
		printf("\n\nSymbol Table:**********************************\n");
		print_symbol_table(symbolTable, end);
		printf("\n\n\n\n\n");
		printTree($<nd>$);
		printf("\n\n\n\n\n");
		exit(0);
	}; 

	| START DECLARE2 BODY END 
	{
		$<nd>$ = (node*)malloc(sizeof(node));
		$<nd->token>$ = strdup("S");

		//$<nd>2 = (node*)malloc(sizeof(node));
		//$<nd>3 = (node*)malloc(sizeof(node));
		//$<nd->token>2 = strdup("DECLARE2");
		$<nd->token>3= strdup("BODY");
		$<nd->token>4 = strdup("END");
		$<nd->arrayEnd>4 = -1;
		insertChildren($<nd>$,4,$<nd>1,$<nd>2,$<nd>3,$<nd>4);


		printf("Switch statement\n");
		printf("\n\nSymbol Table:**********************************\n");
		print_symbol_table(symbolTable, end); 
		printf("\n\n\n\n\n");
		printTree($<nd>$);
		printf("\n\n\n\n\n");
		exit(0);
	};
START:	
	HEADER1 HEADER2 DECLARE2 HEADER3'{' 
	{
	$<nd>$ = (node*)malloc(sizeof(node));
	$<nd->token>$ = strdup("START");

	$<nd>1 = (node*)malloc(sizeof(node));
	$<nd>2 = (node*)malloc(sizeof(node));
	$<nd>3 = (node*)malloc(sizeof(node));
	$<nd>4 = (node*)malloc(sizeof(node));
	$<nd->token>1 = strdup("HEADER1");
	$<nd->token>2 = strdup("HEADER2");
	$<nd->token>3 = strdup("DECLARE2");
	$<nd->token>4 = strdup("HEADER3");
	//$<nd->arrayEnd>2 = -1;
	//$<nd->arrayEnd>3 = -1;
	//$<nd->arrayEnd>4 = -1;
	insertChildren($<nd>$,4,$<nd>1,$<nd>2,$<nd>3,$<nd>4);
	}

	
	| HEADER1 DECLARE2 HEADER3'{' 
	{
	$<nd>$ = (node*)malloc(sizeof(node));
	$<nd->token>$ = strdup("START");
	$<nd>1 = (node*)malloc(sizeof(node));
	//$<nd>2 = (node*)malloc(sizeof(node));
	$<nd>3 = (node*)malloc(sizeof(node));
	$<nd->token>1 = strdup("HEADER1");
	//$<nd->token>2 = strdup("DECLARE2");
	$<nd->token>3= strdup("HEADER3");
	//$<nd->arrayEnd>2 = -1;
	//$<nd->arrayEnd>3 = -1;
	insertChildren($<nd>$,3,$<nd>1,$<nd>2,$<nd>3);
	}

LOOP:	
	DO '{' E '}' WHILE '(' COND ')' ';'
	{
		$<nd>$ = mal;
		$<nd->token>$ = strdup("LOOP");
		$<nd>1 = mal;
		$<nd->token>1 = strdup("DO");
		$<nd->arrayEnd>1 = -1;
		$<nd>5 = mal;
		$<nd->token>5 = strdup("WHILE");
		$<nd->arrayEnd>5 = -1;

		insertChildren($<nd>$,4,$<nd>1,$<nd>3,$<nd>5,$<nd>7);
		printf("\n\nTOOOOK %s %d\n\n",$<nd->token>7,$<nd->arrayEnd>$);
	};
BODY: 
	SWITCH '(' T ')' '{' CASES '}'
	{
		$<nd>$ = mal;
		$<nd->token>$ = strdup("BODY");
		$<nd>1 = mal;
		$<nd->token>1 = strdup("SWITCH");
		$<nd->arrayEnd>1 = -1;
		

		insertChildren($<nd>$,3,$<nd>1,$<nd>3,$<nd>6);
		printf("\n\nTOOOOK %s %d\n\n",$<nd->token>7,$<nd->arrayEnd>$);

	};
CASES: 
	CASE T ':' E {
		$<nd>$ = mal;
		$<nd->token>$ = strdup("CASES");
		$<nd>1 =  mal;
		$<nd->token>1 = strdup("CASE");
		$<nd->arrayEnd>1 = -1;
		insertChildren($<nd>$,3,$<nd>1,$<nd>2,$<nd>4);
	}
	| CASE T ':' E CASES {
		$<nd>$ = mal;
		$<nd->token>$ = strdup("CASES");
		$<nd>1 =  mal;
		$<nd->token>1 = strdup("CASE");
		$<nd->arrayEnd>1 = -1;
		insertChildren($<nd>$,4,$<nd>1,$<nd>2,$<nd>4,$<nd>5);
	};
	| DEFAULT ':' E{
		$<nd>$ = mal;
		$<nd->token>$ = strdup("CASES");
		$<nd>1 =  mal;
		$<nd->token>1 = strdup("DEFAULT");
		$<nd->arrayEnd>1 = -1;
		insertChildren($<nd>$,2,$<nd>1,$<nd>3);
	}
END:	
	'}';
T:	
	ID 
	{	char* str = strdup($<nd->str>1);
		nodeType* res=check_symbol_table($<nd->str>1,symbolTable,end);
		if (res == NULL)
			yyerror("Redeclara");
		else{
			switch(res->id.idType){
				case Int:
					$<nd->value>$ = *(res->id.val.intVal);
					break;
				case Char:
					$<nd->value>$ = *(res->id.val.charVal);
					break;
			}
			//$<nd>$ = mal;
			//$<nd->token>$ = strdup("T");
			$<nd>1 = mal;
			$<nd->token>1 = strdup(str);
			$<nd->arrayEnd>1 = -1;
			insertChildren($<nd>$,1,$<nd>1);

		}
	}

	| NUM {
		//$<nd>$ = mal;
		$<nd->token>$ = strdup("T");
		$<nd>1 = mal;
		$<nd->token>1 = strdup("NUM");
		$<nd->arrayEnd>1 = -1;
		insertChildren($<nd>$,1,$<nd>1);
	};
	| STRING {
		//$<nd>$ = mal;
		$<nd->token>$ = strdup("T");
		$<nd>1 = mal;
		$<nd->token>$ = strdup("STRING");
		$<nd->arrayEnd>1 = -1;
		insertChildren($<nd>$,1,$<nd>1);
	};
E:	
	ASSIGN E {
		$<nd>$ = mal;
		$<nd->token>$ = strdup("E");
		insertChildren($<nd>$,2,$<nd>1,$<nd>2);
	}
	| DECLARE2 E {
		$<nd>$ = mal;
		$<nd->token>$ = strdup("E");
		insertChildren($<nd>$,2,$<nd>1,$<nd>2);
	}
	| X';'E {
		$<nd>$ = mal;
		$<nd->token>$ = strdup("E");
		insertChildren($<nd>$,2,$<nd>1,$<nd>2);
	}
	| BREAK';' 
	| OUT E 
	| IN E |/*empty*/ ;

DECLARE1:
	initInt ID ';' 
	{
	value* val = createValueUnion(Int);
	*val->intVal = 0;
	declare(Int,$<nd->str>2,val,symbolTable);
	free(val);
	$<nd>$ = mal;
	$<nd->token>$ = strdup("DECLARE1");
	$<nd->token>2 = strdup("ID");
	$<nd->arrayEnd>2 = -1;

	insertChildren($<nd>$,1,$<nd>2);
	//printf("Children:%d",$<nd->arrayEnd>2);
	//printTree($<nd>$);

	}
	|initInt ID asop X';' 
	{	//printf("hiiii\n");
		value* val = createValueUnion(Int);
		*val->intVal = $<nd->value>4; 
		declare(Int,$<nd->str>2,val,symbolTable);
		printf("value is:%d %d\n",*val->intVal,$<nd->value>4);
		$<nd>$ = mal;
		$<nd->token>$ = strdup("DECLARE1");
		$<nd>2->token = strdup("ID");
		insertChildren($<nd>$,2,$<nd>2,$<nd>3);
		free(val);
	};
	| initChar ID ';'
	{
		value* val = createValueUnion(Char);
		*val->charVal = 0;
		declare(Char,$<nd->str>2,val,symbolTable);
		free(val);
	};
	| initChar ID asop X ';'
	
	{
		value* val = createValueUnion(Char);
		*val->charVal = $<nd->value>4;
		declare(Char,$<nd->str>2,val,symbolTable);
		free(val);

	};
	|initInt arrayID ';'
	{
		char *temp=$<nd->str>2; int start,last;
		for(int i=0;temp[i]!='\0';i++)
		{
			if(temp[i]=='[') start=i;
			if(temp[i]==']') last=i;
		}
		char *idname=(char*)malloc(sizeof(char)*start);
		int index=0,tempindex=0;
		for(int i=0;i<last;i++)
		{
			if(i<start)
				{idname[tempindex]=temp[i]; tempindex++;}
			if(i>start && i<end)
				{index=index*10+(temp[i]-'0');}
				
		}
		nodeType* res=check_symbol_table(idname,symbolTable,end);
		if(res!=NULL){
			yyerror("Redeclaration of variable");
		}
		else{
			value* val = createValueUnion(Int);
			*val->intVal = 0;
			declare(Int,idname,val,symbolTable);
			symbolTable[end-1]->id.line_no=yylineno; 
			symbolTable[end-1]->id.isArray=index;
			symbolTable[end-1]->id.idType=Int;
			symbolTable[end-1]->id.byteSize=4*index;
			symbolTable[end-1]->id.val.intVal=(int*)malloc(sizeof(int)*index);



			/*
			symbolTable[end]=id(0,idname);
			symbolTable[end]->id.line_no=yylineno; 
			symbolTable[end]->id.isArray=1;
			symbolTable[end]->id.idType=Int;
			symbolTable[end]->id.byteSize=4*index;
			symbolTable[end]->id.val.intVal=(int*)malloc(sizeof(int)*index);
			end++;
			*/
		}
	};
	|initInt arrayID asop X';'
	{
		char *temp=$<nd->str>2; int start,last;
		for(int i=0;temp[i]!='\0';i++)
		{
			if(temp[i]=='[') start=i;
			if(temp[i]==']') last=i;
		}
		char *idname=(char*)malloc(sizeof(char)*start);
		int index=0,tempindex=0;
		for(int i=0;i<last;i++)
		{
			if(i<start)
				{idname[tempindex]=temp[i]; tempindex++;}
			if(i>start && i<end)
				{index=index*10+(temp[i]-'0');}
				
		}
		//int *value=$<array>4;
		nodeType* res=check_symbol_table(idname,symbolTable,end);
		if(res!=NULL){
			yyerror("Redeclaration of variable");
		}
		else{
			value* val = createValueUnion(Int);
			*val->intVal = 0;
			declare(Int,idname,val,symbolTable);
			symbolTable[end-1]->id.line_no=yylineno; 
			symbolTable[end-1]->id.isArray=index;
			symbolTable[end-1]->id.idType=Int;
			symbolTable[end-1]->id.byteSize=4*index;
			symbolTable[end-1]->id.val.intVal=(int*)malloc(sizeof(int)*index);

		}
	} 
	;
	
DECLARE2:
	DECLARE1 DECLARE2{
		$<nd>$ = mal;
		$<nd->token>$ = strdup("DECLARE2");
		insertChildren($<nd>$,2,$<nd>1,$<nd>2);
	}
	|
	{
	$<nd>$ = mal;
	$<nd->token>$ = strdup("DECLARE2");
	$<nd->arrayEnd>$ = -1;
	};                    

ASSIGN:	
	ID asop X';'
	{ 	char* str =strdup($<nd->str>1);
		nodeType* res=check_symbol_table($<nd->str>1,symbolTable,end); 
		if(res!=NULL) {
			switch(res->id.idType){
				case Int:
					printf("original value:%d\n",*(res->id.val.intVal));
					*(res->id.val.intVal) = $<nd->value>3;
					printf("value assigned to variable :%d\n",$<nd->value>3);
					break;

				case Char:
					printf("original value:%c\n",*(res->id.val.intVal));
					*(res->id.val.intVal) = $<nd->value>3;
					printf("value assigned to variable :%c\n",$<nd->value>3);
					break;
				default:
					yyerror("type error bro");
			}
			//$<nd>$ = mal;
			$<nd->token>$ = strdup("ASSIGN");
			$<nd>1 = mal;
			$<nd->token>1 = strdup(str);
			$<nd->arrayEnd>1 = -1;
			insertChildren($<nd>$,2,$<nd>1,$<nd>3);
			
			
		}
		else 
		{
			yyerror("value assigned to undeclared variable");
			//symbolTable[end]=id($<nd->value>3,$<nd->str>1); 
			//end++;
		}
		
	};
	|arrayID asop X';'
	{ 
		char *temp=$<nd->str>2;int start,last;
		for(int i=0;temp[i]!='\0';i++)
		{
			if(temp[i]=='[') start=i;
			if(temp[i]==']') last=i;
		}
		char *idname=(char*)malloc(sizeof(char)*start);
		int index=0,tempindex=0;
		for(int i=0;i<last;i++)
		{
			if(i<start)
				{idname[tempindex]=temp[i]; tempindex++;}
			if(i>start && i<end)
				{index=index*10+(temp[i]-'0');}
				
		}
		nodeType* res=check_symbol_table(idname,symbolTable,end);
		if(res!=NULL) {
			res->id.val.intVal[index]=$<nd->value>3; 
			res->id.line_no=yylineno;
			printf("value assigned to variable :%d\n",$<nd->value>3);
		}
		else 
		{
			yyerror("value assigned to undeclared variable");
			//symbolTable[end]=id($<nd->value>3,$<nd->str>1); 
			//end++;
		}
		
	};
																//HS:     
X:	
	T '+' X 
		{
			
			$<nd->token>$ = strdup("X");
			$<nd->arrayEnd>$ = -1;
			$<nd>2 = mal;
			$<nd->token>2 = strdup("+");
			$<nd->arrayEnd>2 = -1;
			node* child1 = mal;
			node* child2 = mal;
			child1->token = inttostring($<nd->value>1);
			child2->token = inttostring($<nd->value>3);
			insertChildren($<nd>$,3,child1,$<nd>2,$<nd>3);
			$<nd->value>$ = $<nd->value>1 + $<nd->value>3;
		}
	|T '-' X {
	$<nd->token>$ = strdup("X");
	$<nd->arrayEnd>$ = -1;
			$<nd>2 = mal;
			$<nd->token>2 = strdup("-");
			$<nd->arrayEnd>2 = -1;
			node* child1 = mal;
			node* child2 = mal;
			child1->token = inttostring($<nd->value>1);
			child2->token = inttostring($<nd->value>3);
			insertChildren($<nd>$,3,child1,$<nd>2,$<nd>3);
	$<nd->value>$ = $<nd->value>1 - $<nd->value>3;

	}
	|T '*' X {
	$<nd->token>$ = strdup("X");
			$<nd->arrayEnd>$ = -1;
			$<nd>2 = mal;
			$<nd->token>2 = strdup("*");
			$<nd->arrayEnd>2 = -1;
			node* child1 = mal;
			node* child2 = mal;
			child1->token = inttostring($<nd->value>1);
			child2->token = inttostring($<nd->value>3);
			insertChildren($<nd>$,3,child1,$<nd>2,child2);
	$<nd->value>$ = $<nd->value>1 * $<nd->value>3;}		

	|T '/' X 
	{
	$<nd->token>$ = strdup("X");
			$<nd->arrayEnd>$ = -1;
			$<nd>2 = mal;
			$<nd->token>2 = strdup("/");
			$<nd->arrayEnd>2 = -1;
			node* child1 = mal;
			node* child2 = mal;
			child1->token = inttostring($<nd->value>1);
			child2->token = inttostring($<nd->value>3);
			insertChildren($<nd>$,3,child1,$<nd>2,child2);
	$<nd->value>$ = $<nd->value>1 / $<nd->value>3;}

	|T '%' X	{
	$<nd->token>$ = strdup("X");
			$<nd->arrayEnd>$ = -1;
			$<nd>2 = mal;
			$<nd->token>2 = strdup("%");
			$<nd->arrayEnd>2 = -1;
			node* child1 = mal;
			node* child2 = mal;
			child1->token = inttostring($<nd->value>1);
			child2->token = inttostring($<nd->value>3);
			insertChildren($<nd>$,3,child1,$<nd>2,child2);
	$<nd->value>$ = $<nd->value>1 % $<nd->value>3;}


	//|T AND X {$<nd->value>$ = $<nd->value>1 AND $<nd->value>3;}
	//|T OR X  {$<nd->value>$ = $<nd->value>1 OR $<nd->value>3;}
	| unP T {$<nd->value>$ = 1 + $<nd->value>2;}
	| unN T {$<nd->value>$ = $<nd->value>2 - 1;}
	| '!' T {$<nd->value>$ = !$<nd->value>2;}
	| T unP {$<nd->value>$ = $<nd->value>1 +1;}
	| T unN {$<nd->value>$ = $<nd->value>1 - 1;}
	| T 	
	{
			$<nd->value>$ = $<nd->value>1;
			$<nd->token>$ = strdup("X");
			node* child = mal;
			child->token = inttostring($<nd->value>$);
			child->arrayEnd = -1;
			insertChildren($<nd>$,1,child);
				}
	| '('X')'{$<nd->value>$ = $<nd->value>1;};

COND:	
	X '<' COND {$<nd->value>$ = ($<nd->value>1 < $<nd->value>3);}
	|X '>' COND {$<nd->value>$ = ($<nd->value>1 > $<nd->value>3);}
	|X LE COND {$<nd->value>$ = ($<nd->value>1 <= $<nd->value>3);}
	|X GE COND {$<nd->value>$= ($<nd->value>1 >= $<nd->value>3);}
	|X EQ COND {$<nd->value>$ = ($<nd->value>1 ==$<nd->value>3);}
	|X NE COND {$<nd->value>$ = ($<nd->value>1 != $<nd->value>3);}
	| X {
	$<nd->token>$ = strdup("COND");
	insertChildren($<nd>$,1,$<nd>1);
	};												
OUT:	
	cout openOut T OUT1 ;
OUT1:	
	openOut T OUT1 | ';';
IN:	
	cin openIn ID IN1 ;
IN1:	
	openIn ID IN1 | ';';


asop:	'=';


%%

void print_symbol_table(nodeType** symTable, int end)
{
	int i;
	for(i=0;i<end;i++)
	{
	if(symbolTable[i]->type==typeId)break;
	 	if(symbolTable[i]->type==typeOpr)
			printf("<operator> %c\n",symbolTable[i]->opr.oper);
		else
			printf("<keyword> %s\n",symbolTable[i]->key.keyWord);
	}
	printf("  Variable  Type Value Size line of change\n");
	for(int j=i;j<end;j++){
	 		switch(symbolTable[j]->id.idType){
	 			case Int:
	 				if(symbolTable[j]->id.isArray){
		 				printf("<ID> ARRAY %s int | ",symbolTable[j]->id.idName,*(symbolTable[j]->id.val.intVal),symbolTable[j]->id.byteSize,symbolTable[j]->id.line_no);
		 				for(int k=0;k<symbolTable[j]->id.isArray;k++){
		 					printf("%d ",(symbolTable[j]->id.val.intVal)[k]);
		 				}
		 				printf("| %d %d\n",symbolTable[j]->id.byteSize,symbolTable[j]->id.line_no);
		 			}
	 				else printf("<ID> REGULAR %s int %d %d %d\n",symbolTable[j]->id.idName,*(symbolTable[j]->id.val.intVal),symbolTable[j]->id.byteSize,symbolTable[j]->id.line_no);
	 				break;

	 			case Char:
	 				printf("<ID> %s char %c %d %d\n",symbolTable[j]->id.idName,*(symbolTable[j]->id.val.charVal),symbolTable[j]->id.byteSize,symbolTable[j]->id.line_no);
	 				break;
	 		
	 	}
		
	}
}

nodeType* check_symbol_table(char *a,nodeType** symTable ,int end)
{
	for(int i=0;i<end;i++)
		if(symTable[i]->type==typeId && strcmp(symTable[i]->id.idName,a)==0)
			return symTable[i];
	return NULL;
}

nodeType *id(value val,char* name,typeEnum type) {
	nodeType *p;

	/* allocate node */
	if ((p = malloc(sizeof(idNodeType))) == NULL)
		yyerror("out of memory");
	/* copy information */
	strcpy(p->id.idName,name);
	p->type = typeId;
	p->id.idType = type;
	switch(type){
		case Int:
			p->id.byteSize = 4; 
			p->id.val.intVal = val.intVal;
			break;
		case Char:
			p->id.byteSize = 1;
			p->id.val.charVal = val.charVal;
			break;
		case Float:
			p->id.byteSize = 4 ;
			p->id.val.floatVal = val.floatVal;
			break;
		case Double:
			p->id.byteSize = 8;
			p->id.val.doubleVal = val.doubleVal;
			break;
		default:
			yyerror("Type Error");
	}
	return p;
}

nodeType *oper(char opr) {
	nodeType *p;
	/* allocate node */
	if ((p = malloc(sizeof(idNodeType))) == NULL)
		yyerror("out of memory");
	/* copy information */
	p->type = typeOpr;
	p->opr.oper = opr;
	return p;
}

nodeType *key(char* keyword) {
	nodeType *p;
	/* allocate node */
	if ((p = malloc(sizeof(idNodeType))) == NULL)
		yyerror("out of memory");
	/* copy information */
	p->type = typeKey;
	p->key.keyWord = (char*)malloc(sizeof(keyword));
	strcpy(p->key.keyWord,keyword);
	return p;
}

nodeType** initSymbolTable(){
	nodeType** symTable = (nodeType**)calloc(sizeof(nodeType*),1000);

	//operators
	symTable[0] = oper('+');
	symTable[1] = oper('-');
	symTable[2]  = oper('*');
	symTable[3] = oper('/');
	symTable[4]  = oper('<');
	symTable[5] = oper('>');
	symTable[6] = oper('=');
	symTable[7] = oper('L'); //<=
	symTable[8] = oper('G');// >=
	symTable[9] = oper('E');// ==
	symTable[10] = oper('I');// ++
	symTable[11] = oper('D');// --
	symTable[12] = oper('O');//  ||
	symTable[13] = oper('A');// &&


	//keywords
	symTable[14] = key("do");
	symTable[15] = key("while");
	symTable[16] = key("break");
	symTable[17] = key("default");
	symTable[18] = key("case");
	symTable[19] = key("switch");
	symTable[20] = key("do");
	symTable[21] = key("cin");
	symTable[22] = key("cout");

	return symTable;
}
value* createValueUnion(typeEnum type){
	value* val = (value*)malloc(sizeof(value));
	switch(type){
		case Int:
			val->intVal = (int*)malloc(sizeof(int));
			break;
		case Char: 
			val->charVal = (char*)malloc(sizeof(char));
			break;
		//code remaining types

	}
	return val;
}

void declare(typeEnum type,char* idName,value* newVal,nodeType** symbolTable){
	nodeType* res=check_symbol_table(idName,symbolTable,end);
	printf("success");
	if(res!=NULL){
			yyerror("Redeclaration of variable");
	}
	else{
			printf("success");
			switch(type){
				case Int:
					symbolTable[end]=id(*newVal,idName,Int);
					break;
				case Char:
					symbolTable[end]=id(*newVal,idName,Char);
					break;
				default:
					yyerror("type error man");
			}
			symbolTable[end]->id.line_no=yylineno;
			end++;

		}

}
void insertChildren(struct node* parent,int no_children, ...){
	int i;
	va_list children;
	va_start(children,no_children);
	for(i=0;i<no_children;i++){
		parent->array[i] = va_arg(children,struct node*);
		//(parent->array[i])->isParent = 0;
	}
	parent->arrayEnd = i;
	parent->isParent = 1;
}
node *mknode(char *token) 
{ /* malloc the node */ 
  node *newnode = (node *)malloc(sizeof(node)); 
  char *newstr = (char *)malloc(strlen(token)+1); 
  strcpy(newstr, token); 
  newnode->token = newstr; 
  return(newnode); 
} 

void printTree(node* parent){
	//if (parent->isParent==0)return;
	if(parent->arrayEnd!=-1)
		printf("(");
	printf(" %s ",parent->token);
	for(int i=0;i<parent->arrayEnd;i++){
		printTree(parent->array[i]);
		//printf("childName: %s,noOfgrand: %d",(parent->array[i])->token,(parent->array[i])->arrayEnd);
	}
	if(parent->arrayEnd!=-1)
		printf(")");
}
char* inttostring(int a){
	char* str = (char*)malloc(6);
	sprintf(str, "%d", a);
	return str;
}

main()
{
 symbolTable = initSymbolTable();
// printf("Enter the program\n\n");
 end=23;
 yydebug = 0;
 yyparse();
}

int yyerror(char *msg)
{
	
 printf("Invalid, error in line no %d:\n",yylineno);
 printf("%s\n",msg);
 exit(0);
}

