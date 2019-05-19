%{
#include<stdio.h>
#include<stdlib.h>
#include"structs.h"
#include<string.h>
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
FILE *fp;
int *icg_temp,labelno=0;
int *switch_cases,sindex=0;
#define YYDEBUG_LEXER_TEXT yytext
%}

%union
{
char *str;
int value;
int *array;
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
		printf("do-while statement\n"); 
		printf("\n\nSymbol Table:**********************************\n");
		print_symbol_table(symbolTable, end); 
		exit(0);
	}; 

	| START DECLARE2 BODY END 
	{
		printf("Switch statement\n");
		printf("\n\nSymbol Table:**********************************\n");
		print_symbol_table(symbolTable, end); 
		fclose(fp);
		exit(0);
	};
START:	
	HEADER1 HEADER2 DECLARE2 HEADER3'{' | HEADER1 DECLARE2 HEADER3'{';
//INITIALIZE:
//	ASSIGN INITIALIZE | DECLARE INITIALIZE |/*empty*/;
LOOP:	
	DO'{' {labelno++;fprintf(fp,"\nL%d:\n",labelno);} LOOPBODY'}'WHILE'('COND')'';';	// | DO'{' {labelno++;fprintf(fp,"L%d:\n",labelno);} temp'}'WHILE'('COND')'';';
											// | DO'{' {labelno++;fprintf(fp,"L%d:\n",labelno);} E LOOP'}'WHILE'('COND')'';'

											// | DO'{' {labelno++;fprintf(fp,"L%d:\n",labelno);} LOOP E'}'WHILE'('COND')'';';
LOOPBODY: LOOPBODY LOOPBODY | E | LOOP;

BODY: 
	{fprintf(fp,"goto Lstart\n\n");} SWITCH'('T')''{' {labelno++;fprintf(fp,"L%d:\n",labelno);} CASES'}' {func_lstart($<str>5); fprintf(fp,"Lnext:\n");};
CASES: 
	CASE T':'  CASEBODY 
	| CASE T':'  CASEBODY{printf("%d",$<value>2);switch_cases[sindex]=$<value>2;sindex++; labelno++;fprintf(fp,"L%d:\n",labelno);} CASES 
	| DEFAULT':'CASEBODY;								//CASE T':'E | CASE T':'E CASES | DEFAULT':'E;
CASEBODY: CASEBODY CASEBODY | E | BODY;

END:	
	'}';
T:	
	ID 
	{
		nodeType* res=check_symbol_table($<str>1,symbolTable,end);
		if (res == NULL)
			yyerror("Redeclaration");
		else
			switch(res->id.idType){
				case Int:
					$<value>$ = *(res->id.val.intVal);
					break;
				case Char:
					$<value>$ = *(res->id.val.charVal);
					break;
			}


	}
	| NUM | STRING; 													//| X | '('X')' ;
E:	
	ASSIGN E | DECLARE2 E | X';'E | BREAK';'{fprintf(fp,"goto Lnext\n\n");} | OUT E | IN E |/*empty*/ ;

DECLARE1:
	initInt ID ';' 
	{
	value* val = createValueUnion(Int);
	*val->intVal = 0;
	declare(Int,$<str>2,val,symbolTable);
	free(val);
												/*
													nodeType* res=check_symbol_table($<str>2,symbolTable,end);
													if(res!=NULL){
														yyerror("Redeclaration of variable");
													}
													else{
														value* val = createValueUnion()
														val->intVal = 0;
														symbolTable[end]=id(val,$<str>2,Int);
														symbolTable[end]->id.line_no=yylineno; 
														end++;
													}
												*/
	}
	|initInt ID asop X';' 
	{	printf("hiiii\n");
		value* val = createValueUnion(Int);
		*val->intVal = $<value>4; 
		declare(Int,$<str>2,val,symbolTable);
		printf("value is:%d %d\n",*val->intVal,$<value>4);
		free(val);
		icg_func2($<value>4,$<str>2);

												/*
												nodeType* res=check_symbol_table($<str>2,symbolTable,end);
												if(res!=NULL){
													yyerror("Redeclaration of variable");
												}
												else{
													value* val = createValueUnion(Int);
													*val->intVal = $<value>4;
													symbolTable[end]=id(val,$<str>2,Int); 
													symbolTable[end]->id.line_no=yylineno; 
													end++;
												}
												*/


	};
	| initChar ID ';'
	{
		value* val = createValueUnion(Char);
		*val->charVal = 0;
		declare(Char,$<str>2,val,symbolTable);
		free(val);
												/*
												nodeType* res=check_symbol_table($<str>2,symbolTable,end);
												if(res!=NULL){
													yyerror("Redeclaration of variable");
												}
												else{
													value* val = createValueUnion();
													val->intVal = 0;
													symbolTable[end]=id(val,$<str>2,Char);
													symbolTable[end]->id.line_no=yylineno; 
													end++;
												}
												*/
	};
	| initChar ID asop X ';'
	
	{
		value* val = createValueUnion(Char);
		*val->charVal = $<value>4;
		declare(Char,$<str>2,val,symbolTable);
		free(val);

	/*
													nodeType* res=check_symbol_table($<str>2,symbolTable);
													if(res!=NULL){
														yyerror("Redeclaration of variable");
													}
													else{
														value* val = createValueUnion(har)
														*val->charVal = $<value>4;
														symbolTable[end]=id(val,$<value>4,$<str>2); 
														symbolTable[end]->id.line_no=yylineno; 
														end++;
													}
	*/

	};
	|initInt arrayID ';'
	{
		char *temp=$<str>2; int start,last;
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
		char *temp=$<str>2; int start,last;
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
	} 
	;
	
