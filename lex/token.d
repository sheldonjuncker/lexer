module lex.token;

/**
* The enum that contains all of the token types.
* + = complete lexer support
* ~ = partial lexer support
*/
enum TokenType
{
	SlComment, 		//+
	MlComment, 		//+
	Whitespace, 	//+
	Double, 		//+ (leading +/- signs left to parser)
	Str, 			//+ (no support for hex/octal escapes)
	Ident, 			//+
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
	Eof				//Do we need this?
}

/**
* The token location class.
* Specifies all token location information for a token.
*/
class TokenLocation
{
	///The line number
	public int line;

	///The column number
	public int column;

	/**
	* Constructor.
	* @paran line The line number.
	* @param column The column number.
	*/
	this(int line, int column)
	{
		this.line = line;
		this.column = column;
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