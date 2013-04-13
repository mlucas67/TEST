**
** Header file for the Regex class that implements Thompson's on-the-fly
** regular expression compiler and evaluator.
**
$ifndef $Regex
**
** Enumerations used for special "control" characters using in regexes.
**
$define LPAREN 257
$define RPAREN 258
$define ALTERN 259
$define KONCAT 260
$define KLEENE 261

$define ESCAPES '......abtnvfr....................".....()*.................................................\...............................|'

**
** Opcodes
**
$define OP_STOP 1
$define OP_JUMP 2
$define OP_MATCH 3
$define OP_BRANCH 4

$define Regex 1

$endif
