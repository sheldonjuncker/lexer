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
	//lexes a ~5MB file in roughly 8.5 seconds

    return 0;
}
