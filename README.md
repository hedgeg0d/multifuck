# Multifuck
### Introduction
Multifuck is a [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) dialect I made, I plan to use it as IR for [Optifuck compiler](https://github.com/hedgeg0d/Optifuck). The main idea of it is to automate the most frequent command blocks in Brainfuck, and make it more convenient. Multifuck does not change the standard Brainfuck functionality, but only adds new features.
### Features

 - Full compatibility with Brainfuck code
 - Two-dimensional memory structure
 - Implemented move-to function
 - Usage of numbers to loop actions is allowed
 - Implemented nullify command
 ### How to use
 
 [V](https://vlang.io/) compiler is required to build the interpreter.
 ```
$ git clone <link> && cd <folder> && v main.v -o mtfcomp 
```
Now you can use compiled interpreter to run .mtf files. 
```$ ./mtfcomp main.mtf```

## Guide
### **Full list of Multifuck commands:**
**Standart Brainfuck commands:**

 - \+ (Plus) - increment selected memory cell by 1
 - \- (Minus) - decrement selected memory cell by 1
 - \> - select next memory cell
 - \< - select previous memory cell
 - [ - start loop
 -  ] - end loop
 - . (Dot) - convert selected cell value to an ASCII symbol and output it
 - , (Comma) - read ASCII symbol, and write it's code to selected cell
  
**Multifuck commands:**
 - @ - switch to the local memory of the cell
 - ! - nullify all cells in local memory, except of the first
 - ) - move value from selected cell to one of the next cells
 - ( - move value from selected cell to one of the previous cells
 
### Explanation

#### Basics
As in Brainfuck, you have an array of single-byte cells. By default, the pointer is set to the very first cell

```
 0 0 0 0 0
/\
```
You can use > < commands to move pointer, and + - to change cell value

##### Example
Code: `+>>>+++-<`
Result:
```
1 0 3
 /\
```
##### Note
If you need to do same operation for a few times you can use numbers for that. For example `+5` is equal to `+++++`. This only works with `+`, `-`, `>` and `<` operations.
#### Cycles
Cycles are done using ] and [ commands. As long as there is no 0 in the selected cell, the iterations will continue, and code between [] executed. If 0, the cycle will not start.
##### Examples
Code: `+++[>++<-]`
Result:
```
 0 6 0
/\
```
Code: `+3[>++<-]>[-]`
Result:
```
0 0 0
 /\
```
##### Note
In Multifuck nullify operation (`[-]`) can be done by using `0`. `+3[>++<-]>[-]` is equal to `+3[>++<-]>0`
#### Output
In Brainfuck `.` command is being used to output ASCII symbols. After it is called cell value is being converted to symbol according to [ASCII table](https://www.ascii-code.com/) and printed. 
##### Hello, World! Brainfuck vs Multifuck
Brainfuck code:
 ```
++++++++[>+++++++++<-]>. 72
<+++++[>++++++<-]>-. 103
+++++++.. 108 x2
+++. 111
[-]++++++[<+++++>-]<++. 32
>+++++++++++[<+++++>-]<.87
>+++++[<+++++>-]<-.111
+++. 114
------. 108
--------.100
[-]>+++++++++++[<+++>-]<.33
```
Multifuck code:
```
+72.+29.+7..+3.0+44.-12.0+87.+24.+3.-6.-8.0.+33.
```
Output: `Hello, World!`

#### Move-to function
Move-to function copies the value of selected cell to another cell, not resetting any cells to zero.`)` command is being used to copy value to one of the next cells and `(` to copy to one of the previous cells.
##### Examples
Memory: 
```
 9 0 0 0
/\
```
Code:
`)3`
Result:
```
 0 0 0 9
/\
```
Memory: 
```
0 0 8 0
   /\
```
Code:
`(2`
Result:
```
8 0 0 0
    /\
```

#### Two-dimensional memory
Every memory cell have its own local memory of a small size. This is especially useful in large programs.
##### Usage example
Imagine situation when first 20 memory cells contain some important values, and you need to multiply first cell by 2. The only way to do it in Brainfuck is to copy cell value somewhere, then move value from that cell to original cell. 
**Let's look at Brainfuck solution:**
```
++++++ 1st cell is 6
keeping next 19 cells unchanged
[>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<-]
>>>>>>>>>>>>>>>>
[<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>-]
>[<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>-]
```
In Multifuck local memory can be used in this situation. To enter local memory `@` command is being used.
##### Example
Memory state before `@`
```
 6 x x x x x
/\
```
Memory state after `@`:
```
 6 0 0 0 0 0
 /\
 ```
 ##### Resetting local memory
After manipulating the cell is finished, you can exit the local memory with the same command. Note local memory is not being reset after exiting it. To manually reset it use `!` command. It will reset all cells except of the first, as it is a part of global memory.
##### Example
Local memory state:
``` 6 5 4 3 2 1```
Local memory state after `!`:
```6 0 0 0 0 0```
So using these features we can solved described problem easier
**Multifuck code:**
```
+6@)1>(1-0@
```

   

