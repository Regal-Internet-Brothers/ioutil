
/*
	Based on the "filestream.h" and "filestream.cpp" module(s), found in "modules/brl/native/filestream.cpp".
*/

// ***** standardiostream.h *****

// Preprocessor related:
#define FILE_STREAM_NONE 0

// Includes:
#if defined(CFG_BBSTDSTREAM_WINNT_NATIVE_HANDLES) // && defined(_WIN32)
	#define WIN32_LEAN_AND_MEAN
	
	#include <windows.h>
#else
	//#include <cstdio>
#endif

// Namespaces:
namespace external_ioutil
{
	// Typedefs:
	#ifdef CFG_BBSTDSTREAM_WINNT_NATIVE_HANDLES
		typedef HANDLE systemFile;
	#else
		typedef FILE* systemFile;
	#endif
	
	/*
		enum file_meta : systemFile
		{
			FILE_STREAM_NONE = 0,
		};
	*/
	
	// Classes:
	class BBStandardIOStream : public BBStream
	{
		public:
			// Functions:
			
			// This may be used to close a native 'systemFile' handle.
			static void closeFile(systemFile file);
			
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
			bool hasFileOpen() const;
			
			bool inputError() const;
			bool outputError() const;
			bool fileError() const;
			
			// Fields (Protected):
			systemFile input;
			systemFile output;
			
			int _position;
			int _length;
	};
}
// ***** standardiostream.cpp *****

// Namespaces:
namespace external_ioutil
{
	// Classes:
	
	// BBStandardIOStream:
	
	// Functions:
	
	// This may be used to close a native 'systemFile' handle.
	void BBStandardIOStream::closeFile(systemFile file)
	{
		#ifndef CFG_BBSTDSTREAM_WINNT_NATIVE_HANDLES
			fclose(file);
		#else
			CloseHandle(file);
		#endif
		
		return;
	}
	
	// Constructor(s):
	BBStandardIOStream::BBStandardIOStream()
		: input(FILE_STREAM_NONE), output(FILE_STREAM_NONE), _position(0), _length(0) { /* Nothing so far. */ }
	
	// Destructor(s):
	BBStandardIOStream::~BBStandardIOStream()
	{
		if (input != FILE_STREAM_NONE)
			closeFile(input);
		
		if (output != FILE_STREAM_NONE)
			closeFile(output);
	}
	
	void BBStandardIOStream::Close()
	{
		// Check for errors:
		if (!hasFileOpen()) // (input == FILE_STREAM_NONE && output == FILE_STREAM_NONE)
			return;
		
		#ifndef CFG_BBSTDSTREAM_WINNT_NATIVE_HANDLES
			if (input != stdin)
		#else
			if (input != GetStdHandle(STD_INPUT_HANDLE))
		#endif
			{
				closeFile(input);
			}
			
		if
		(
			(output != input)
			
			#ifndef CFG_BBSTDSTREAM_WINNT_NATIVE_HANDLES
				&& (output != stdout && output != stderr)
			#else
				&& (output != GetStdHandle(STD_OUTPUT_HANDLE) && output != GetStdHandle(STD_ERROR_HANDLE))
			#endif
		)
		{
			closeFile(output);
		}
		
		input = FILE_STREAM_NONE;
		output = FILE_STREAM_NONE;
		
		_position = 0;
		_length = 0;
		
		return;
	}
	
	// Methods (Public):
	bool BBStandardIOStream::Open()
	{
		if (hasFileOpen())
			return false;
		
		//freopen(0, "rb", stdin);
		//freopen(0, "wb", stdout);
		
		//freopen("CONOUT$", "wb", stdout);
		//freopen("CONIN$", "rb", stdin);
		
		#ifndef CFG_BBSTDSTREAM_WINNT_NATIVE_HANDLES
			input = stdin;
			output = stdout;
		#else
			input = GetStdHandle(STD_INPUT_HANDLE);
			output = GetStdHandle(STD_OUTPUT_HANDLE);
			
			if
			(
				input == INVALID_HANDLE_VALUE || input == FILE_STREAM_NONE ||
				output == INVALID_HANDLE_VALUE || output == FILE_STREAM_NONE
			)
			{
				Close();
				
				return false;
			}
		#endif
		
		// Return the default response.
		return true;
	}
	
	bool BBStandardIOStream::Open(String path, String mode)
	{
		#ifdef CFG_BBSTDSTREAM_WINNT_NATIVE_HANDLES
			return false;
		#else
			if (hasFileOpen())
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
			
			systemFile file = (systemFile)game->OpenFile(path, fmode);
			
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
		#endif
	}
	
	bool BBStandardIOStream::ErrOpen()
	{
		if (hasFileOpen())
			return false;
		
		#ifndef CFG_BBSTDSTREAM_WINNT_NATIVE_HANDLES
			input = stderr;
			output = input; // stderr;
		#else
			input = GetStdHandle(STD_ERROR_HANDLE);
			output = input;
		#endif
		
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
		
		#ifndef CFG_BBSTDSTREAM_WINNT_NATIVE_HANDLES
			fseek(input, position, SEEK_SET);
			
			_position = ftell(input);
		#else
			_position = (int)SetFilePointer(input, position, NULL, FILE_BEGIN);
		#endif
		
		return _position;
	}
	
	int BBStandardIOStream::Read(BBDataBuffer* buffer, int offset, int count)
	{
		// Check for errors:
		if (inputError())
			return 0;
		
		#ifndef CFG_BBSTDSTREAM_WINNT_NATIVE_HANDLES
			int bytesRead = fread(buffer->WritePointer(offset), 1, count, input);
		#else
			int bytesRead = 0;
			
			DWORD __winnt_bytesRead = 0;
			
			if (ReadFile(input, buffer->WritePointer(offset), (DWORD)count, &__winnt_bytesRead, NULL)) // == TRUE
			{
				bytesRead = (int)__winnt_bytesRead; // count;
			}
			else
			{
				return 0; // bytesRead; // __winnt_bytesRead;
			}
		#endif
		
		_position += bytesRead;
		
		return bytesRead;
	}
	
	int BBStandardIOStream::Write(BBDataBuffer* buffer, int offset, int count)
	{
		// Check for errors:
		if (outputError())
			return 0;
		
		#ifndef CFG_BBSTDSTREAM_WINNT_NATIVE_HANDLES
			int bytesWritten = fwrite(buffer->ReadPointer(offset), 1, count, output);
		#else
			int bytesWritten = 0;
			
			DWORD __winnt_bytesWritten = 0;
			
			if (WriteFile(output, buffer->ReadPointer(offset), (DWORD)count, &__winnt_bytesWritten, NULL)) // == TRUE
			{
				bytesWritten = (int)__winnt_bytesWritten;
			}
			else
			{
				return 0;
			}
		#endif
		
		_position += bytesWritten;
		
		if (_position > _length)
			_length = _position; // max();
		
		return bytesWritten;
	}
	
	// Methods (Protected):
	bool BBStandardIOStream::hasFileOpen() const
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
}