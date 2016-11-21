%{
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <sys/time.h> // gettimeofday
#define YYDEBUG 1

int yyerror(char const *str);

int yylex(void);

uint64_t timer() {
struct timeval tv;
gettimeofday(&tv, NULL);
return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

%}

%start Program

%precedence GR
%precedence CAST
%token VAR_LEN_PARAM EQ NE COMB_AND NON_COMB_AND COMB_VB NON_COMB_VB INC DEC MR
%token AADD ASUB AMUL ADIV AMOD ALEFTSHIFT ARIGHTSHIFT ALOGICALRIGHTSHIFT ABITAND ABITXOR ABITOR
%token RARROW LEFTSHIFT LTEQ GTEQ COMB_GT ANNO_DOT E_DIM_DOT
%token TYPE_ARG_OP
%token STRING_TYPE INT_TYPE BOOLEAN_TYPE DOUBLE_TYPE FLOAT_TYPE SHORT_TYPE
%token CHAR_TYPE BYTE_TYPE LONG_TYPE VOID_TYPE E_DIM E_DIAMOND

%token IF FOR ELSE RETURN FALSE TRUE
%token ABSTRACT ASSERT BREAK CASE CATCH CLASS CONST CONTINUE DEFAULT DO ENUM
%token EXTENDS FINAL FINALLY GOTO IMPLEMENTS IMPORT INSTANCEOF INTERFACE ANNO_INTERFACE NATIVE
%token NEW NULL_LITERAL PACKAGE PRIVATE PROTECTED PUBLIC STATIC STRICTFP SUPER SWITCH
%token SYNCHRONIZED THIS THROW THROWS TRANSIENT TRY VOLATILE WHILE
%token INT STRING IDENTIFIER EOF_SYMBOL LONG FLOAT DOUBLE CHAR

%%

Program
  : TopLevel
  | Program TopLevel
  ;

TopLevel
  : PackageDeclaration
  | ImportDeclarations
  | TypeDeclarations
  | PackageDeclaration ImportDeclarations
  | ImportDeclarations TypeDeclarations
  | PackageDeclaration ImportDeclarations TypeDeclarations
  ;

/* Annotation */
// OptAnnotations
//   :
//   | Annotations
//   ;
Annotations
  : Annotation
  | Annotations Annotation
  ;
Annotation
  : '@' QualifiedName '(' ElementValuePairList ')'
  | '@' QualifiedName '(' ElementValue ')'
  | '@' QualifiedName '(' ')'
  | '@' QualifiedName
  ;
ElementValuePairList
  : ElementValuePair
  | ElementValuePairList ',' ElementValuePair
  ;
ElementValuePair
  : IDENTIFIER '=' ElementValue
  ;
ElementValue
  : ElementValueArrayInitializer
  | ConditionalExpression
  | Annotation
  ;
ElementValueList
  : ElementValue
  | ElementValueList ',' ElementValue
  ;
ElementValueArrayInitializer
  : '{' ElementValueList ',' '}'
  | '{' ElementValueList  '}'
  | '{' '}'
  ;
/* Declaration */
// package

PackageDeclaration
  : Annotations PACKAGE QualifiedName ';'
  | PACKAGE QualifiedName ';'
  ;
// import
ImportDeclarations
  : ImportDeclaration
  | ImportDeclarations ImportDeclaration
  ;
ImportDeclaration
  : IMPORT STATIC PackageName ';'
  | IMPORT PackageName ';'
  ;
PackageName
  : QualifiedName '.' '*'
  | QualifiedName
  ;

// type

TypeDeclarations
  : TypeDeclaration
  | TypeDeclarations TypeDeclaration
  ;
TypeDeclaration
  : ClassDeclaration
  | InterfaceDeclaration
  | ';'
  ;

ClassDeclaration
  : CLASS IDENTIFIER OptTypeParameters OptSuperClass OptSuperInterfaces ClassBody
  | CommonModifiers CLASS IDENTIFIER OptTypeParameters OptSuperClass OptSuperInterfaces ClassBody
  | ENUM IDENTIFIER OptSuperInterfaces EnumBody
  | CommonModifiers ENUM IDENTIFIER OptSuperInterfaces EnumBody
  ;
CommonModifier
  : /*Annotation*/ Annotations
  | PUBLIC
  | PROTECTED
  | PRIVATE
  | ABSTRACT
  | STATIC
  | STRICTFP
  | FINAL
  | TRANSIENT
  | NATIVE
  | VOLATILE
  | SYNCHRONIZED
  ;
CommonModifiers
  : CommonModifier
  | CommonModifiers CommonModifier
  ;
OptSuperClass
  :
  | SuperClass
  ;
SuperClass
  : EXTENDS ClassOrInterfaceType
  ;
OptSuperInterfaces
  :
  | SuperInterfaces
  ;
SuperInterfaces
  : IMPLEMENTS ClassOrInterfaceTypes
  ;
OptClassBody
  :
  | ClassBody
  ;
ClassBody
  : '{' '}'
  | '{' ClassBodyDeclarations '}'
  ;
ClassBodyDeclarations
  : ClassBodyDeclaration
  | ClassBodyDeclarations ClassBodyDeclaration
  ;
ClassBodyDeclaration
  : ClassMemberDeclaration
  | Block
  | STATIC Block
  | ConstructorDeclaration
  ;
ClassMemberDeclaration
  : FieldDeclaration
  | MethodDeclaration
  | ClassDeclaration
  | InterfaceDeclaration
  | ';'
  ;
EnumBody
  : '{' Enumerators ',' ';' ClassBodyDeclarations '}'
  | '{' Enumerators ';' ClassBodyDeclarations '}'
  | '{' Enumerators ',' ';' '}'
  | '{' Enumerators ';' '}'
  | '{' Enumerators ',' '}'
  | '{' Enumerators '}'
  | '{' '}'
  ;
Enumerators
  : Enumerator
  | Enumerators ',' Enumerator
  ;
Enumerator
  : IDENTIFIER EmptyOrArgumentList
  | IDENTIFIER EmptyOrArgumentList ClassBody
  | Annotations IDENTIFIER EmptyOrArgumentList
  | Annotations IDENTIFIER EmptyOrArgumentList ClassBody
  | IDENTIFIER ClassBody
  | Annotations IDENTIFIER ClassBody
  | IDENTIFIER
  | Annotations IDENTIFIER
  ;

// interface, annotation
InterfaceDeclaration
  : INTERFACE IDENTIFIER OptTypeParameters ExtendsInterfaces InterfaceBody
  | CommonModifiers INTERFACE IDENTIFIER OptTypeParameters ExtendsInterfaces InterfaceBody
  | ANNO_INTERFACE IDENTIFIER AnnotationTypeBody
  | CommonModifiers ANNO_INTERFACE IDENTIFIER AnnotationTypeBody
  ;
ExtendsInterfaces
  :
  | EXTENDS ClassOrInterfaceTypes
  ;
InterfaceBody
  : '{' '}'
  | '{' InterfaceMemberDeclarations '}'
  ;
InterfaceMemberDeclarations
  : InterfaceMemberDeclaration
  | InterfaceMemberDeclarations InterfaceMemberDeclaration
  ;
InterfaceMemberDeclaration
  : ConstantDeclaration
  | InterfaceMethodDeclaration
  | ClassDeclaration
  | InterfaceDeclaration
  | ';'
  ;
AnnotationTypeBody
  : '{' '}'
  | '{' AnnotationTypeMemberDeclarations '}'
  ;
AnnotationTypeMemberDeclarations
  : AnnotationTypeMemberDeclaration
  | AnnotationTypeMemberDeclarations AnnotationTypeMemberDeclaration
  ;
AnnotationTypeMemberDeclaration
  : AnnotationTypeElementDeclaration
  | ConstantDeclaration
  | ClassDeclaration
  | InterfaceDeclaration
  | ';'
  ;
AnnotationTypeElementDeclaration
  : Type IDENTIFIER '(' ')' AnnotationTypeElementDefaultValue ';'
  | CommonModifiers Type IDENTIFIER '(' ')' AnnotationTypeElementDefaultValue ';'
  ;
AnnotationTypeElementDefaultValue
  :
  | DEFAULT ElementValue
  ;

// local variable
VariableDeclaration
  : Type InitDeclList
  | CommonModifiers Type InitDeclList
  ;
InitDeclList
  : InitDecl
  | InitDeclList ',' InitDecl
  ;
InitDecl
  : VarName
  | VarName '=' Initializer
  ;
VarName
  : IDENTIFIER
  | IDENTIFIER ArrayModifiers
  | IDENTIFIER Dims
  ;
ArrayModifiers
  : ArrayModifier
  | ArrayModifiers ArrayModifier
  ;
ArrayModifier
  : '[' ConstantExpression ']'
  ;
Initializer
  : Expression
  | ArrayInitializer
  ;
InitializerList
  : Initializer
  | InitializerList ',' Initializer
  ;
ArrayInitializer
  : '{' '}'
  | '{' InitializerList '}'
  | '{' InitializerList ',' '}'
  ;

// field
FieldDeclaration
  : CommonModifiers Type InitDeclList ';'
  | Type InitDeclList ';'
  ;

// constant
ConstantDeclaration
  : Type InitDeclList ';'
  | CommonModifiers Type InitDeclList ';'
  ;

// method
// MethodDeclaration
//   : MethodHeader BlockOrSemicolon
//   | CommonModifiers MethodHeader BlockOrSemicolon
//   ;
// MethodHeader
//   : MethodDeclarator
//   | MethodDeclarator Throws
//   | TypeParameters MethodDeclarator
//   | TypeParameters MethodDeclarator Throws
//   | TypeParameters Annotations MethodDeclarator
//   | TypeParameters Annotations MethodDeclarator Throws
//   ;
// MethodDeclarator
//   : Type IDENTIFIER MethodParameters
//   | Type IDENTIFIER MethodParameters Dims
//   ;

MethodDeclaration
  : Type IDENTIFIER MethodParameters BlockOrSemicolon
  | Type IDENTIFIER MethodParameters Throws BlockOrSemicolon
  | TypeParameters Type IDENTIFIER MethodParameters BlockOrSemicolon
  // | TypeParameters Annotations Type IDENTIFIER MethodParameters BlockOrSemicolon
  | TypeParameters Type IDENTIFIER MethodParameters Throws BlockOrSemicolon
  // | TypeParameters Annotations Type IDENTIFIER MethodParameters Throws BlockOrSemicolon
  | CommonModifiers Type IDENTIFIER MethodParameters BlockOrSemicolon
  | CommonModifiers Type IDENTIFIER MethodParameters Throws BlockOrSemicolon
  | CommonModifiers TypeParameters Type IDENTIFIER MethodParameters BlockOrSemicolon
  // | CommonModifiers TypeParameters Annotations Type IDENTIFIER MethodParameters BlockOrSemicolon
  | CommonModifiers TypeParameters Type IDENTIFIER MethodParameters Throws BlockOrSemicolon
  // | CommonModifiers TypeParameters Annotations Type IDENTIFIER MethodParameters Throws BlockOrSemicolon
  ;

BlockOrSemicolon
  : Block
  | '{' '}' ';'
  | ';'
  ;
InterfaceMethodDeclaration
  : MethodDeclaration
  ;
MethodParameters
  : '(' MethodParamList ')'
  | '(' VarParam ')'
  | '(' ')'
  ;
MethodParamList
  : MethodParam
  | MethodParamList ',' VarParam
  | MethodParamList ',' MethodParam
  ;
MethodParam
  : Type VarName
  | CommonModifiers Type VarName
  ;
VarParam
  : Type VAR_LEN_PARAM VarName
  | CommonModifiers Type VAR_LEN_PARAM VarName
  ;

Throws
  : THROWS ClassOrInterfaceTypes
  ;
// constructor
ConstructorDeclaration
  : CommonModifiers IDENTIFIER MethodParameters ConstructorBody
  | CommonModifiers TypeParameters IDENTIFIER MethodParameters ConstructorBody
  | CommonModifiers IDENTIFIER MethodParameters Throws ConstructorBody
  | CommonModifiers TypeParameters IDENTIFIER MethodParameters Throws ConstructorBody
  | IDENTIFIER MethodParameters ConstructorBody
  | TypeParameters IDENTIFIER MethodParameters ConstructorBody
  | IDENTIFIER MethodParameters Throws ConstructorBody
  | TypeParameters IDENTIFIER MethodParameters Throws ConstructorBody
  ;
ConstructorBody
  : '{' '}'
  | '{' ExplicitConstructorInvocation '}'
  | '{' BlockStatements '}'
  | '{' ExplicitConstructorInvocation BlockStatements '}'
  ;
ExplicitConstructorInvocation
  : THIS EmptyOrArgumentList ';'
  | TypeArguments THIS EmptyOrArgumentList ';'
  | SUPER EmptyOrArgumentList ';'
  | TypeArguments SUPER EmptyOrArgumentList ';'
  | QualifiedName '.' SUPER EmptyOrArgumentList ';'
  | QualifiedName '.' TypeArguments SUPER EmptyOrArgumentList ';'
  | PrimaryExpression '.' SUPER EmptyOrArgumentList ';'
  | PrimaryExpression '.' TypeArguments SUPER EmptyOrArgumentList ';'
  ;

/* Types, Values, Variables */
TypeTest
  : Type
  | TypeTest Type
  ;
Type
  : ReferenceType
  | PrimitiveType
  | VOID_TYPE
  ;
PrimitiveType
  : Annotations UnannoPrimitiveType
  | UnannoPrimitiveType
  ;
UnannoPrimitiveType
  : NumericType
  | BooleanType
  ;
NumericType
  : IntegralType
  | FloatingPointType
  ;
IntegralType
  : BYTE_TYPE
  | CHAR_TYPE
  | SHORT_TYPE
  | INT_TYPE
  | LONG_TYPE
  ;
FloatingPointType
  : FLOAT_TYPE
  | DOUBLE_TYPE
  ;
BooleanType
  : BOOLEAN_TYPE
  ;
ReferenceType
  : ArrayType
  | ClassOrInterfaceType
  // deprecated
  // | TypeVariable
  ;
ArrayType
  : PrimitiveType InitArrays
  | ClassOrInterfaceType InitArrays
  // deprecated
  // | TypeVariable InitArrays
  ;
InitArrays
  : InitArray
  | InitArrays InitArray
  ;
InitArray
  : Annotations E_DIM
  | E_DIM
  ;
ClassOrInterfaceType
  : ClassType
  ;
ClassType
  : QualifiedName
  // | QualifiedName TypeArguments
  | ClassType TypeArguments
  | ClassType TypeArguments '.' ClassType
  | ClassType ANNO_DOT Annotations IDENTIFIER
  // | ClassType ANNO_DOT Annotations IDENTIFIER TypeArguments
  ;

// ClassType
//   : IDENTIFIER
//   | IDENTIFIER TypeArguments
//   | Annotations IDENTIFIER TypeArguments
//   | Annotations IDENTIFIER
//   | ClassType '.' IDENTIFIER
//   | ClassType '.' IDENTIFIER TypeArguments
//   | ClassType '.' Annotations IDENTIFIER TypeArguments
//   | ClassType '.' Annotations IDENTIFIER
//   ;


// Followings are deprecated because it deal same input consumed by SimpleClassType production.
// TypeVariable
//   : Annotations IDENTIFIER
//   | IDENTIFIER
//   ;

OptTypeParameters
  :
  | TypeParameters
  ;
TypeParameters
  : TYPE_ARG_OP '>'
  | TYPE_ARG_OP COMB_GT
  | TYPE_ARG_OP TypeParameterList '>'
  | TYPE_ARG_OP TypeParameterList COMB_GT
  ;
TypeParameterList
  : TypeParameter
  | TypeParameterList ',' TypeParameter
  ;
TypeParameter
  : Annotations UnannoTypeParameter
  | UnannoTypeParameter
  ;
UnannoTypeParameter
  : IDENTIFIER ExtendsTypeModifier
  | IDENTIFIER
  ;
ExtendsTypeModifier
  : EXTENDS ClassOrInterfaceType
  | EXTENDS ClassOrInterfaceType InterfaceTypeList
  ;
InterfaceTypeList
  : NON_COMB_AND ClassOrInterfaceType
  | InterfaceTypeList NON_COMB_AND ClassOrInterfaceType
  ;
TypeArguments
  : TYPE_ARG_OP '>'
  | TYPE_ARG_OP COMB_GT
  | TYPE_ARG_OP TypeArgumentList '>'
  | TYPE_ARG_OP TypeArgumentList COMB_GT
  ;
TypeArgumentList
  : TypeArgument
  | TypeArgumentList ',' TypeArgument
  ;
TypeArgument
  : ReferenceType
  | '?'
  | '?' ExtendsOrSuper
  | Annotations '?'
  | Annotations '?' ExtendsOrSuper
  ;
ExtendsOrSuper
  : EXTENDS ReferenceType
  | SUPER ReferenceType
  ;
NonArrayType
  : ClassOrInterfaceType
  | PrimitiveType
  ;
ClassOrInterfaceTypes
  : ClassOrInterfaceType
  | ClassOrInterfaceTypes ',' ClassOrInterfaceType
  ;
/* Block, Statement */
Block
  : '{' '}'
  | '{' BlockStatements '}'
  ;
BlockStatements
  : BlockStatement
  | BlockStatements BlockStatement
  ;
BlockStatement
  : Statement
  | VariableDeclaration ';'
  | ClassDeclaration
  ;
Statement
  : Block
  | ASSERT Expression ';'
  | ASSERT Expression ':' Expression ';'
  | IF '(' Expression ')' Statement
  | IF '(' Expression ')' Statement ELSE Statement
  | SwitchStatement
  | WHILE '(' Expression ')' Statement
  | DO Statement WHILE '(' Expression ')' ';'
  | FOR '(' OptExpressionList ';' OptExpression ';' OptExpressionList ')' Statement
  | FOR '(' VariableDeclaration ';' OptExpression ';' OptExpressionList ')' Statement
  | FOR '(' Type IDENTIFIER ':' OptExpression ')' Statement
  | FOR '(' CommonModifiers Type IDENTIFIER ':' OptExpression ')' Statement
  | CONTINUE OptIDENTIFIER ';'
  | BREAK OptIDENTIFIER ';'
  | RETURN OptExpression ';'
  | TryStatement
  | THROW Expression ';'
  | SYNCHRONIZED '(' Expression ')' Block
  | IDENTIFIER ':'
  | Expression ';'
  | ';'
  ;

// try-catch-finally
TryStatement
  : TRY ResourceList Block OptCatches
  | TRY ResourceList Block OptCatches FINALLY Block
  | TRY Block OptCatches FINALLY Block
  | TRY Block Catches
  ;
ResourceList
  : '(' Resources ')'
  | '(' Resources ';' ')'
  ;
Resources
  : Resource
  | Resources ';' Resource
  ;
Resource
  : Type IDENTIFIER '=' Expression
  | CommonModifiers Type IDENTIFIER '=' Expression
  ;
OptCatches
  :
  | Catches
  ;
Catches
  : Catch
  | Catches Catch
  ;
Catch
  : CATCH '(' AddCatchParameter ')' Block
  ;
AddCatchParameter
  : ClassOrInterfaceType IDENTIFIER
  | CommonModifiers ClassOrInterfaceType IDENTIFIER
  | AddClassOrInterfaceTypes IDENTIFIER
  | CommonModifiers AddClassOrInterfaceTypes IDENTIFIER
  ;
AddClassOrInterfaceTypes
  : ClassOrInterfaceType
  | AddClassOrInterfaceTypes NON_COMB_VB ClassOrInterfaceType
  ;

// switch
SwitchStatement
  : SWITCH '(' Expression ')' SwitchBlock
  ;
SwitchBlock
  : '{' SwitchConditions '}'
  ;
SwitchConditions
  : SwitchCondition
  | SwitchConditions SwitchCondition
  ;
SwitchCondition
  : CASE ConstantExpression ':'
  | CASE ConstantExpression ':' CaseBlock
  | DEFAULT ':'
  | DEFAULT ':' CaseBlock
  ;
CaseBlock
  : BlockStatement
  | CaseBlock BlockStatement
  ;

/* Expression */
ExpressionTest
  : Expression
  | ExpressionTest Expression
  ;
Expression
  : LambdaExpression
  | AssignmentExpression
  ;
OptExpression
  :
  | Expression
  ;
OptExpressionList
  :
  | ExpressionList
  ;
ExpressionList
  : Expression
  | ExpressionList ',' Expression
  ;
AssignmentExpression
  : UnaryExpression AddAssignmentOperator Expression
  | ConditionalExpression
  ;
AddAssignmentOperator
  : '='
  | AMUL
  | ADIV
  | AMOD
  | AADD
  | ASUB
  | ALEFTSHIFT
  | ARIGHTSHIFT
  | ALOGICALRIGHTSHIFT
  | ABITAND
  | ABITXOR
  | ABITOR
  ;
ConstantExpression
  : ConditionalExpression
  ;
ConditionalExpression
  : LogicalOrExpression
  | ConditionalExpression '?' Expression ':' LogicalOrExpression
  ;
LogicalOrExpression
  : LogicalAndExpression
  | LogicalOrExpression COMB_VB NON_COMB_VB /* '||'*/ LogicalAndExpression
  ;
LogicalAndExpression
  : InclusiveOrExpression
  | LogicalAndExpression COMB_AND NON_COMB_AND /* '&&'*/ InclusiveOrExpression
  ;
InclusiveOrExpression
  : ExclusiveOrExpression
  | InclusiveOrExpression NON_COMB_VB ExclusiveOrExpression
  ;
ExclusiveOrExpression
  : AndExpression
  | ExclusiveOrExpression '^' AndExpression
  ;
AndExpression
  : EqualityExpression
  | AndExpression NON_COMB_AND EqualityExpression
  ;
EqualityExpression
  : RelationalExpression
  | EqualityExpression EQ RelationalExpression
  | EqualityExpression NE RelationalExpression
  ;
RelationalExpression
  : ShiftExpression
  | RelationalExpression '<' ShiftExpression
  | RelationalExpression '>' ShiftExpression
  | RelationalExpression LTEQ ShiftExpression
  | RelationalExpression GTEQ ShiftExpression
  | RelationalExpression INSTANCEOF ReferenceType
  ;
ShiftExpression
  : AdditiveExpression
  | ShiftExpression LEFTSHIFT AdditiveExpression
  | ShiftExpression COMB_GT '>'  AdditiveExpression
  | ShiftExpression COMB_GT COMB_GT '>' AdditiveExpression
  ;
AdditiveExpression
  : MultiplicativeExpression
  | AdditiveExpression '+' MultiplicativeExpression
  | AdditiveExpression '-' MultiplicativeExpression
  ;
MultiplicativeExpression
  : UnaryExpression
  | MultiplicativeExpression '*' UnaryExpression
  | MultiplicativeExpression '/' UnaryExpression
  | MultiplicativeExpression '%' UnaryExpression
  ;
UnaryExpression
  : PostfixExpression
  | INC UnaryExpression
  | DEC UnaryExpression
  | '+' UnaryExpression
  | '-' UnaryExpression
  | '~' UnaryExpression
  | '!' UnaryExpression
  | CastExpression
  ;
CastExpression
  : CastOrGroup UnaryExpression
  ;
CastOrGroup
  : '(' PrimitiveType ')'
  | '(' ArrayType ')'
  | '(' Expression ')'
  // | '(' QualifiedName ')'
  | '(' QualifiedName TypeArguments ')'
  | '(' QualifiedName TypeArguments E_DIM ')'
  ;
PostfixExpression
  : PrimaryExpression
  | QualifiedName
  | PostfixExpression INC
  | PostfixExpression DEC
  ;
ArgumentExpressionList
  : '(' ExpressionList ')'
  ;
PrimaryExpression
  : Constant
  | ClassLiteral
  | THIS
  // | SUPER
  | CastOrGroup
  | QualifiedName '.' THIS
  // | QualifiedName '.' SUPER
  | InstanceCreationExpression
  | FieldAccess
  | ArrayAccess
  | ArrayCreationExpression
  | MethodInvocation
  | MethodReference
  ;
ClassLiteral
  : QualifiedName '.' CLASS
  | QualifiedName E_DIM_DOT '.' CLASS
  | VOID_TYPE '.' CLASS
  | NumericType '.' CLASS
  | NumericType E_DIM_DOT '.' CLASS
  | BOOLEAN_TYPE '.' CLASS
  | BOOLEAN_TYPE E_DIM_DOT '.' CLASS
  ;
InstanceCreationExpression
  : UnqualifiedInstanceCreationExpression
  | QualifiedName '.' UnqualifiedInstanceCreationExpression
  | PrimaryExpression '.' UnqualifiedInstanceCreationExpression
  ;
UnqualifiedInstanceCreationExpression
  : NEW ClassOrInterfaceType EmptyOrArgumentList OptClassBody
  | NEW TypeArguments ClassOrInterfaceType EmptyOrArgumentList OptClassBody
  ;
FieldAccess
  : PrimaryExpression '.' IDENTIFIER
  | SUPER '.' IDENTIFIER
  | QualifiedName '.' SUPER '.' IDENTIFIER
  ;
ArrayAccess
  : QualifiedName '[' Expression ']'
  | PrimaryExpression '[' Expression ']'
  ;
ArrayCreationExpression
  : NEW NonArrayType DimExpressions OptDims
  | NEW NonArrayType Dims ArrayInitializer
  ;
DimExpressions
  : DimExpression
  | DimExpressions DimExpression
  ;
DimExpression
  : '[' Expression ']'
  | Annotations '[' Expression ']'
  ;
OptDims
  : /* empty */
  | Dims
  ;
Dims
  : Dim
  | Dims Dim
  ;
Dim
  : E_DIM
  | Annotations E_DIM
  ;
MethodInvocation
  : QualifiedName EmptyOrArgumentList
  | QualifiedName '.' TypeArguments IDENTIFIER EmptyOrArgumentList
  | FieldAccess EmptyOrArgumentList
  | PrimaryExpression '.' TypeArguments IDENTIFIER EmptyOrArgumentList
  | QualifiedName '.' SUPER '.' IDENTIFIER EmptyOrArgumentList
  | QualifiedName '.' SUPER '.' TypeArguments IDENTIFIER EmptyOrArgumentList
  ;
EmptyOrArgumentList
  : '(' ')'
  | ArgumentExpressionList
  ;

MethodReference // FIXME
  : QualifiedName MR IDENTIFIEROrNew
  | QualifiedName MR TypeArguments IDENTIFIEROrNew
  // : ReferenceType MR IDENTIFIEROrNew
  // | ReferenceType MR TypeArguments IDENTIFIEROrNew
  | QualifiedName '.' SUPER MR IDENTIFIER
  | QualifiedName '.' SUPER MR TypeArguments IDENTIFIER
  | SUPER MR IDENTIFIER
  | SUPER MR TypeArguments IDENTIFIER
  ;
IDENTIFIEROrNew
  : IDENTIFIER
  | NEW
  ;
LambdaExpression
  : LambdaParameters RARROW LambdaBody
  ;
LambdaParameters
  : IDENTIFIER
  | '(' ')'
  | '(' MethodParamList ')'
  // | '(' InferredParamList ')'
  ;
//FIXME Followings occurr reduce/reduce conflicts
// InferredParamList
//   : IDENTIFIER
//   | InferredParamList ',' IDENTIFIER
//   ;
LambdaBody
  : Expression
  | Block
  ;
/* Identifier */
OptIDENTIFIER
  :
  | IDENTIFIER
  ;
QualifiedName
  : IDENTIFIER
  | QualifiedName '.' IDENTIFIER
  ;

/* Literal, Constant */
Literal
  : FLOAT
  | DOUBLE
  | INT
  | TRUE
  | FALSE
  | CHAR
  | STRING
  | NULL_LITERAL
  ;
Constant
  : Literal
  ;


  %%
  int
  yyerror(char const *str)
  {
      extern char *yytext;
      extern int yylineno;
      fprintf(stderr, "line:%d parse error near %s\n",yylineno, yytext);
      return 0;
  }

  static double timediff(struct timeval *s, struct timeval *e) {
    double t1 = (e->tv_sec - s->tv_sec) * 1000.0;
    double t2 = (e->tv_usec - s->tv_usec) / 1000.0;
    return t1 + t2; /* ms */
  }

  int main(int argc, char *const argv[])
  {
      extern int yyparse(void);
      extern FILE *yyin;
      // const char *input_file = NULL;
      int input_size = 0;
      const char *orig_argv0 = argv[0];
      // int opt;


      if (argc == 1 ) {
        fprintf(stdout,"Usage: %s [inputfiles]",argv[0]);
        return 1;
      }

      for (int i = 1; i < argc; i++) {
        if (!(yyin = fopen(argv[i], "rb"))) {
    			fprintf(stderr, "File [%s] is not found!\n", argv[i]);
    			return 1;
        }
        int result = 0;
        struct timeval start, end;
        gettimeofday(&start, NULL);
        result = yyparse();
        gettimeofday(&end, NULL);
        // printf("%d\n",result );
        if (result) {
          fprintf(stderr, "[%s] Parse Error!!!\n", argv[i]);
          break;
        }
        fprintf(stdout, "%s OK %.4f [ms]\n", argv[i], timediff(&start, &end));
      }

      // for (int i = 1; i < argc; i++) {
      //   if (!(yyin = fopen(argv[i], "rb"))) {
      //     fprintf(stderr, "File [%s] is not found!\n", argv[i]);
      //     return 1;
      //   }
      //   double tsum = 0.0;
      //   double t[5];
      //   for (int c = 0; c < 5; c++) {
      //     int result = 0;
      //     struct timeval start, end;
      //     gettimeofday(&start, NULL);
      //     result = yyparse();
      //     gettimeofday(&end, NULL);
      //     // printf("%d\n",result );
      //     if (result) {
      //       fprintf(stdout, "%s FAIL %.4f [ms]\n", argv[i], timediff(&start, &end));
      //       break;
      //     }
      //     t[c] = timediff(&start, &end);
      //     tsum += t[c];
      //   }
      //   if (tsum != 0.0) {
      //     fprintf(stdout, "%s OK %.4f [ms]\n", argv[i], tsum/5);
      //   }
      // }


      // uint64_t start, end;
      // start = timer();
      // if (yyparse()) {
      //     fprintf(stderr, "[%s] Parse Error!!!\n", argv[2]);
      //     exit(1);
      // } else {
      //     // fprintf(stderr, "Match!!\n");
      // }
      // end = timer();
      //
      // printf("[%s] %llu [ms]\n",argv[2],end - start);
      //
      // return 0;
  }
