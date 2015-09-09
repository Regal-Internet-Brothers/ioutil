
/*
	Based on the "filestream.h" and "filestream.cpp" module(s), found in "modules/brl/native/filestream.cpp".
*/

// ***** standardiostream.h *****

//#include <cstdio>

// Classes:
class BBStandardIOStream : public BBStream
{
	public:
		// Constant variable(s):
		static FILE* FILE_STREAM_NONE;
		
		// Constructor(s):
		BBStandardIOStream();
		
		// Destructor(s):
		~BBStandardIOStream();
		
		void Close();
		
		// Methods:
		bool Open();
		bool Open(String path, String mode);
		bool ErrOpen();
		
		int Eof(); // const;
		int Length(); // const;
		int Position(); // const;
		
		int Seek(int position);
		
		int Read(BBDataBuffer* buffer, int offset, int count);
		int Write(BBDataBuffer* buffer, int offset, int count);
	protected:
		// Methods (Protected):
		bool fileOpen() const;
		
		bool inputError() const;
		bool outputError() const;
		bool fileError() const;
		
		// Fields (Protected):
		FILE* input;
		FILE* output;
		
		int _position;
		int _length;
};

// ***** standardiostream.cpp *****

// Classes:

// BBStandardIOStream:

// Constant variable(s):
FILE* BBStandardIOStream::FILE_STREAM_NONE = 0; // nullptr; // NULL;

// Constructor(s):
BBStandardIOStream::BBStandardIOStream()
	: input(FILE_STREAM_NONE), output(FILE_STREAM_NONE), _position(0), _length(0) { /* Nothing so far. */ }

// Destructor(s):
BBStandardIOStream::~BBStandardIOStream()
{
	if (input != FILE_STREAM_NONE)
		fclose(input);
	
	if (output != FILE_STREAM_NONE)
		fclose(output);
}

void BBStandardIOStream::Close()
{
	// Check for errors:
	if (input == FILE_STREAM_NONE && output == FILE_STREAM_NONE)
		return;
	
	if (input != stdin)
		fclose(input);
	
	if (input != stdout)
		fclose(output);
	
	input = FILE_STREAM_NONE;
	output = FILE_STREAM_NONE;
	
	_position = 0;
	_length = 0;
	
	return;
}

// Methods (Public):
bool BBStandardIOStream::Open()
{
	if (fileOpen())
		return false;
	
	//freopen(0, "rb", stdin);
	//freopen(0, "wb", stdout);
	
	//freopen("CONOUT$", "wb", stdout);
	//freopen("CONIN$", "rb", stdin);
	
	input = stdin;
	output = stdout;
	
	// Return the default response.
	return true;
}

bool BBStandardIOStream::Open(String path, String mode)
{
	if (fileOpen())
		return false;
	
	String fmode;
	bool isInput = false;
	
	if (mode == "r")
	{
		fmode = "rb";
		
		isInput = true;
	}
	else if (mode == "w")
	{
		fmode = "wb";
	}
	else if (mode == "u")
	{
		fmode = "rb+";
		
		isInput = true;
	}
	else
	{
		return false;
	}
	
	BBGame* game = BBGame::Game();
	
	FILE* file = (FILE*)game->OpenFile(path, fmode);
	
	if (file == FILE_STREAM_NONE && mode == "u")
	{
		file = game->OpenFile(path, "wb+");
	
		if (file == FILE_STREAM_NONE)
			return false;
		
		isInput = false;
	}
	
	fseek(file, 0, SEEK_END);
	
	_length = ftell(file);
	
	fseek(file, 0, SEEK_SET);
	
	_position = 0;
	
	if (isInput)
	{
		input = file;
	}
	else
	{
		output = file;
	}
	
	// Return the default response.
	return true;
}

bool BBStandardIOStream::ErrOpen()
{
	if (fileOpen())
		return false;
	
	input = stderr;
	output = stderr;
	
	// Return the default response.
	return true;
}

int BBStandardIOStream::Eof() // const
{
	// Check for errors:
	if (inputError())
		return -1;
	
	return (_position == _length);
}

int BBStandardIOStream::Length() // const
{
	return _length;
}

int BBStandardIOStream::Position() // const
{
	return _position;
}

int BBStandardIOStream::Seek(int position)
{
	// Check for errors:
	if (inputError())
		return 0;
	
	fseek(input, _position, SEEK_SET);
	
	_position = ftell(input);
	
	return _position;
}

int BBStandardIOStream::Read(BBDataBuffer* buffer, int offset, int count)
{
	// Check for errors:
	if (inputError())
		return 0;
	
	int bytesRead = fread(buffer->WritePointer(offset), 1, count, input);
	
	_position += bytesRead;
	
	return bytesRead;
}

int BBStandardIOStream::Write(BBDataBuffer* buffer, int offset, int count)
{
	// Check for errors:
	if (outputError())
		return 0;
	
	int bytesWritten = fwrite(buffer->ReadPointer(offset), 1, count, output);
	
	_position += bytesWritten;
	
	if (_position > _length)
		_length = _position; // max();
	
	return bytesWritten;
}

// Methods (Protected):
bool BBStandardIOStream::fileOpen() const
{
	return (input != FILE_STREAM_NONE || output != FILE_STREAM_NONE);
}

bool BBStandardIOStream::inputError() const
{
	return (input == FILE_STREAM_NONE);
}

bool BBStandardIOStream::outputError() const
{
	return (output == FILE_STREAM_NONE);
}

bool BBStandardIOStream::fileError() const
{
	return (inputError() || outputError());
}
