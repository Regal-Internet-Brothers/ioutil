Strict

Public

' Imports (Public):
Import brl.stream

' Imports (Private):
Private

Import publicdatastream

Public

' Classes:
Class StringStream Extends PublicDataStream
	' Constant variable(s):
	
	' ASCII:
	Const ASCII_CARRIAGE_RETURN:= 13
	Const ASCII_LINE_FEED:= 10
	
	Const ASCII_QUOTE:= 34
	
	' Global variable(s):
	
	' Defaults:
	Global Default_Size:= 1024 ' 1KB
	
	' Constructor(s):
	Method New(Message:String, Encoding:String="utf8", FixByteOrder:Bool=Default_BigEndianStorage, InitSize:Int=Default_Size, SizeLimit:Int=NOLIMIT)
		Super.New(InitSize, FixByteOrder, True, SizeLimit)
		
		WriteString(Message, Encoding)
		
		'Self.Encoding = Encoding
	End
	
	Method New(Size:Int=Default_Size, FixByteOrder:Bool=Default_BigEndianStorage, SizeLimit:Int=NOLIMIT)
		Super.New(Size, FixByteOrder, True, SizeLimit)
	End
	
	' Methods:
	
	#Rem
		Method ToString:String() ' Property
			Return Echo()
		End
	#End
	
	Method Echo:String(Encoding:String="utf8")
		Local P:= Position
		
		Seek(0)
		
		Local Output:= ReadString(Encoding)
		
		Seek(P)
		
		Return Output
	End
	
	Method WriteChar:Void(Value:Int)
		WriteByte(Value)
		'WriteShort(Value)
		
		Return
	End
	
	Method WriteChars:Void(Chars:Int[], Offset:Int, Length:Int)
		' Not the most optimal, but it works:
		For Local I:= Offset Until Length
			WriteChar(Chars[I])
		Next
		
		Return
	End
	
	Method WriteChars:Void(Chars:Int[], Offset:Int=0)
		WriteChars(Chars, Offset, Chars.Length)
		
		Return
	End
	
	Method EndLine:Void()
		WriteChar(ASCII_CARRIAGE_RETURN)
		WriteChar(ASCII_LINE_FEED)
		
		Return
	End
	
	Method WriteQuote:Void()
		WriteChar(ASCII_QUOTE)
		
		Return
	End
	
	' Fields:
	'Field Encoding:String
End