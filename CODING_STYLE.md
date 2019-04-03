neng2 Coding Style
====================

Tabs and indentation
--------------------

No Tab characters should be used in source code.  
Use 4 spaces instead of tabs.


Identifiers
-----------

Class names: CamelCase with uppercase first letter and begins with "C", e.g.: `CNode`, `CTexture`.  
Method and property names: camelCase with lowercase first letter, e.g.: `maxLength`, `onClick`.  
Signal names: camelCase.  
```D
class CMyClass {
private:
    int _magicNumber;

public:
    @property 
    int getMagicNumber() { 
        return magicNumber; 
    }
}
```

Enum names: CamelCase with uppercase first letter and begins with "E", e.g.: `EAlign`, `EType`.   
Enum member names: JAVA_LIKE.  
```D
enum ESomeEnum {
    SE_TEST1,
    SE_TEST2,
}
```

Spaces
------

Always put space after comma or semicolon if there are more items in the same line.
```D
update( x, y, isAnimating( this ) );

auto list = [1, 2, 3, 4, 5];
```
Usually there is space after opening and before closing `()`.
```D
auto y = ( x * x + ( ( ( a - b ) + c ) ) * 2 );
```
Use spaces before and after == != && || + - * / etc.


Brackets
--------

Curly braces for `if`, `switch`, `for`, `foreach` - preferable placed on the same lines as keyword:
```D
if ( a == b ) {
    //
} else {
    //
}

foreach ( item; list ) {
    writeln( item );
}
```
Cases in switch should be indented:
```D
switch ( action.id ) {
    case 1:
        processAction( 1 );
        break;
    default:
        break;
}
```
For classes and structs opening { must be at the end of line. 
```D
class CFoo {
}

class CBar : CFoo {
}
```
For methods  { should be at the end of line.
```D
void invalidate() {
    //
}

int length() {
    return list.length;
}
```

ORIGINAL: https://github.com/buggins/dlangui/blob/master/CODING_STYLE.md
