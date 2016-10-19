import std.stdio;
import std.conv;
import lex.lexer;
import lex.token;

int main(string[] argv)
{
	//Open a file with the lexer
	Lexer l = new Lexer("test.txt");

	//Lex all input
	l.lex();

	//Print out all tokens
	foreach(Token t; l.tokens)
	{
		writeln(std.conv.to!string(t.type) ~ ": " ~ t.lexeme);
	}

    return 0;
}
