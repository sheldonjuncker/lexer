module lex.lexer;
import lex.token;
import core.stdc.limits;
import std.algorithm;
import std.stdio;
import std.file;

/**
* The lexer class.
* Reads a file and outputs a list of tokens.
*/
class Lexer
{
	///The file to read from
	File file;

	///Specifies whether to ignore whitespace
	bool ignoreWhitespace = true;

	///Specifies whether to ignore comments
	bool ignoreComments = true;

	///Current line number
	int line;

	///Current column
	int column;

	///List of tokens read
	Token[] tokens;

	///Unread characters (up to 4 max)
	int[4] buffer;

	//Current position of buffer (cannot exceed 4)
	int buffer_index;

	/**
	* Reads a character from the file.
	*/
	int read()
	{
		//Check lookahead characters
		if(buffer_index)
			return buffer[buffer_index--];

		//Read from file
		else
			return getc(this.file.getFP());
	}

	/**
	* Unreads a character back to the file.
	* @param int The character to unread.
	*/
	void unread(int c)
	{
		if(buffer_index == 4)
			throw new FileException("Overflowed lookahead buffer!");

		else
			buffer[++buffer_index] = c;
	}

	/**
	* Peeks at the next character.
	* Does so by reading and unreading.
	*/
	int peek()
	{
		if(buffer_index)
			return buffer[buffer_index];
		
		else
		{
			int c = read();
			unread(c);
			return c;
		}
	}

	/**
	* Matches next characters in file against string.
	* @param match The string to match.
	* @note Does not change the characters in the file stream.
	* @note Can be modified to use a fixed array buffer for
	* optimization.
	*/
	bool matches(string match)
	{
		//Read characters to match
		char[] buf;

		for(int i=0; i<match.length; i++)
		{
			int c = read();
			if(c == EOF)
				break;
			else
				buf ~= cast(char) c;
		}
		
		//Perform the match
		bool test = (match == buf);

		//Unread the characters
		reverse(buf);
		foreach(char c; buf)
		{
			unread(c);
		}

		return test;
	}