DECLARE2:
	DECLARE1 DECLARE2|;

ASSIGN:	
	ID asop X';'
	{ 
		nodeType* res=check_symbol_table($<str>1,symbolTable,end); 
		if(res!=NULL) {
			switch(res->id.idType){
				case Int:
					printf("original value:%d\n",*(res->id.val.intVal));
					*(res->id.val.intVal) = $<value>3;
					printf("value assigned to variable :%d\n",$<value>3);
					break;

				case Char:
					printf("original value:%c\n",*(res->id.val.intVal));
					*(res->id.val.intVal) = $<value>3;
					printf("value assigned to variable :%c\n",$<value>3);
					break;
				default:
					yyerror("type error bro");
			}
			
			
		}
		else 
		{
			yyerror("value assigned to undeclared variable");
			//symbolTable[end]=id($<value>3,$<str>1); 
			//end++;
		}
		icg_func2($<value>3,$<str>1);
		
	};
	|arrayID asop X';'
	{ 
		char *temp=$<str>2;int start,last;
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
			res->id.val.intVal[index]=$<value>3; 
			res->id.line_no=yylineno;
			printf("value assigned to variable :%d\n",$<value>3);
		}
		else 
		{
			yyerror("value assigned to undeclared variable");
			//symbolTable[end]=id($<value>3,$<str>1); 
			//end++;
		}
		
	};
																//HS:     
X:	
	T '+' X {
			char op='+';
			$<value>$ = $<value>1 + $<value>3;	
			icg_func1($<value>1,$<value>3,"+");
		
		 }
	|T '-' X {
			char op='-';
			$<value>$ = $<value>1 - $<value>3;
			icg_func1($<value>1,$<value>3,"-");
		 }
	|T '*' X {
			char op='*';
			$<value>$ = $<value>1 * $<value>3;
			icg_func1($<value>1,$<value>3,"*");	
		 }	
	|T '/' X {
			char op='/';
			$<value>$ = $<value>1 / $<value>3;
			icg_func1($<value>1,$<value>3,"/");
		 }
	|T '%' X {
			char op='%';
			$<value>$ = $<value>1 % $<value>3;
			icg_func1($<value>1,$<value>3,"%");
		 }
	//|T AND X {$<value>$ = $<value>1 AND $<value>3;}
	//|T OR X  {$<value>$ = $<value>1 OR $<value>3;}
	| unP T {$<value>$ = 1 + $<value>2;}
	| unN T {$<value>$ = $<value>2 - 1;}
	| '!' T {$<value>$ = !$<value>2;}
	| T unP {$<value>$ = $<value>1 +1;}
	| T unN {$<value>$ = $<value>1 - 1;}
	| T 	{$<value>$ = $<value>1;}
	| '('X')'{$<value>$ = $<value>1;};

