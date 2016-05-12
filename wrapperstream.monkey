#Rem
	THIS MODULE IS CURRENTLY EXPERIMENTAL; USE AT YOUR OWN RISK.
#End

Strict

Public

' Preprocessor related:
'#REGAL_IOUTIL_WRAPPERSTREAM_SAFE = True

' Imports (Public):
Import brl.stream

' Imports (Private):
Private

Import brl.databuffer

Public

' Classes:
Class WrapperStream<StreamType> Extends Stream
	' Constructor(s):
	Method New(S:StreamType, ThrowOnInvalid:Bool=True)
		If (ThrowOnInvalid) Then
			If (S = Null) Then
				Throw New InvalidWrapperStream(Self, S)
			Endif
		Endif
		
		Self.InternalStream = S
	End
	
	' Destructor(s):
	Method Close:Void()
		InternalStream.Close()
		
		Return
	End

	' Methods (Public):
	Method Read:Int(Buffer:DataBuffer, Offset:Int, Count:Int)
		Return InternalStream.Read(Buffer, Offset, Count)
	End
	
	Method Write:Int(Buffer:DataBuffer, Offset:Int, Count:Int)
		Return InternalStream.Write(Buffer, Offset, Count)
	End
	
	Method ReadAll:Void(Buffer:DataBuffer, Offset:Int, Count:Int)
		InternalStream.ReadAll(Buffer, Offset, Count)
		
		Return
	End
	
	Method ReadAll:DataBuffer()
		Return InternalStream.ReadAll()
	End
	
	Method WriteAll:Void(Buffer:DataBuffer, Offset:Int, Count:Int)
		InternalStream.WriteAll(Buffer, Offset, Count)
		
		Return
	End
	
	Method ReadString:String(Count:Int, Encoding:String="utf8")
		Return InternalStream.ReadString(Count, Encoding)
	End
	
	Method ReadString:String(Encoding:String="utf8")
		Return InternalStream.ReadString(Encoding)
	End
	
	Method ReadLine:String()
		Return InternalStream.ReadLine()
	End
	
	Method ReadByte:Int()
		Return InternalStream.ReadByte()
	End
	
	Method ReadShort:Int()
		Return InternalStream.ReadShort()
	End
	
	Method ReadInt:Int()
		Return InternalStream.ReadInt()
	End
	
	Method ReadFloat:Float()
		Return InternalStream.ReadFloat()
	End
	
	Method WriteByte:Void(Value:Int)
		InternalStream.WriteByte(Value)
		
		Return
	End
	
	Method WriteShort:Void(Value:Int)
		InternalStream.WriteShort(Value)
		
		Return
	End
	
	Method WriteInt:Void(Value:Int)
		InternalStream.WriteInt(Value)
		
		Return
	End
	
	Method WriteFloat:Void(Value:Float)
		InternalStream.WriteFloat(Value)
		
		Return
	End
	
	Method WriteString:Void(Value:String, Encoding:String="utf8")
		InternalStream.WriteString(Value, Encoding)
		
		Return
	End
	
	Method WriteLine:Void(Str:String)
		InternalStream.WriteLine(Str)
		
		Return
	End
	
	Method Seek:Int(Position:Int)
		Return InternalStream.Seek(Position)
	End
	
	Method Skip:Void(Count:Int)
		InternalStream.Skip(Count)
		
		Return
	End
	
	' Methods (Protected):
	Protected
	
	Method InternalReadAll:Void(Buffer:DataBuffer, Offset:Int, Count:Int)
		' Call the super-class's implementation.
		Super.ReadAll(Buffer, Offset, Count)
		
		Return
	End
	
	Method InternalReadAll:DataBuffer()
		' Call the super-class's implementation.
		Return Super.ReadAll()
	End
	
	Method InternalWriteAll:Void(Buffer:DataBuffer, Offset:Int, Count:Int)
		' Call the super-class's implementation.
		Super.WriteAll(Buffer, Offset, Count)
		
		Return
	End
	
	Public
	
	' Properties:
	Method Eof:Int() Property
		Return InternalStream.Eof
	End
	
	Method Length:Int() Property
		Return InternalStream.Length
	End
	
	Method Position:Int() Property
		Return InternalStream.Position
	End
	
	Method Stream:StreamType() Property
		Return Self.InternalStream
	End
	
	' Fields (Public):
	' Nothing so far.
	
	' Fields (Protected):
	Protected
	
	Field InternalStream:StreamType
	
	Public
End

' Exceptions:
Class InvalidWrapperStream Extends StreamError
	' Constructor(s):
	Method New(Instance:Stream, WrappedStream:Stream=Null)
		Super.New(Instance)
		
		Self.WrappedStream = WrappedStream
	End
	
	' Methods:
	Method ToString:String()
		Return "An invalid stream was given to a 'WrapperStream' object."
	End
	
	' Fields (Protected):
	Protected
	
	Field WrappedStream:Stream
	
	Public
End