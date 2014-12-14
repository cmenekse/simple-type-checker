%{
#include <stdio.h>
#include <string.h>
#include "Node.h"
#include  <assert.h>
#include "vector.h"

void yyerror(const char *s)
{
	printf("%s\n", s);
}

//Vector
void vector_init(vector *v)
{
	v->data = NULL;
	v->size = 0;
	v->count = 0;
}
 
int vector_count(vector *v)
{
	return v->count;
}
 
void vector_add(vector *v, void *e)
{
	printf("ADD START\n");
	if (v->size == 0) {
		v->size = 10;
		v->data = malloc(sizeof(void*) * v->size);
		//memset(v->data, '\0', sizeof(void) * v->size);
		memset(v->data, '\0', sizeof(void *) * v->size);
	}
 
	// condition to increase v->data:
	// last slot exhausted
	if (v->size == v->count) {
		v->size *= 2;
		v->data = realloc(v->data, sizeof(void*) * v->size);
	}
 
	v->data[v->count] = e;
	v->count++;
	printf("ADD END\n");
}
 
void vector_set(vector *v, int index, void *e)
{
	if (index >= v->count) {
		return;
	}
 
	v->data[index] = e;
}
 
void *vector_get(vector *v, int index)
{
	if (index >= v->count) {
		return;
	}
 
	return v->data[index];
}
 
void vector_delete(vector *v, int index)
{
	if (index >= v->count) {
		return;
	}
 
	v->data[index] = NULL;
 
	int i, j;
	void **newarr = (void**)malloc(sizeof(void*) * v->count * 2);
	for (i = 0, j = 0; i < v->count; i++) {
		if (v->data[i] != NULL) {
			newarr[j] = v->data[i];
			j++;
		}		
	}
 
	free(v->data);
 
	v->data = newarr;
	v->count--;
}
 
void vector_free(vector *v)
{
	free(v->data);
}
//Vector sample

/*
vector v;
	vector_init(&v);
 
	vector_add(&v, "emil");
	vector_add(&v, "hannes");
	vector_add(&v, "lydia");
	vector_add(&v, "olle");
	vector_add(&v, "erik");
 
	int i;
	printf("first round:\n");
	for (i = 0; i < vector_count(&v); i++) {
		printf("%s\n", vector_get(&v, i));
	}
 
	vector_delete(&v, 1);
	vector_delete(&v, 3);
 
	printf("second round:\n");
	for (i = 0; i < vector_count(&v); i++) {
		printf("%s\n", vector_get(&v, i));
	}
 
	vector_free(&v);
 
	return 0;

*/

//End Vctor

vector types;
vector ids;
vector arrayLengths;
char * getTypeOfId(char * id);
int indexOfVector(char * id , vector searchedV);
void printVector(vector vToPrint);
void copy_string(char *target, char *source);
Node * createNode(int value,int arrayLength,char * typeName,char *variableName);
void addToVector(int arrayLength,char * typename,char * name);

%}
%union {
char *name;
int value;
Node *nodePtr;
}
%token <value>tINTNUM tREALNUM <name>tID tINT tREAL tBOOLEAN tBEGIN tEND tIF tTHEN tELSE tWHILE tFALSE tTRUE tCOMMA tLPAR tRPAR tSLPAR tSRPAR tASSIGN
%type <nodePtr> Expr
%type <nodePtr> Lval
%type <nodePtr> Type
%type <nodePtr> BinOp
%left tNOT
%left tSUB
%left tMULT
%left tPLUS
%left tSMALLER
%left tEQ
%left tAND
%% /*Grammar follows */
Prgrm: VarDeclLst StmtBlk {printf("Printing here;");printVector(ids);printVector(types);}
;
VarDeclLst: VarDecl VarDeclLst
			|VarDecl {printVector(ids)}
			;
VarDecl: Type tID tCOMMA 
		 { 
		 	char * id = $2;
		 	char* typeName = $1->typeName;
		   	addToVector(-1,typeName,id);

		 }
		 |Type tID tSLPAR tINTNUM tSRPAR tCOMMA 
		 {
		 	int arrayLength = $4;
		 	char * typeName = $1->typeName;
		 	char * id = $2;
		 	addToVector(arrayLength,typeName,id);
		 
		 }
		 ;
Type: tINT {$$=createNode(-1,-1,"integer","NA");}
	  |tREAL {$$=createNode(-1,-1,"real","NA");}
	  |tBOOLEAN {$$=createNode(-1,-1,"boolean","NA");}
	  ;
StmtBlk: tBEGIN StmtLst tEND
;
StmtLst: Stmt StmtLst
		 |Stmt
		 ;
Stmt : AsgnStmt 
	   |IfStmt
	   |WhlStmt
	   ;
AsgnStmt:Lval tASSIGN Expr tCOMMA
;
Lval: tID 
	  |tID tSLPAR Expr tSRPAR
	  ;