COND:	
	X '<' COND {$<value>$ = ($<value>1 < $<value>3);  icg_label($<value>1,$<value>3,"<");}
	|X '>' COND {$<value>$ = ($<value>1 > $<value>3); icg_label($<value>1,$<value>3,">");}
	|X LE COND {$<value>$ = ($<value>1 <= $<value>3); icg_label($<value>1,$<value>3,"<=");}
	|X GE COND {$<value>$= ($<value>1 >= $<value>3);  icg_label($<value>1,$<value>3,">=");}
	|X EQ COND {$<value>$ = ($<value>1 ==$<value>3);  icg_label($<value>1,$<value>3,"==");}
	|X NE COND {$<value>$ = ($<value>1 != $<value>3); icg_label($<value>1,$<value>3,"!=");}
	| T {icg_label($<value>1,-1000,"");};												
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
void func_lstart(char *var)
{
	fprintf(fp,"Lstart:\n");
	for(int i=0;i<labelno-1;i++)
	{
		//if(switch_cases[i])
		{
			{fprintf(fp,"if %s==%d goto L%d\n",var,switch_cases[i],i+1);}
		}
	}
}
void icg_label(int a, int b, char *op)
{
	fprintf(fp,"\n");
	int ai=-1,bi=-1;
	for(int i=0;i<10;i++)
	{
		if(icg_temp[i]==a) ai=i;
		if(icg_temp[i]==b) bi=i;
	}	
	if(ai>=0 && bi>=0 && b!=-1000)
		fprintf(fp,"if t%d%st%d goto L%d\n",ai,op,bi,labelno);
	else if(bi>=0 && ai==-1 && b!=-1000)
		fprintf(fp,"if %d%st%d goto L%d\n",a,op,bi,labelno);
	else if(ai>=0 && bi==-1 && b!=-1000)
		fprintf(fp,"if t%d%s%d goto L%d\n",ai,op,b,labelno);
	else if(ai>=0 && b==-1000)
		fprintf(fp,"if t%d%s goto L%d\n",ai,op,labelno);
	else
		fprintf(fp,"if %d%s goto L%d\n",a,op,labelno);
	labelno--;
}

void icg_func2(int val, char *id)
{
	int i,flag=-1;
	for(i=0;i<10;i++)
	{
		if(icg_temp[i]==val)
		{
			flag=0;
			break;
		}
	}
	//i=0;icg_temp[i]=val;
	if(fp && flag==0)
	{
		printf("\n\nVALUEEEEEEEEEEEEEEE");
		//fprintf(fp,"t%d=%d\n",i,val);
		fprintf(fp,"%s=t%d\n",id,i);
	}		
}
void icg_func1(int a, int b, char *op)
{	int i,ai=-1,bi=-1,index=-1;
	int temp;
	switch(op[0])
	{
		case '+':temp=a+b;break;
		case '-':temp=a-b;break;
		case '*':temp=a*b;break;
		case '%':temp=a%b;break;
		case '/':temp=a/b;break;	
	}
	static int blockno=1;
	//CODE OPTIMIZATION CSE------- from 472 to 491; put '{' after commenting
	if(blockno==labelno)
	{	
		for(i=0;i<10;i++)
		{
			if(icg_temp[i]==0 && find_CSE(temp)==-1)
				{
				
					icg_temp[i]=temp;
					break;
				}	
			else
				index=find_CSE(temp);
			if(icg_temp[i]==a) ai=i;
			if(icg_temp[i]==b) bi=i;
		}
	}
	else
	{
		for(int i=0;i<10;i++)
			icg_temp[i]=0;
		
		for(i=0;i<10;i++)
		{
			if(icg_temp[i]==0)
				{
					icg_temp[i]=temp;
					break;
				}	
		if(icg_temp[i]==a) ai=i;
		if(icg_temp[i]==b) bi=i;
		}
		blockno++;
	}
	if(fp)
	{
		printf("\n\nIIIIIIIIIIIIIIIIIIIIIIIIICGG%d%d%s%d",i,a,op,b);
		if(index!=-1)
			return;		
		else if(ai>=0 && bi==-1)
			fprintf(fp,"t%d=t%d%s%d\n",i,ai,op,b);
		else if(bi>=0 && ai==-1)
			fprintf(fp,"t%d=%d%st%d\n",i,a,op,bi);
		else if(ai>=0 && bi>=0)
			fprintf(fp,"t%d=t%d%st%d\n",i,ai,op,bi);		
		else	
			fprintf(fp,"t%d=%d%s%d\n",i,a,op,b);
	}
		
}
int find_CSE(int val)
{
	for(int i=0;i<10;i++)
	{
		if(icg_temp[i]==val)
			return i;	
	}
	return -1;
}

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
//	p->id.i = i;
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



main()
{
 fp=fopen("icg.txt","w");
 icg_temp=(int*)calloc(sizeof(int),10);
 switch_cases=(int*)calloc(sizeof(int),10);
 symbolTable = initSymbolTable();
// printf("Enter the program\n\n");
 end=23;
 yydebug = 1;
 yyparse();
	
}

int yyerror(char *msg)
{

 printf("Invalid, error in line no %d:\n",yylineno);
 printf("%s\n",msg);
 exit(0);
}


