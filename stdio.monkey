Strict

Public

' Preprocessor related:
#If TARGET = "stdcpp" Or TARGET = "glfw" ' Or TARGET = "ios"
	#IOUTIL_STDIO_IMPLEMENTED = True
#End

#If IOUTIL_STDIO_IMPLEMENTED
	#If HOST = "winnt"
		#BBSTDSTREAM_WINNT_NATIVE_HANDLES = True
	#End
	
	' Imports (Public):
	Import brl.stream
	
	' Imports (Private):
	Private
	
	Import brl.gametarget
	Import brl.databuffer
	
	' Native language imports:
	Import "native/stdio.${LANG}"
	
	Public
	
	' Classes (External):
	Extern
	
	Class BBStandardIOStream Extends BBStream = "external_ioutil::BBStandardIOStream"
		' Methods:
		Method Open:Bool()
		Method Open:Bool(Path:String, Mode:String)
		Method ErrOpen:Bool()
		
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
			Else
				StandardStream.ErrOpen()
			Endif
			
			Return StandardStream
		End
		
		Function OpenNativeStream:BBStandardIOStream(Path:String, Mode:String)
			Local StandardStream:= New BBStandardIOStream()
			
			Local RealMode:= Mode
			
			If (RealMode = "a") Then
				RealMode = "u"
			Endif
			
			If (Not StandardStream.Open(Path, RealMode)) Then
				Return Null
			Endif
			
			If (Mode = "a") Then
				StandardStream.Seek(StandardStream.Length())
			Endif
			
			Return StandardStream
		End
		
		Public
		
		' Constructor(s):
		Method New(ErrorInfo:Bool=False)
			NativeStream = OpenNativeStream(ErrorInfo)
		End
		
		Method New(Path:String, Mode:String)
			NativeStream = OpenNativeStream(Path, Mode)
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
		
		Field NativeStream:BBStandardIOStream
		
		Public
	End
#End