IfStmt:tIF tLPAR Expr tRPAR tTHEN StmtBlk tELSE StmtBlk
	  {
		 char * typeName = $3->typeName;
		 if(typeName!="boolean")
		 {
		 	printf("Expression on the IF should be boolean");
		 }
	  }
;
WhlStmt:tWHILE tLPAR Expr tRPAR StmtBlk
	 {
	 	char * typeName = $3->typeName;
		 if(typeName!="boolean")
		 {
		 	printf("Expression on the While should be boolean");
		 }		
	 }
;
Expr: tINTNUM { $$=createNode($1,-1,"integer","NA");} 
	  |tREALNUM 
	  |tFALSE { $$=createNode(-1,-1,"boolean","NA");}	
	  |tTRUE  { $$=createNode(-1,-1,"boolean","NA");}	
	  |tID 
	  {
	  	char *typeName=getTypeOfId($1);
	  	char * idName = $1;
	  	$$=createNode(-1,-1,typeName,idName);
	  }
	  |tID tSLPAR Expr tSRPAR 
	  {
	  	char * typeName = getTypeOfId($1);
	  	int arrayLength= getArrayLength($1);
	  	if(arrayLength!=-1)
	  	{
	  		int exprValue=$3->value;
	  		if(arrayLength>=exprValue)
	  		{
	  			printf("Array Index is out of range");
	  		}
	  	}
	  	else
	  	{
	  		printf("it is not an array");
	  	}
	  
	  
	  
	   }
	  |tLPAR Expr tRPAR
	  |Expr BinOp Expr { if (strcmp($1->typeName,$3->typeName)==0)
	  					 {
	  					 	char * resultType = strdup($1->typeName);
	  					 	printf(" %s and %s does match" , $1->typeName, $3->typeName);
	  					 	if(strcmp($2->typeName,"PLUS")== 0)
	  					 	{
	  					 			char * variableName="NA";
	  					 			int value = $1->value + $3->value;
	  					 			int arrayLength=-1;
	  					 			$$=createNode(value,arrayLength,resultType,variableName); 
	  					 	}
	  					 	else if (strcmp($2->typeName,"MULT")==0)
	  					 	{
	  					 			char * variableName="NA";
	  					 			int value = $1->value * $3->value;
	  					 			int arrayLength=-1;
	  					 			$$=createNode(value,arrayLength,resultType,variableName);
	  					 	}
	  					 } 
	  					 else
	  					 {
	  				 	 	printf(" %s and %s does NOT match" , $1->typeName, $3->typeName);
	  					 }
	  				   }
	  |UnOp Expr
	  ;
BinOp: tPLUS {$$=createNode(-1,-1,"PLUS","NA");}
	   |tMULT {$$=createNode(-1,-1,"MULT","NA");}
	   |tSMALLER {$$=createNode(-1,-1,"SMALLER","NA");}
	   |tEQ {$$=createNode(-1,-1,"EQ","NA");}
	   |tAND {$$=createNode(-1,-1,"AND","NA");}
	   ;
UnOp: tSUB
	  |tNOT
	  ;
%%		 
int main()
{	
	printf("Version 27");
	vector_init(&types);
	vector_init(&ids);
	vector_init(&arrayLengths);
	if(yyparse())
	{
		printf("ERROR\n" );
		//return 1;
	}
	else
	{
		printf("OK\n");
	}
	return 0;
}

char * getTypeOfId(char * id)
{
	
	int index = indexOfVector(id,ids);
	printf("found in %d ",index );
	char * foundType=vector_get(&types,index);
	return foundType;
}
int getArrayLength(char *id)
{
	int index = indexOfVector(id,ids);
	printf("found in %d ",index );
	int arrayLength=vector_get(&arrayLengths,index);
	return arrayLength;
}


void addToVector(int arrayLength,char * typename,char * name)
{
	printf ( "Adding tuple Name : %s , TypeName: %s \n",name,typename);
	
	char *addName=strdup(name);
	char *addTypeName = strdup(typename);
	vector_add(&types,addTypeName);
	printVector(types);
	vector_add(&ids,addName);
	vector_add(&arrayLengths,arrayLength);
	printVector(ids);
}



void printVector(vector vToPrint)
{
	printf ( "Printing the vector: \n");	
	int i;	
	for(i=0;i<vector_count(&vToPrint);i++)
	{
		printf("[%d]=%s \n" ,i, vector_get(&vToPrint,i));	
	}
	printf("\n");
}

int indexOfVector(char * id , vector searchedV)
{
	printf("Searching %s " ,id );
	int i;	
	for(i=0;i<vector_count(&searchedV);i++)
	{
		char * text=vector_get(&searchedV,i);
		if(strcmp(id,text)==0)
		{
			return i;		
		}		
			
	}
	return -1;
}

Node * createNode(int value,int arrayLength,char * typeName,char *variableName)
{
	Node * ret = (Node *) malloc (sizeof(Node));
	ret->typeName = typeName;
	ret->value = value;
	ret->arrayLength=arrayLength;
	ret->variableName=variableName;
	return (ret);
}







