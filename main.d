import std.stdio;
import std.conv;
import lex.lexer;
import lex.token;

int main(string[] argv)
{
	Lexer l = new Lexer("test.txt");
	l.lex();

	foreach(Token t; l.tokens)
	{
		writeln(std.conv.to!string(t.type) ~ ": " ~ t.lexeme);
	}

    return 0;
}
