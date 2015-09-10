#Rem
	THIS MODULE IS CURRENTLY EXPERIMENTAL; USE AT YOUR OWN RISK.
#End

Strict

Public

' Imports (Public):
Import brl.stream

' Imports (Private):
Private

Import wrapperstream

Import sizeof

Import brl.databuffer

Public

' Classes:
Class Repeater Extends SpecializedRepeater<Stream, Stream> Final
	' Constructor(s):
	Method New(SynchronizedFinish:Bool=False, CanCloseOutputStreams:Bool=False)
		Super.New(SynchronizedFinish, CanCloseOutputStreams)
	End
	
	Method New(Streams:Stack<Stream>, SynchronizedFinish:Bool=False, CanCloseOutputStreams:Bool=False)
		Super.New(Streams, SynchronizedFinish, CanCloseOutputStreams)
	End
	
	Method New(InputStream:InputStreamType, SynchronizedFinish:Bool=False, CanCloseInputStream:Bool=False, CanCloseOutputStreams:Bool=False)
		Super.New(InputStream, SynchronizedFinish, CanCloseInputStream, CanCloseOutputStreams)
	End
	
	Method New(InputStream:InputStreamType, Streams:Stack<OutputStreamType>, SynchronizedFinish:Bool=False, CanCloseInputStream:Bool=False, CanCloseOutputStreams:Bool=False)
		Super.New(InputStream, Streams, SynchronizedFinish, CanCloseInputStream, CanCloseOutputStreams)
	End
End

