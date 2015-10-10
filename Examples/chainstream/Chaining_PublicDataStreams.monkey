Strict

Public

' Imports:
Import ioutil.publicdatastream
Import ioutil.chainstream

Import sizeof

' Functions:

' This function produces a 'PublicDataStream' specifically to house the value specified.
' The 'Padding' argument specifies the number of bytes before 'Value' in the stream.
Function IntStream:PublicDataStream(Value:Int, Padding:Int=0)
	' Local variable(s):
	
	' Allocate a new 'PublicDataStream' based on the size
	' of an integer, and the padding specified by the user.
	Local S:= New PublicDataStream(Padding+SizeOf_Integer, False, False)
	
	' Move past the padding.
	S.Seek(Padding)
	
	' Write the specified value.
	S.WriteInt(Value)
	
	' Seek to the beginning, so future input operations are not offset.
	S.Seek(0)
	
	' Return the stream we prepared.
	Return S
End

Function Main:Int()
	' Constant variable(s):
	
	' This represents the number of streams we'll be chaining together.
	Const StreamCount:= 32
	
	' This will be the amount of padding we'll
	' have before the data-segment begins.
	Const Padding:= 8
	
	' The number of integers supplied for each entry. (See below)
	Const Scale:= 10
	
	' Local variable(s):
	
	' This will act as our canonical streams.
	Local Streams:= New Stack<Stream>()
	
	' Create the first "node" stream with the padding we described.
	Streams.Push(IntStream(Scale, Padding))
	
	' Create our chain stream, using our stack.
	' By default, closing-rights are assumed.
	Local S:= New ChainStream(Streams)
	
	' Seek past the padding.
	S.Seek(Padding)
	
	Print(S.ReadInt())
	
	' Constantly add streams to the chain, as we read forward:
	For Local I:= 1 Until StreamCount
		' For every other "node", don't bother with padding.
		S.Links.Push(IntStream((I+1)*Scale))
		
		Print(S.ReadInt())
	Next
	
	' Close our chain, including the "node" streams.
	S.Close()
	
	' Return the default response.
	Return 0
End