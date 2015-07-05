# M2000Interpreter
M2000 Version 8
Environment M2000
A programming language for pupils in a solid environment.

Version History
M2000 Interpreter as an idea started in 1999 in a Window 98 system using Visual Basic 5. By design M2000 have a target to pupils. A pupil can work with it, to make applications with graphics, databases and media. It is common to anyone that programming languages have commands in English language, but M2000 has two set of instructions, in Greek and English language, and is free to update it to any other. Version 5 was a major update in 2003, with an IDE in Greek language only. There was a test form to control execution, step by step, slow or break it.
For ten years, from 2003, the language be unchanged. Syntax of language was like basic, declaring variables anywhere with modules (like subroutines) and functions (with recursive capability), arrays up to ten dimensions. The new in this language was the use of a stack of values (strings and numbers). Scripts with gsb extension can be run with a click. Modules an Functions can have private modules and functions, so the interpreter can run small blocks inside other blocks, and use local variables and arrays. Code can be loaded at run time. Strings literals may have paragraphs using brackets {}.
In 2013 a new version (6) add threads (code in modules that can be run concurrent), add 32 layers for images and text, add pipe connections (sending data between two or more running scripts), an internal background music score player (using the thread system), and a text to speech interface. New Report command with justified text output. Print can handle proportional text in tabs. Also for the language we have passing by reference variables and arrays to modules and functions. From 6.5 the code converted to VB6. A new Refresh command handle the refresh time, by using a tick counter, setting and resetting by code. Plenty error messages.
From 2014 Unicode was the next target. So a new version (7) change a lot. Scripts saved in utf8 format. Open file statement may have WIDE tag, for read, write, or use random (records with specific length), files in UTF16LE (for 2 bytes only). From version 7 we have new dialog forms and internal text editor, in environment plus a new Form command that apply any text mode in any screen (so a 40x25 can be form in any screen). Earlier versions was stick in the font size (a Mode 12 command set 12pt font size). All dialog forms are zoomable, so when we resize we get a bigger form; plus in all lists we can push up or down with auto scrolling, and for last they have an auto hide scroll bar (in lists). Also threads can be run when we search for a file. Dialog forms for settings, message boxes, font, color, images (with preview), directories (with tree by indentation) are internal in the code so there is no needing for external components. New Test Form with stack showing and a print instruction to print expressions for every step.Two new elements for language, the Document and the Group. We can update a string or a string element in an array to a Document. Documents are paragraph based strings. Group in version 6.5 was like an object and structure, that holds any number of variables, arrays, modules, functions and groups. For that version we can pass group by reference. Also we can pass reference to a group from outside the group.
From 2015, June, a new version, 8th came to complete the language an environment. The new version updates instructions, add many more, like zoomable pop up menu, adding wheel control in all lists. Internal screen editor have a new header line with cursor position, paragraph number, three one key bookmarks and current language keyboard indicator. We can use text editor for Documents with transparent background. Now in Test Forn we can choose to see next command in the code (with lines before and after). Language now can pass anything as value (by copying) groups and arrays. Functions can return groups and arrays too. Functions can be passed by reference. We can make arrays of groups. That groups are "float" groups, and that groups can moved anywhere (no only forward – passing by reference, and now by value – but we can return it enclosed in one array element or in value stack. So now we have classes as functions which return groups (a group may have any number of variables, arrays, modules, functions and other groups).. Sub routines as part of a module using Gosub,

Hello World
1 Using a Module HelloWorld
Module HelloWorld { Print "Hello World" } : HelloWorld
2. Using a Function HelloWorld
Function HelloWorld$ { ="Hello World" } : Print HelloWorld$()
3.Using a Group HelloWorld calling a module inside group ( @Print is a call to internal print)
Group HelloWorld { Module Print {@Print "Hello World" } } : HelloWorld.Print
4.Using a Group HelloWorld using a function inside group
Group HelloWorld { Function Print$ {= "Hello World" } } : Print HelloWorld.Print$()
5. From manual mode just execute the command 
Print "Hello World"
All examples can run from command line interpreter, or from any module or function. Example 1 make a new module. Example 2 make a new function. Example 3 make a group and a module. Example 4 make a group and a function. If we execute Example 3 and 4 then we get one group with a module and a function. If we run all examples we get 5 "Hello World" out to screen, and 2 modules and 2 functions plus one group.
Advance Examples
Example 6 (after execute example 3)
K=HelloWorld : K.Print
We copy group HelloWorld to K and now K has a module Print
Example 7 (after execute example 6)
Group K { Module Print { @Print "Now we print HelloHorld"}}
Now group K change module definition (but not the HelloWorld Group)
We can see all functions and modules in memory with Modules ? 
K.PRINT() HELLOWORLD.PRINT
We can see all variables with LIST
K[Group], HELLWORLD[Group

Example 8 (A function as a Class)
We erase any module/function with NEW. We clear Variables and arrays using Clear with no parameters
New : Clear 
Function HelloWorld { group k {module helloworld { print "Hello World"} } : = k }
AnyName=HelloWorld() : Anyname.Helloworld
We can return a group from a function. So we make a new group as class HelloWorld
We can compact the HelloWorld function using Class
Class HelloWorld { module helloworld { print "Hello World"}} : AnyName=HelloWorld() 
We use module helloworld in a class Helloworld as constructor (M2000 is not case sensitive).
So before HelloWorld return a group copy run module helloworld 
So a class is a function which return a group and execute before a construction module with same name
As we see later we can pass parameters to class function and we process that parameters in construction module.
