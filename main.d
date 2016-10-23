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
	//Print out all tokens
	/*
	foreach(Token t; l.tokens)
	{
		writeln(std.conv.to!string(t.type) ~ ": " ~ t.lexeme);
	}
	*/

    return 0;
}