Class SpecializedRepeater<InputStreamType, OutputStreamType> Extends WrapperStream<InputStreamType>
	' Constructor(s) (Public):
	Method New(SynchronizedFinish:Bool=True, CanCloseOutputStreams:Bool=False)
		Self.SynchronizedFinish = SynchronizedFinish
		Self.CloseOutputStreams = CanCloseOutputStreams
		
		MakeStreamContainer()
	End
	
	Method New(Streams:Stack<OutputStreamType>, SynchronizedFinish:Bool=True, CanCloseOutputStreams:Bool=False)
		Self.SynchronizedFinish = SynchronizedFinish
		Self.CloseOutputStreams = CanCloseOutputStreams
		
		Self.Streams = Streams
	End
	
	Method New(InputStream:InputStreamType, SynchronizedFinish:Bool=True, CanCloseInputStream:Bool=False, CanCloseOutputStreams:Bool=False)
		Self.InputStream = InputStream
		
		Self.SynchronizedFinish = SynchronizedFinish
		Self.CloseInputStream = CanCloseInputStream
		Self.CloseOutputStreams = CanCloseOutputStreams
		
		MakeStreamContainer()
	End
	
	Method New(InputStream:InputStreamType, Streams:Stack<OutputStreamType>, SynchronizedFinish:Bool=True, CanCloseInputStream:Bool=False, CanCloseOutputStreams:Bool=False)
		Self.InputStream = InputStream
		Self.Streams = Streams
		
		Self.SynchronizedFinish = SynchronizedFinish
		Self.CloseInputStream = CanCloseInputStream
		Self.CloseOutputStreams = CanCloseOutputStreams
	End
	
	' Constructor(s) (Protected):
	Protected
	
	Method MakeStreamContainer:Void()
		Self.Streams = New Stack<OutputStreamType>()
		
		Return
	End
	
	Public
	
	' Destructor(s):
	
	' This will automatically close the appropriate streams as directed.
	' Closing with this command is considered "unprotected", but should
	' be done when finished with this stream repeater.
	Method Close:Void()
		If (HasInputStream And CloseInputStream) Then
			Super.Close()
		Endif
		
		If (CloseOutputStreams) Then
			For Local S:= Eachin Streams
				S.Close()
			Next
		Endif
		
		Streams.Clear()
		
		Return
	End
	
	' Methods:
	
	' This may be used to add an output stream to this repeater.
	Method Add:Void(S:OutputStreamType)
		Streams.Push(S)
		
		Return
	End
	
	' This may be used to remove an output stream from this repeater.
	Method Remove:Void(S:OutputStreamType)
		Streams.RemoveEach(S)
		
		Return
	End
	
	' Without an 'InputStream', this will seek using the internal "virtual output position".
	' If 'InputStream' is available, seeking will be performed on that instead.
	Method Seek:Int(Position:Int)
		If (Not HasInputStream) Then
			OutputSeek(Position)
		Else
			Return Super.Seek(Position) ' InputStream.Seek(Position)
		Endif
		
		Return Position
	End
	
	Method OutputSeek:Int(Position:Int)
		Local Diff:Int = (Position-OutputPosition)
			
		If (Diff = 0) Then
			Return OutputPosition
		Endif
		
		For Local S:= Eachin Streams
			S.Seek(S.Position+Diff) ' S.Skip
		Next
		
		OutputPosition = Max(OutputPosition + Diff, 0)
		
		Return OutputPosition
	End
	
	' If an 'InputStream' is available, this may be used to transfer
	' 'Count' bytes from that stream to all of the output streams.
	Method TransferFromInput:Int(Count:Int)
		Local TempBuffer:= New DataBuffer(Count)
		
		ReadAll(TempBuffer, 0, Count)
		
		Local BytesTransferred:= WriteAll(TempBuffer, 0, Count)
		
		TempBuffer.Discard()
		
		Return BytesTransferred
	End
	
	' This will transfer all data available from 'InputStream'; use with caution.
	Method TransferInput:Int()
		Local InputData:= ReadAll()
		
		Local BytesTransferred:= WriteAll(InputData, 0, InputData.Length)
		
		InputData.Discard()
		
		Return BytesTransferred
	End
	
	Method Write:Int(Buffer:DataBuffer, Offset:Int, Count:Int)
		Local MaxBytesTransferred:= 0
		
		For Local S:= Eachin Streams
			Local Transferred:Int = 0
			Local ShouldClose:Bool = False ' S.Eof
			
			Try
				Transferred = S.Write(Buffer, Offset, Count)
				
				If (Transferred <> Count) Then ' Transferred < Count
					ShouldClose = True
				Endif
			Catch E:StreamWriteError
				ShouldClose = True
			End
			
			If (ShouldClose) Then ' Or (S.Length-S.Position) <= 0
				Remove(S)
				
				If (CloseOutputStreams) Then
					Try
						S.Close()
					Catch E:StreamError
						' Nothing so far.
					End
				Endif
			Endif
			
			MaxBytesTransferred = Max(MaxBytesTransferred, Transferred)
		Next
		
		OutputPosition += MaxBytesTransferred
		
		Return MaxBytesTransferred
	End
	
	Method WriteByte:Void(Value:Int)
		For Local S:= Eachin Streams
			S.WriteByte(Value)
		Next
		
		OutputPosition += SizeOf_Byte
		
		Return
	End
	
	Method WriteShort:Void(Value:Int)
		For Local S:= Eachin Streams
			S.WriteShort(Value)
		Next
		
		OutputPosition += SizeOf_Short
		
		Return
	End
	
	Method WriteInt:Void(Value:Int)
		For Local S:= Eachin Streams
			S.WriteInt(Value)
		Next
		
		OutputPosition += SizeOf_Integer
		
		Return
	End
	
	Method WriteFloat:Void(Value:Float)
		For Local S:= Eachin Streams
			S.WriteFloat(Value)
		Next
		
		OutputPosition += SizeOf_FloatingPoint
		
		Return
	End
	
	Method WriteString:Void(Value:String, Encoding:String="utf8")
		Local StreamResult:= 0
		
		For Local S:= Eachin Streams
			Local CurrentPosition:= S.Position
			
			S.WriteString(Value, Encoding)
			
			StreamResult = Max(StreamResult, (S.Position-CurrentPosition))
		Next
		
		If (StreamResult <= 0) Then
			OutputPosition += SizeOf(Value)
		Else
			OutputPosition += StreamResult
		Endif
		
		Return
	End
	
	Method WriteLine:Void(Str:String)
		Local StreamResult:= 0
		
		For Local S:= Eachin Streams
			Local CurrentPosition:= S.Position
			
			S.WriteLine(Str)
			
			StreamResult = Max(StreamResult, (S.Position-CurrentPosition))
		Next
		
		If (StreamResult <= 0) Then
			OutputPosition += SizeOf(Str) + (SizeOf_Byte*2) ' (SizeOf_Char*2)
		Else
			OutputPosition += StreamResult
		Endif
		
		Return
	End
	
	' Properties (Public):
	
	' This provides direct access to the 'InternalStream' property;
	' basically, this is what we use for input operations.
	Method InputStream:InputStreamType() Property
		Return InternalStream
	End
	
	' If a different stream is specified, and we have the right
	' to close the current stream, it will be closed.
	Method InputStream:Void(Input:InputStreamType) Property
		If (Input <> InternalStream) Then
			If (CloseInputStream) Then
				InternalStream.Close()
			Endif
			
			InternalStream = Input
		Endif
		
		Return
	End
	
	' This specifies if the minimum or maximum end-points of the output-streams should be used.
	Method SynchronizedFinish:Bool() Property
		Return Self._SynchronizedFinish
	End
	
	' This specifies if we have an 'InputStream'.
	Method HasInputStream:Bool() Property
		Return (InputStream <> Null)
	End
	
	' This property states if ANY stream has reached its end.
	' The only exception to this rule is output-streams,
	' where the 'SynchronizedFinish' flag dictates behavior.
	Method Eof:Int() Property
		' Constant variable(s):
		Const RESPONSE_ERROR:= -1
		Const RESPONSE_NORMAL:= 0
		Const RESPONSE_EOF:= 1
		Const RESPONSE_UNKNOWN:= 2
		
		If (HasInputStream) Then
			' Local variable(s):
			Local InputResponse:= Super.Eof ' InputStream.Eof
			
			If (InputResponse <> RESPONSE_NORMAL) Then
				Return InputResponse
			Endif
		Endif
		
		Local Result:Int = RESPONSE_UNKNOWN
		
		For Local S:= Eachin Streams
			Local Response:= S.Eof
			
			If (SynchronizedFinish) Then
				If (Response = RESPONSE_EOF Or Response = RESPONSE_ERROR) Then
					Return Response
				Endif
			Else
				If (Response <> RESPONSE_NORMAL) Then
					Result = Min(Result, Response)
				Endif
			Endif
		Next
		
		If (Result = RESPONSE_UNKNOWN) Then
			Return RESPONSE_NORMAL
		Endif
		
		Return Result
	End
	
	' This will return the length of 'InputStream' if available.
	' If not, the 'OutputLength' property will be used.
	Method Length:Int() Property
		If (Not HasInputStream) Then
			Return OutputLength
		Endif
		
		Return Super.Length ' InputStream.Length
	End
	
	' If 'InputStream' is available, it will be returned.
	' If not, 'OutputPosition' will be returned instead.
	Method Position:Int() Property
		If (Not HasInputStream) Then
			Return OutputPosition
		Endif
		
		Return Super.Position ' InputStream.Position
	End
	
	' This retrieves the largest length of the output-streams.
	Method MaximumLength:Int() Property
		Local L:= 0
		
		For Local S:= Eachin Streams
			L = Max(L, S.Length)
		Next
		
		Return L
	End
	
	' This retrieves the smallest length of the output-streams.
	Method MinimumLength:Int() Property
		Local L:= Streams.Top().Length
		
		For Local S:= Eachin Streams
			L = Min(L, S.Length)
		Next
		
		Return L
	End
	
	' This provides the "virtual output position".
	Method OutputPosition:Int() Property
		Return Self._Position
	End
	
	' This provides the desired length of the output-streams. (Based on 'SynchronizedFinish')
	Method OutputLength:Int() Property
		If (SynchronizedFinish) Then
			Return MinimumLength
		Endif
		
		Return MaximumLength
	End
	
	' Properties (Protected):
	Protected
	
	Method SynchronizedFinish:Void(Input:Bool) Property
		Self._SynchronizedFinish = Input
		
		Return
	End
	
	Method OutputPosition:Void(Input:Int) Property
		Self._Position = Input
		
		Return
	End
	
	Public
	
	' Fields (Public):
	
	' Caution should be taken when modifying these fields:
	Field CloseInputStream:Bool
	Field CloseOutputStreams:Bool
	
	' Fields (Protected):
	Protected
	
	' A container of streams used for output.
	Field Streams:Stack<OutputStreamType>
	
	' The "virtual output position" of this stream.
	Field _Position:Int
	
	' Booleans / Flags:
	
	' See the 'SynchronizedFinish' property for details.
	Field _SynchronizedFinish:Bool
	
	Public
End