Strict

Public

' Imports:
Import sizeof
Import publicdatastream
Import chainstream

' Functions:
Function IntStream:PublicDataStream(Value:Int, Padding:Int=0)
	Local S:= New PublicDataStream(Padding+SizeOf_Integer, False, False)
	
	S.Seek(Padding)
	S.WriteInt(Value)
	
	S.Seek(0)
	
	Return S
End

Function Main:Int()
	' Constant variable(s):
	Const StreamCount:= 32
	
	' Local variable(s):
	Local Streams:Stream[StreamCount]
	
	Local Padding:= 1024
	
	Streams[0] = IntStream(10, Padding)
	
	For Local I:= 1 Until StreamCount
		Streams[I] = IntStream((I+1)*10)
	Next
	
	Local S:= New ChainStream(Streams)
	
	S.Seek(Padding)
	
	While (Not S.Eof)
		Print(S.ReadInt())
	Wend
	
	' Return the default response.
	Return 0
End