	/**
	* Tests if a character is the start of an identifier.
	* @param c The character to test.
	*/
	bool isIdent(int c)
	{
		return ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c == '_'));
	}

	/**
	* Tests if a character is a number.
	* @param c The character to test.
	*/
	bool isNumber(int c)
	{
		return (c >= '0' && c <= '9');
	}

	/**
	* Tests to see if a character is whitespace.
	* @param c The character to test.
	*/
	bool isWhitespace(int c)
	{
		return (c == ' ' || c == '\t' || c == '\n' || c == '\r');
	}

	/**
	* Updates location information based on character read.
	* @param c The character read.
	*/
	void updateLocation(int c)
	{
		if(c == '\n')
		{
			this.column = 0;
			this.line++;
		}

		else
		{
			this.column++;
		}
	}

	/**
	* Reads a character and updates location.
	*/
	int consume()
	{
		int c = this.read();
		this.updateLocation(c);
		return c;
	}

	/**
	* Adds a token to the token list.
	* @param token The token to add.
	*/
	void addToken(Token token)
	{
		//Ignore comments if specified to do so
		if(ignoreComments && (token.type == TokenType.SlComment || token.type == TokenType.MlComment))
			return;

		//Ignore whitespace if specified to do so
		if(ignoreWhitespace && token.type == TokenType.Whitespace)
			return;

		this.tokens ~= token;
	}

	/**
	* Adds a token based on string and consumes corresponding input.
	* @param type The token type.
	* @paran lexeme The token string.
	*/
	void addStringToken(TokenType type, string lexeme)
	{
		//Consume entire lexeme
		for(int i=0; i<lexeme.length; i++)
			consume();

		//Add token
		Token token = new Token(type, lexeme, new TokenLocation(line, column));
		addToken(token);
	}

	/**
	* Reads a string.
	* Strings support the standard escape sequenes.
	* And they can span multiple lines.
	*/
	void readString()
	{
		//Consume first quote
		consume();

		//Storage for string
		string str;

		//While we don't see a " keep reading input
		while(peek() != '"')
		{
			//Consume the character
			int c = consume();

			//Check for EOF
			if(c == EOF)
			{
				throw new FileException("Reached end of file in string.");
			}

			//Check for escaping
			else if(c == '\\')
			{
				//Consume next character regardless
				int escaped = consume();

				//Can be anything but EOF
				if(escaped == EOF)
				{
					throw new FileException("Reached end of file in string.");
				}

				//Check for special escape characters
				//Note that we're not supporting hex or octal escapes
				if(escaped == 'n')
					c = '\n';
				else if(escaped == 'r')
					c = '\r';
				else if(escaped == 't')
					c = '\t';
				else if(escaped == 'b')
					c = '\b';
				else if(escaped == 'a')
					c = '\a';
				else if(escaped == 'v')
					c = '\v';
				else if(escaped == 'f')
					c = '\f';
				else if(escaped == '0')
					c = '\0';
				else
					c = escaped;
			}

			//Add the character
			str ~= cast(char) c;
		}

		//Consume end quote
		consume();

		//Add string token
		TokenLocation location = new TokenLocation(line, column);
		Token token = new Token(TokenType.Str, str, location);
		addToken(token);
	}

	/**
	* Reads a character.
	*/
	void readChar()
	{
		//Consume '
		consume();

		//Get next character
		int c = consume();

		//Check for empty character
		if(c == '\'')
		{
			throw new FileException("Invalid empty character.");
		}

		//Verify next character is a '
		if(peek() != '\'')
		{
			throw new FileException("Unterminated character literal.");
		}

		//Consume the ending '
		consume();

		//Add char token
		string str;
		str ~= c;
		TokenLocation location = new TokenLocation(line, column);
		Token token = new Token(TokenType.Str, str, location);
		addToken(token);
	}

	/**
	* Reads a multi-line comment.
	*/
	void readMlComment()
	{
		//Consume /*
		consume(); consume();

		int commentDepth = 1;

		//Allows for nested comments.
		while(commentDepth)
		{
			if(peek() == EOF)
			{
				throw new FileException("Reached end of file in comment.");
			}

			else if(matches("*/"))
			{
				consume(); consume();
				commentDepth--;
			}

			else if(matches("/*"))
			{
				commentDepth++;
				consume(); consume();
			}

			else
			{
				consume();
			}
		}

		//Add comment
		TokenLocation location = new TokenLocation(line, column);
		addToken(new Token(TokenType.MlComment, "/*...*/", location));
	}

	/**
	* Reads a single-line comment.
	*/
	void readSlComment()
	{
		//Consume //
		consume(); consume();

		//Ignore till end of line or file
		while(peek() != '\n' && peek() != EOF)
		{
			consume();
		}

		//Add comment
		TokenLocation location = new TokenLocation(line, column);
		addToken(new Token(TokenType.SlComment, "//...", location));
	}

	/**
	* Reads an identifier.
	*/
	void readIdent()
	{
		string ident;
		
		//Consume first character
		//Some bug here
		ident ~= cast(char) consume();

		//Keep consuming while we see an identifier character or number
		while(isIdent(peek()) || isNumber(peek()))
		{
			ident ~= consume();
		}

		TokenType type = TokenType.Ident;

		//Check for keywords
		if(ident == "if")
			type = TokenType.If;
		else if(ident == "else")
			type = TokenType.Else;
		else if(ident == "while")
			type = TokenType.While;
		else if(ident == "break")
			type = TokenType.Break;
		else if(ident == "continue")
			type = TokenType.Continue;
		else if(ident == "class")
			type = TokenType.Class;
		else if(ident == "return")
			type = TokenType.Return;

		//Add token
		TokenLocation location = new TokenLocation(line, column);
		addToken(new Token(type, ident, location));
	}

	/**
	* Reads a number.
	*/
	void readNumber()
	{
		string num;
		
		//Consume first character
		num ~= consume();

		//Keep consuming while we see an identifier character or number
		while(isNumber(peek()))
		{
			num ~= consume();
		}

		//Check for floating point numbers
		if(peek() == '.')
		{
			consume();

			//Check for numbers
			if(isNumber(peek()))
			{
				num ~= ".";
				//Read the decimal part
				while(isNumber(peek))
				{
					num ~= consume();
				}
			}

			//Unread the .
			else
			{
				unread('.');
			}
		}

		//Check for exponent
		if(peek() == 'e' || peek() == 'E')
		{
			//Sign and exponent
			int sign, e;
			
			e = consume();

			if(peek() == '-' || peek() == '+')
				sign = consume();
			
			//Check for number
			if(isNumber(peek()))
			{
				num ~= cast(char) e;
				if(sign)
					num ~= cast(char) sign;
				
				while(isNumber(peek()))
				{
					num ~= consume();
				}
			}

			//Put the -/+ and e/E back
			else
			{
				if(sign)
					unread(sign);
				unread(e);
			}
		}

		//Add token
		TokenLocation location = new TokenLocation(line, column);
		addToken(new Token(TokenType.Double, num, location));
	}

	/**
	* Reads whitespace.
	*/
	void readWhitespace()
	{
		//Consume all whitespace
		while(isWhitespace(peek()))
		{
			consume();
		}

		//Add token
		TokenLocation location = new TokenLocation(line, column);
		addToken(new Token(TokenType.Whitespace, " ", location));		
	}

	/**
	* Lexes all input.
	*/
	void lex()
	{
		//Loop through each character of input
		int c;
		while((c = peek()) != EOF)
		{
			//Test for each type of token

			//String
			if(c == '"')
				readString();

			//Character
			else if(c == '\'')
				readChar();
			
			//Single-line comment
			else if(this.matches("//"))
				readSlComment();
			
			//Multi-line comment
			else if(this.matches("/*"))
				readMlComment();

			//Read identifier
			else if(isIdent(c))
				readIdent();

			//Read a number
			else if(isNumber(c))
				readNumber();
			
			//Read whitespace
			else if(isWhitespace(c))
				readWhitespace();

			/**
			* Multiple character matches.
			* Must come before single character operators
			* to resolve ambiguity.
			* The first redundant test is for optimization.
			*/
			else if(c == '=' && matches("=="))
				addStringToken(TokenType.Equals, "==");
			else if(c == '+' && matches("++"))
				addStringToken(TokenType.Inc, "++");
			else if(c == '-' && matches("--"))
				addStringToken(TokenType.Dec, "--");
			else if(c == '>' && matches(">="))
				addStringToken(TokenType.Gte, ">=");
			else if(c == '<' && matches("<="))
				addStringToken(TokenType.Lte, "<=");
			else if(c == '.' && matches(".."))
				addStringToken(TokenType.Range, "..");
			else if(c == '&' && matches("&&"))
				addStringToken(TokenType.And, "&&");
			else if(c == '|' && matches("||"))
				addStringToken(TokenType.Or, "||");

			/**
			* Single character tokens
			*/
			else if(c == '=')
				addStringToken(TokenType.Assign, "=");
			else if(c == '*')
				addStringToken(TokenType.Star, "*");
			else if(c == '^')
				addStringToken(TokenType.Pow, "^");
			else if(c == '/')
				addStringToken(TokenType.Slash, "/");
			else if(c == '%')
				addStringToken(TokenType.Percent, "%");
			else if(c == '+')
				addStringToken(TokenType.Plus, "+");
			else if(c == '-')
				addStringToken(TokenType.Minus, "-");
			//Some special stuff for fp numbers like .25
			else if(c == '.')
			{
				consume();
				//Is it a floating point number?
				if(isNumber(peek()))
				{
					//Put a 0 in front of the . and try again. :)
					unread('.');
					unread('0');
					continue;
				}

				//Just a .
				else
				{
					unread('.');
					addStringToken(TokenType.Dot, ".");
				}
			}	
			else if(c == '>')
				addStringToken(TokenType.Gt, ">");
			else if(c == '<')
				addStringToken(TokenType.Lt, "<");
			else if(c == ':')
				addStringToken(TokenType.Colon, ":");
			else if(c == ';')
				addStringToken(TokenType.Semi, ";");
			else if(c == ',')
				addStringToken(TokenType.Comma, ",");
			else if(c == '!')
				addStringToken(TokenType.Not, "!");
			else if(c == '(')
				addStringToken(TokenType.Lprn, "(");
			else if(c == ')')
				addStringToken(TokenType.Rprn, ")");
			else if(c == '[')
				addStringToken(TokenType.Lbrk, "[");
			else if(c == ']')
				addStringToken(TokenType.Rbrk, "]");
			else if(c == '{')
				addStringToken(TokenType.Lbrc, "{");
			else if(c == '}')
				addStringToken(TokenType.Rbrc, "}");

			//Error
			else
			{
				writeln(c);
				throw new FileException("Unrecognized character '" ~ cast(char) c ~ "'");
			}
			
		}
	}

	/**
	* Constructor.
	* @param filename The name of the file to open for lexing.
	*/
	this(string filename)
	{
		if(exists(filename))
			this.file.open(filename);
		else
			throw new FileException("The file could not be opened.");
	}
}