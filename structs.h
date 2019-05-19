typedef enum { typeId, typeOpr ,typeKey} nodeEnum;
typedef enum {Int,Char,Float,Double} typeEnum;
/* constants */

typedef union value{
	int* intVal;
	float* floatVal;
	char* charVal;
	double* doubleVal;
}value;

//identifiers
typedef struct {
	nodeEnum type;
	int isArray;
	typeEnum idType;
	int byteSize;
	int line_no;
	char idName[31];
	value val;
	int i;
	char *scope;
} idNodeType;

//operators
typedef struct {
	nodeEnum type;
	int line_no;
	int oper; // specify operator as a character(ascii value is int)
} oprNodeType;

//keywords
typedef struct{
	nodeEnum type;
	int line_no;
	char* keyWord;
}keyNodeType;

typedef union nodeTypeTag {
	nodeEnum type;
	
	idNodeType id;
	oprNodeType opr;
	keyNodeType key;
} nodeType;
