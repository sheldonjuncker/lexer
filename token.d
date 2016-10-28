module lexer.token;
import std.conv;

/**
* The enum that contains all of the token types.
* + = complete lexer support
* ~ = partial lexer support
* - = no lexer support
*/
enum TokenType
{
	SlComment, 		//+
	MlComment, 		//+
	Whitespace, 	//+
	Double, 		//+ (leading +/- signs left to parser)
	Str, 			//+ (no support for hex/octal escapes)
	Ident, 			//+
	Var				//+
	If, 			//+
	Else, 			//+
	While, 			//+
	Break, 			//+
	Continue, 		//+
	Return, 		//+
	Class, 			//+
	Plus,			//+
	Minus,			//+
	Star, 			//+
	Pow,			//+
	Slash, 			//+
	Percent, 		//+
	Assign,			//+
	Equals, 		//+
	Not, 			//+
	Inc, 			//+
	Dec, 			//+
	Gt, 			//+
	Lt, 			//+
	Gte, 			//+
	Lte, 			//+
	And, 			//+
	Or, 			//+
	Xor,			//-
	Dot, 			//+
	Comma,			//+
	Lprn,			//+
	Rprn,			//+
	Lbrc,			//+
	Rbrc,			//+
	Lbrk,			//+
	Rbrk,			//+
	Range,			//+
	Colon,			//+
	Semi,			//+
	Eof				//+
}

/**
* The token location class.
* Specifies all token location information for a token.
*/
class TokenLocation
{
	///The file
	string file;

	///The line number
	int line;

	///The column number
	int column;

	/**
	* Constructor.
	* @paran line The line number.
	* @param column The column number.
	*/
	this(int line, int column, string file="")
	{
		this.file = file;
		this.line = line;
		this.column = column;
	}

	/**
	* Converts the token to a string representation.
	* Used in error messages.
	*/
	override string toString()
	{
		return "file " ~ to!string(file) ~ ", line " ~ to!string(line) ~ ", column " ~ to!string(column);
	}
}

/**
* The token class.
* Represents a token from the input stream.
*/
class Token
{
	///Type of token
	public TokenType type;

	///String token
	public string lexeme;

	///Line number of token
	public TokenLocation location;

	/**
	* Constructor.
	* @param type The type of token.
	* @param lexeme The string of the token.
	* @param location The location of the token.
	*/
	this(TokenType type, string lexeme, TokenLocation location)
	{
		this.type = type;
		this.lexeme = lexeme;
		this.location = location;
	}

	/**
	* Default constructor.
	* Uses default initialization.
	*/
	this()
	{
		
	}
}