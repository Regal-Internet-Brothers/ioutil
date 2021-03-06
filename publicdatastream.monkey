Strict

Public

' Preprocessor related:
#IOUTIL_PUBLICDATASTREAM_LEGACY_BIG_ENDIAN = True

' Imports (Public):
Import regal.byteorder

' BRL:
Import brl.stream

' Imports (Private):
Private

Import regal.util

' BRL:
Import brl.databuffer

Public

' Classes:
Class PublicDataStream Extends Stream Implements IOnLoadDataComplete
	' Constant variable(s):
	Const NOLIMIT:Int = 0 ' -1
	
	' Defaults:
	Const Default_ResizeScalar:Float = 1.5 ' 2.0
	
	' Booleans / Flags:
	Const Default_BigEndianStorage:Bool = False
	
	' Constructor(s) (Public):
	
	' The specified size must be at least 2 bytes large.
	Method New(Size:Int, BigEndianStorage:Bool=Default_BigEndianStorage, Resizable:Bool=True, SizeLimit:Int=NOLIMIT)
		GenerateBuffer(Size)
		
		Self.BigEndianStorage = BigEndianStorage
		Self.ShouldResize = Resizable
		Self.SizeLimit = SizeLimit
	End
	
	Method New(B:DataBuffer, Length:Int, Offset:Int=0, Copy:Bool=False, BigEndianStorage:Bool=Default_BigEndianStorage, Resizable:Bool=True, SizeLimit:Int=NOLIMIT)
		If (Copy) Then
			GenerateBuffer(B)
			
			OwnsBuffer = True
		Else
			Self.Data = B
		Endif
		
		Self.Offset = Offset
		Self._Length = Length
		
		Self.RawSize = Length
		
		Self.BigEndianStorage = BigEndianStorage
		Self.ShouldResize = Resizable
		Self.SizeLimit = SizeLimit
	End
	
	Method New(Path:String, BigEndianStorage:Bool=Default_BigEndianStorage, Async:Bool=False)
		If (Not Async) Then
			OnLoadDataComplete(DataBuffer.Load(Path), Path)
		Else
			DataBuffer.LoadAsync(Path, Self)
		Endif
		
		Self.BigEndianStorage = BigEndianStorage
	End
	
	' Constructor(s) (Protected):
	Protected
	
	Method New()
		' Nothing so far.
	End
	
	Method GenerateBuffer:Void(Size:Int)
		Self.Data = New DataBuffer(Size)
		Self.RawSize = Size
		Self.OwnsBuffer = True
		
		Return
	End
	
	' This will copy the contents of 'B' into an internally managed buffer.
	Method GenerateBuffer:Void(B:DataBuffer)
		GenerateBuffer(B.Length)
		
		B.CopyBytes(0, Data, 0, Data.Length)
		
		Return
	End
	
	Public
	
	' Destructor(s) (Protected):
	Protected
	
	Method DestructDetails:Void()
		Self.Offset = 0
		Self._Position = 0
		
		Return
	End
	
	Public
	
	' Destructor(s) (Public):
	Method FreeBuffer:Void(DiscardBuffer:Bool=True)
		If (Data <> Null) Then
			If (DiscardBuffer) Then
				Data.Discard()
			Endif
			
			Data = Null
		Endif
		
		OwnsBuffer = False
		
		RawSize = 0
		
		Return
	End
	
	Method Close:Void()
		FreeBuffer(OwnsBuffer)
		DestructDetails()
		
		Return
	End
	
	' The resulting 'DataBuffer' represents the 'Data'
	' property before destruction takes place.
	Method CloseWithoutBuffer:DataBuffer()
		Local OutputBuffer:= Data
		
		FreeBuffer(False)
		DestructDetails()
		
		Return OutputBuffer
	End
	
	' Methods:
	
	' This creates a 'DataBuffer' by copying 'Data' based on the contents described by this point.
	' This is useful for handling storage semantics; copies.
	Method ToDataBuffer:DataBuffer()
		Local outBuffer:= New DataBuffer(Length)
		
		Data.CopyBytes(Offset, outBuffer, 0, Length)
		
		Return outBuffer
	End
	
	Method Seek:Int(Input:Int=0)
		Self._Position = Clamp(Input, 0, DataLength)
		
		Return Self._Position
	End
	
	Method Reset:Void()
		Seek()
		ResetLength()
		
		Return
	End
	
	' This states if the number of bytes specified may be read safely.
	Method WillOverReach:Bool(Bytes:Int)
		Return ReadWillOverReach(Bytes)
	End
	
	Method ReadWillOverReach:Bool(Bytes:Int)
		Return (Position+Bytes > Length)
	End
	
	Method WriteWillOverReach:Bool(Bytes:Int)
		Return (Position+Bytes > DataLength) ' Length
	End
	
	Method ReadShort:Int()
		If (BigEndianStorage) Then
			Local Value:= Super.ReadShort()
			
			#If IOUTIL_PUBLICDATASTREAM_LEGACY_BIG_ENDIAN
				Return NToHS(Value)
			#Else
				Return NToHS_S(Value)
			#End
		Endif
		
		Return Super.ReadShort()
	End
	
	Method ReadInt:Int()
		If (BigEndianStorage) Then
			Return NToHL(Super.ReadInt())
		Endif
		
		Return Super.ReadInt()
	End
	
	Method ReadFloat:Float()
		If (BigEndianStorage) Then
			Return NToHF(Super.ReadInt())
		Endif
		
		Return Super.ReadFloat()
	End
	
	Method WriteShort:Void(Value:Int)
		If (BigEndianStorage) Then
			Super.WriteShort(HToNS(Value))
		Else
			Super.WriteShort(Value)
		Endif
		
		Return
	End
	
	Method WriteInt:Void(Value:Int)
		If (BigEndianStorage) Then
			Super.WriteInt(HToNL(Value))
		Else
			Super.WriteInt(Value)
		Endif
		
		Return
	End
	
	Method WriteFloat:Void(Value:Float)
		If (BigEndianStorage) Then
			Super.WriteInt(HToNF(Value))
		Else
			Super.WriteFloat(Value)
		Endif
		
		Return
	End
	
	Method Read:Int(Buf:DataBuffer, Offset:Int, Count:Int)
		If (WillOverReach(Count)) Then
			Count = Self.BytesLeft
		Endif
		
		#Rem
			For Local Index:= 0 Until Count
				Buf.PokeByte(Offset+Index, Self.Data.PeekByte(Offset+Position+Index))
			Next
		#End
		
		Self.Data.CopyBytes(Self.DataOffset, Buf, Offset, Count)
		
		Self._Position += Count
		
		Return Count
	End
	
	Method Write:Int(Buf:DataBuffer, Offset:Int, Count:Int)
		Local NewPosition:= (Count+Position)
		
		If (NewPosition > DataLength) Then
			If (ShouldResize) Then
				AutoResize(Count)
			Else
				Count = (DataLength-Position) ' Max(..., 0)
			Endif
		Endif
		
		Buf.CopyBytes(Offset, Self.Data, Self.DataOffset, Count)
		
		Self._Position = NewPosition
		
		SetLengthSafe(NewPosition)
		
		Return Count
	End
	
	' This transfers a raw segment of the internal buffer into 'S'. (Use at your own risk)
	Method TransferSegment:Void(S:Stream, Bytes:Int, Offset:Int)
		S.WriteAll(Data, Offset, Bytes)
		
		Return
	End
	
	' This may be used to transfer the internal data of this stream to another.
	Method TransferTo:Void(S:Stream, Offset:Int=0)
		Local ReadOffset:= (Self.Offset+Offset)
		
		TransferSegment(S, Length, ReadOffset)
		
		Return
	End
	
	' This may be used to transfer what has already been read.
	Method TransferPastData:Void(S:Stream, Offset:Int=0)
		Local ReadOffset:= (Self.Offset+Offset)
		
		TransferSegment(S, (Position-ReadOffset), ReadOffset)
		
		Return
	End
	
	' This may be used to read the number of bytes specified, from this stream then transfer it to another.
	Method TransferAmount:Void(S:Stream, Bytes:Int, Offset:Int=0)
		Local P:= S.Position
		
		TransferSegment(S, Bytes, (Self.Offset+Self.Position+Offset))
		
		S.Seek(P)
		
		Return
	End
	
	Method AutoResize:Bool(MinBytes:Int=0)
		If (Not OwnsBuffer) Then
			Return False
		Endif
		
		Return Resize(Max(Int(Float(Data.Length) * ResizeScalar), MinBytes))
	End
	
	Method SmartResize:Bool(MinBytes:Int)
		If (MinBytes <= DataLength) Then
			Return True
		Endif
		
		Return Resize(MinBytes)
	End
	
	Method Resize:Bool(NewSize:Int, Force:Bool=False)
		If (Not OwnsBuffer) Then
			Return False
		Endif
		
		If (SizeLimit <> NOLIMIT) Then
			If (NewSize > SizeLimit) Then
				If (Force) Then
					NewSize = Min(NewSize, SizeLimit)
				Else
					Return False
				Endif
			Endif
		Endif
		
		Data = ResizeBuffer(Data, NewSize, True, True, True)
		
		If (Data <> Null) Then
			RawSize = NewSize ' Data.Length
			
			Return True
		Endif
		
		Return False
	End
	
	Method SetLength:Void(Value:Int)
		Self._Length = Min(Value, DataLength)
		
		Return
	End
	
	Method SetLengthSafe:Void(Value:Int)
		SetLength(Max(Value, Self._Length))
		
		Return
	End
	
	' This sets the internal length to the current position.
	Method ClampToPosition:Void()
		SetLength(Position)
		
		Return
	End
	
	Method ResetLength:Void()
		SetLength(0)
		
		Return
	End
	
	' Call-backs:
	Method OnLoadDataComplete:Void(Data:DataBuffer, Path:String)
		If (Self.Data = Null) Then
			Self.Data = Data
			Self._Length = Data.Length
		Endif
		
		Return
	End
	
	' Properties (Public):
	
	' The internal I/O buffer.
	Method Data:DataBuffer() Property
		Return Self._Data
	End
	
	Method Eof:Int() Property
		Return (Position >= Length)
	End
	
	' The furthest this stream has written.
	Method Length:Int() Property
		Return Self._Length
	End
	
	' The number of bytes into the buffer this stream is.
	Method Position:Int() Property
		Return Self._Position
	End
	
	' The overall length of the 'Data' buffer. (Taking 'Offset' into account)
	Method RawSize:Int() Property
		Return Self._RawSize
	End
	
	' This will return the 'RawSize' property adjusted to the internal offset.
	Method DataLength:Int() Property
		Return (RawSize - Offset)
	End
	
	' The real position in the 'Data' buffer. (After 'Offset')
	Method DataOffset:Int() Property
		Return (Offset+Position)
	End
	
	' The number of bytes left in 'Data'. (Input only)
	Method BytesLeft:Int() Property
		Return Max(Length - Position, 0)
	End
	
	' This specifies the number of bytes left.
	' (Based on 'RawSize' and 'DataOffset'; use at your own risk)
	Method RealBytesLeft:Int() Property
		Return Max(RawSize - DataOffset, 0)
	End
	
	' This may be used for asynchronous buffer-loading.
	Method DataReady:Bool() Property
		Return (Data <> Null)
	End
	
	' Properties (Protected):
	Protected
	
	Method Data:Void(Input:DataBuffer) Property
		Self._Data = Input
		
		Return
	End
	
	Method RawSize:Void(Input:Int) Property
		Self._RawSize = Input
		
		Return
	End
	
	Public
	
	' Fields (Public):
	
	' Please use any corresponding properties when possible:
	
	' This acts as an internal offset inside the 'Data' buffer.
	Field Offset:Int
	
	' The (Local) position of the stream.
	Field _Position:Int
	
	' The furthest point we have written in the internal buffer.
	Field _Length:Int
	
	' The internal buffer's size-limit. (Used when resizing)
	Field SizeLimit:Int = NOLIMIT
	
	' A floating-point scalar used when a resize-operation occurs.
	' Numbers will be rounded as the hardware sees fit. (Usually rounds down)
	Field ResizeScalar:Float = Default_ResizeScalar
	
	' Booleans / Flags:
	
	' This may be used to toggle resizing the internal buffer.
	Field ShouldResize:Bool
	
	' This specifies if big-endian byte-order should be used.
	Field BigEndianStorage:Bool
	
	' This specifies if this stream owns the internal buffer.
	Field OwnsBuffer:Bool
	
	' Fields (Protected):
	Protected
	
	Field _Data:DataBuffer
	Field _RawSize:Int
	
	Public
End