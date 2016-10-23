import std.stdio;
import std.conv;
import std.datetime;
import lex.lexer;
import lex.token;

int main(string[] argv)
{
	//Open a file with the lexer
	Lexer l = new Lexer("test.txt");

	//Lex all input
	StopWatch sw;
	sw.start();
	writeln("Beginning lexing:");
	l.lex();
	writeln("Finished lexing:");
	writeln(sw.peek().nsecs / 1000000000.0);
	/*
	* Initial state
	* lexes a ~5MB file in roughly 8.5 seconds.
	*/

	/*
	* Changed lookahead buffer from dynamic array
	* using concatenation for unreading to using a fixed
	* stack-like array. 
	* lexes a ~5MB file in roughly 5.4 seconds.
	*/

	/*
	* Optimized peeking by not calling read/unread if the
	* buffer is not empty.
	* Refactoring some simple operations.
	* Preceded all match() tests with initial single character test.
	* lexes a ~5MB file in roughly 3.9 seconds.
	*/

    return 0;
}
