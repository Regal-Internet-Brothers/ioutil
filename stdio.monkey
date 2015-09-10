Strict

Public

' Preprocessor related:
#If LANG = "cpp" Or LANG = "cs" ' TARGET = "stdcpp" Or TARGET = "glfw" ' Or TARGET = "ios"
	#IOUTIL_STDIO_IMPLEMENTED = True
#End

#If IOUTIL_STDIO_IMPLEMENTED
	#If LANG = "cpp"
		#If HOST = "winnt"
			#BBSTDSTREAM_WINNT_NATIVE_HANDLES = True
			'#BBSTDSTREAM_STD_BINARYHACK = True
			'#BBSTDSTREAM_WINNT_STD_REOPENHACK = True
		#End
		
		#BBSTDSTREAM_FLUSH_IMPLEMENTED = True
	#End
	
	' Imports (Public):
	Import errors
	
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
			
			#If BBSTDSTREAM_FLUSH_IMPLEMENTED
				Method Flush:Void()
			#End
			
			Method Length:Int()
			Method Position:Int()
			Method Seek:Int(Position:Int)
		End
	
	Public
	
	' Classes (Monkey):
	Class StandardIOStream Extends Stream
		' Constructor(s) (Public):
		
		' The 'ErrorInfo' argument should only be changed with
		' full understanding of the target it is used on.
		' If unsure, do not specify an argument.
		Method New(ErrorInfo:Bool=False)
			OpenNativeStream(ErrorInfo)
		End
		
		Method New(Path:String, Mode:String, Fallback:Bool=False)
			OpenNativeStream(Path, Mode, Fallback)
		End
		
		' Constructor(s) (Protected):
		Protected
		
		Method OpenNativeStream:Void(ErrorInfo:Bool=False)
			Local StandardStream:= New BBStandardIOStream()
			
				If (Not ErrorInfo) Then
					If (Not StandardStream.Open()) Then
						Throw New InvalidOpenOperation(Self)
					Endif
			#If LANG = "cpp"
				Else
					If (Not StandardStream.ErrOpen()) Then
						Throw New InvalidOpenOperation(Self)
					Endif
			#End
					Throw New UnsupportedStreamOperation(Self)
				Endif
			
			RealHandle = StandardStream
			
			Return
		End
		
		Method OpenNativeStream:Void(Path:String, Mode:String, Fallback:Bool=False)
			#If LANG = "cpp"
				Local StandardStream:= New BBStandardIOStream()
				
				Local RealMode:= Mode
				
				#If Not BBSTDSTREAM_WINNT_NATIVE_HANDLES
					If (RealMode = "a") Then
						RealMode = "u"
					Endif
				#End
				
				If (Not StandardStream.Open(Path, RealMode, Fallback)) Then
					Throw New InvalidOpenOperation(Self)
				Endif
				
				#If Not BBSTDSTREAM_WINNT_NATIVE_HANDLES
					If (Mode = "a") Then
						StandardStream.Seek(StandardStream.Length())
					Endif
				#End
				
				RealHandle = StandardStream
			#Elseif LANG = "cs"
				Local FStream:= New BBFileStream()
				
				If (Not FStream.Open(Path, Mode)) Then
					Throw New InvalidOpenOperation(Self)
				Endif
				
				NativeStream = FStream
			#End
		End
		
		Public
		
		' Destructor(s):
		Method Close:Void()
			If (NativeStream = Null) Then
				Return
			Endif
			
			If (RealHandle <> NativeStream And RealHandle <> Null) Then
				RealHandle.Close()
			Endif
			
			NativeStream.Close()
			
			NativeStream = Null
			RealHandle = Null
			
			Return
		End
		
		' Methods:
		Method Flush:Void()
			#If BBSTDSTREAM_FLUSH_IMPLEMENTED
				RealHandle.Flush()
			#End
			
			Return
		End
		
		Method Seek:Int(Position:Int)
			Return NativeStream.Seek(Position)
		End
		
		Method Read:Int(Buffer:DataBuffer, Offset:Int, Count:Int)
			Return NativeStream.Read(Buffer, Offset, Count)
		End
		
		Method Write:Int(Buffer:DataBuffer, Offset:Int, Count:Int)
			Return NativeStream.Write(Buffer, Offset, Count)
		End
		
		' Properties (Public):
		Method Eof:Int() Property
			Return NativeStream.Eof()
		End
		
		Method Length:Int() Property
			Return NativeStream.Length()
		End
		
		Method Position:Int() Property
			Return NativeStream.Position()
		End
		
		' Properties (Protected):
		Protected
		
		Method RealHandle:BBStandardIOStream() Property
			Return Self._RealHandle
		End
		
		Method RealHandle:Void(Input:BBStandardIOStream) Property
			Self._RealHandle = Input
			
			If (NativeStream <> Null) Then
				NativeStream.Close()
			Endif
			
			NativeStream = Input
			
			Return
		End
		
		Public
		
		' Fields (Protected):
		Protected
		
		Field NativeStream:BBStream ' BBStandardIOStream
		
		' This handle may or may not be set, depending on the situation.
		Field _RealHandle:BBStandardIOStream
		
		Public
	End
#End