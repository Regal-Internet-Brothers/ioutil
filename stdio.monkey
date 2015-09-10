Strict

Public

' Preprocessor related:
#If LANG = "cpp" Or LANG = "cs" ' TARGET = "stdcpp" Or TARGET = "glfw" ' Or TARGET = "ios"
	#IOUTIL_STDIO_IMPLEMENTED = True
#End

#If IOUTIL_STDIO_IMPLEMENTED
	#If HOST = "winnt"
		#If LANG = "cpp"
			#BBSTDSTREAM_WINNT_NATIVE_HANDLES = True
			'#BBSTDSTREAM_STD_BINARYHACK = True
			'#BBSTDSTREAM_WINNT_STD_REOPENHACK = True
		#End
	#End
	
	' Imports (Public):
	Import brl.stream
	
	' Imports (Private):
	Private
	
	Import brl.gametarget
	Import brl.databuffer
	
	#If LANG <> "cpp"
		Import brl.filestream
	#End
	
	' Native language imports:
	Import "native/stdio.${LANG}"
	
	Public
	
	' Classes (External):
	Extern
	
	#If LANG = "cpp"
		Class BBStandardIOStream Extends BBStream = "external_ioutil::BBStandardIOStream"
	#Else
		Class BBStandardIOStream Extends BBStream
	#End
			' Methods:
			Method Open:Bool()
			
			#If LANG = "cpp"
				Method Open:Bool(Path:String, Mode:String, Fallback:Bool=False)
				Method ErrOpen:Bool()
			#End
			
			Method Length:Int()
			Method Position:Int()
			Method Seek:Int(Position:Int)
		End
	
	Public
	
	' Classes (Monkey):
	Class StandardIOStream Extends Stream
		' Functions (Protected):
		Protected
		
		Function OpenNativeStream:BBStandardIOStream(ErrorInfo:Bool=False)
			Local StandardStream:= New BBStandardIOStream()
			
				If (Not ErrorInfo) Then
					StandardStream.Open()
			#If LANG = "cpp"
				Else
					StandardStream.ErrOpen()
			#End
				Endif
			
			Return StandardStream
		End
		
		Function OpenNativeStream:BBStream(Path:String, Mode:String, Fallback:Bool=False)
			#If LANG = "cpp"
				Local StandardStream:= New BBStandardIOStream()
				
				Local RealMode:= Mode
				
				#If Not BBSTDSTREAM_WINNT_NATIVE_HANDLES
					If (RealMode = "a") Then
						RealMode = "u"
					Endif
				#End
				
				If (Not StandardStream.Open(Path, RealMode, Fallback)) Then
					Return Null
				Endif
				
				#If Not BBSTDSTREAM_WINNT_NATIVE_HANDLES
					If (Mode = "a") Then
						StandardStream.Seek(StandardStream.Length())
					Endif
				#End
				
				Return StandardStream
			#Elseif LANG = "cs"
				Local FStream:= New BBFileStream()
				
				FStream.Open(Path, Mode)
				
				Return FStream
			#End
		End
		
		Public
		
		' Constructor(s):
		Method New(ErrorInfo:Bool=False)
			NativeStream = OpenNativeStream(ErrorInfo)
		End
		
		Method New(Path:String, Mode:String, Fallback:Bool=False)
			NativeStream = OpenNativeStream(Path, Mode, Fallback)
		End
		
		' Destructor(s):
		Method Close:Void()
			If (NativeStream = Null) Then
				Return
			Endif
			
			NativeStream.Close()
			
			NativeStream = Null
			
			Return
		End
		
		' Methods:
		Method Seek:Int(Position:Int)
			Return NativeStream.Seek(Position)
		End
		
		Method Read:Int(Buffer:DataBuffer, Offset:Int, Count:Int)
			Return NativeStream.Read(Buffer, Offset, Count)
		End
		
		Method Write:Int(Buffer:DataBuffer, Offset:Int, Count:Int)
			Return NativeStream.Write(Buffer, Offset, Count)
		End
		
		' Properties:
		Method Eof:Int() Property
			Return NativeStream.Eof()
		End
		
		Method Length:Int() Property
			Return NativeStream.Length()
		End
		
		Method Position:Int() Property
			Return NativeStream.Position()
		End
		
		' Fields (Protected):
		Protected
		
		Field NativeStream:BBStream ' BBStandardIOStream
		
		Public
	End
#End