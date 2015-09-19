
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
	//#include <winbase.h>
	#include <tchar.h>
	//#include <shlwapi.h>
	
	#if defined(CFG_BBSTDSTREAM_CLEAR_IMPLEMENTED)
		//#include <conio.h>
		//#include <cstdio>
	#endif
#else
	//#include <cstdio>
	
	#ifdef CFG_BBSTDSTREAM_STD_BINARYHACK
		#include <io.h>
		#include <fcntl.h>
	#endif
#endif

// Namespace(s):
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
			bool Open(bool rawOpen=false);
			bool Open(String path, String mode, bool fallback);
			bool ErrOpen();
			
			void Flush();
			void Clear();
			
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

// Namespace(s):
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
	bool BBStandardIOStream::Open(bool rawOpen)
	{
		if (!rawOpen && hasFileOpen())
			return false;
		
		#ifndef CFG_BBSTDSTREAM_WINNT_NATIVE_HANDLES
			if (input == FILE_STREAM_NONE)
			{
				#ifndef CFG_BBSTDSTREAM_STD_BINARYHACK
					#ifndef CFG_BBSTDSTREAM_WINNT_STD_REOPENHACK
						freopen(0, "rb", stdin);
					#else
						freopen("CONIN$", "rb", stdin);
					#endif
				#else
					_setmode(_fileno(stdin), _O_BINARY);
				#endif
				
				input = stdin;
			}
			
			if (output == FILE_STREAM_NONE)
			{
				#ifndef CFG_BBSTDSTREAM_STD_BINARYHACK
					#ifndef CFG_BBSTDSTREAM_WINNT_STD_REOPENHACK
						freopen(0, "wb", stdout);
					#else
						freopen("CONOUT$", "wb", stdout);
					#endif
				#else
					_setmode(_fileno(stdout), _O_BINARY);
				#endif
				
				output = stdout;
			}
		#else
			if (input == FILE_STREAM_NONE)
			{
				input = GetStdHandle(STD_INPUT_HANDLE);
			}
			
			if (output == FILE_STREAM_NONE)
			{
				output = GetStdHandle(STD_OUTPUT_HANDLE);
			}
			
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
	
	bool BBStandardIOStream::Open(String path, String mode, bool fallback)
	{
		if (hasFileOpen())
			return false;
		
		bool isInput = false;
		bool isOutput = false;
		bool moveToEnd = false;
		
		#ifdef CFG_BBSTDSTREAM_WINNT_NATIVE_HANDLES
			systemFile file = FILE_STREAM_NONE;
			OFSTRUCT fileInfo;
			
			memset(&fileInfo, 0, sizeof(fileInfo));
			
			fileInfo.cBytes = sizeof(fileInfo);
			
			if (mode == "r")
			{
				file = (systemFile)OpenFile((LPCSTR)path.ToCString<CHAR>(), &fileInfo, OF_READ);
				
				isInput = true;
			}
			else if (mode == "w")
			{
				file = (systemFile)OpenFile((LPCSTR)path.ToCString<CHAR>(), &fileInfo, OF_WRITE);
				
				isOutput = true;
			}
			else
			{
				bool mode_is_U = (mode == "u");
				bool mode_is_A = (mode == "a");
				bool mode_is_either = (mode_is_U || mode_is_A);
				
				if (mode_is_either)
				{
					//if (!PathFileExists((LPCTSTR)path.ToCString<TCHAR>())) // == FALSE
					if (GetFileAttributes((LPCTSTR)path.ToCString<TCHAR>()) == INVALID_FILE_ATTRIBUTES && GetLastError()==ERROR_FILE_NOT_FOUND)
					{
						file = (systemFile)OpenFile((LPCSTR)path.ToCString<CHAR>(), &fileInfo, OF_CREATE|OF_WRITE|OF_READ);
					}
					else
					{
						file = (systemFile)OpenFile((LPCSTR)path.ToCString<CHAR>(), &fileInfo, OF_WRITE|OF_READ);
					}
					
					isInput = true;
					isOutput = true;
					
					if (mode_is_A)
					{
						moveToEnd = true;
					}
				}
				else
				{
					return false;
				}
			}
			
			if (file == FILE_STREAM_NONE || (HFILE)file == HFILE_ERROR)
			{
				return false;
			}
			
			_length = (int)SetFilePointer(file, 0, NULL, FILE_END);
			
			if (moveToEnd)
			{
				_position = _length;
			}
			else
			{
				SetFilePointer(file, 0, NULL, FILE_BEGIN);
			}
		#else
			String fmode;
			
			if (mode == "r")
			{
				fmode = "rb";
				
				isInput = true;
			}
			else if (mode == "w")
			{
				fmode = "wb";
				
				isOutput = true;
			}
			else if (mode == "u")
			{
				fmode = "rb+";
				
				isInput = true;
				isOutput = true;
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
				
				isOutput = true;
				isInput = false;
			}
			
			fseek(file, 0, SEEK_END);
			
			_length = ftell(file);
			
			fseek(file, 0, SEEK_SET);
			
			_position = 0;
		#endif
		
		if (isInput)
		{
			input = file;
		}
		
		if (isOutput)
		{
			output = file;
		}
		
		if (!fallback || !Open(true))
		{
			if (input == FILE_STREAM_NONE && output == FILE_STREAM_NONE)
			{
				closeFile(file);
				
				return false;
			}
		}
		
		// Return the default response.
		return true;
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
	
	void BBStandardIOStream::Flush()
	{
		#ifndef CFG_BBSTDSTREAM_WINNT_NATIVE_HANDLES
			if (input != FILE_STREAM_NONE)
				fflush(input);
			
			if (output != FILE_STREAM_NONE)
				fflush(output);
		#endif
		
		return;
	}
	
	void BBStandardIOStream::Clear()
	{
		#ifdef CFG_BBSTDSTREAM_CLEAR_IMPLEMENTED
			system("cls"); // clrscr();
		#endif
		
		return;
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