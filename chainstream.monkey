#Rem
	THIS MODULE IS CURRENTLY EXPERIMENTAL; USE AT YOUR OWN RISK.
#End

Strict

Public

' Imports (Public):
Import brl.stream

' Imports (Private):
Private

Import byteorder

Import brl.databuffer

Public

' Classes:
Class ChainStream Extends SpecializedChainStream<Stream> Final
	' Constructor(s):
	Method New(Streams:Stream[], BigEndian:Bool=Default_BigEndian, CloseRights:Bool=True, Link:Int=0)
		Super.New(Streams, BigEndian, CloseRights, Link)
	End
	
	Method New(Streams:Stack<StreamType>, BigEndian:Bool=Default_BigEndian, CloseRights:Bool=True, Link:Int=0)
		Super.New(Streams, BigEndian, CloseRights, Link)
	End
End

Class SpecializedChainStream<StreamType> Extends Stream
	' Constant variable(s):
	
	' Defaults:
	
	' Booleans / Flags:
	Const Default_BigEndian:Bool = False
	
	' Constructor(s) (Public):
	
	' All containers passed to these constructors should be assumed to be under this object's control:
	Method New(Streams:StreamType[], BigEndian:Bool=Default_BigEndian, CloseRights:Bool=True, Link:Int=0)
		Construct(New Stack<StreamType>(Streams), BigEndian, CloseRights, Link)
	End
	
	Method New(Streams:Stack<StreamType>, BigEndian:Bool=Default_BigEndian, CloseRights:Bool=True, Link:Int=0)
		Construct(Streams, BigEndian, CloseRights, Link)
	End
	
	' Constructor(s) (Protected):
	Protected
	
	Method Construct:Void(Streams:Stack<StreamType>, BigEndian:Bool=Default_BigEndian, CloseRights:Bool=True, Link:Int=0)
		Self.Chain = Streams
		Self.Link = Link
		
		Self.BigEndian = BigEndian
		Self.CanCloseStreams = CloseRights
		
		Return
	End
	
	Public
	
	' Destructor(s):
	Method Close:Void()
		If (CanCloseStreams) Then
			For Local Node:= Eachin Chain
				Node.Close()
			Next
		Endif
		
		' Empty the stream-chain.
		Chain.Clear()
		
		Return
	End
	
	' Methods (Public):
	
	' This is pretty bloated, but it works:
	Method Seek:Int(Position:Int)
		Local Target:Int = -1
		Local BackwardOffset:Int = 0
		
		For Local I:= FinalChainIndex To 0 Step -1
			Local CL:= ChainLength(I)
			
			If (Position >= CL) Then
				Target = I
				BackwardOffset = CL
			Else
				Chain.Get(I).Seek(0)
			Endif
		Next
		
		If (Target = -1) Then
			Return Self.Position
		Endif
		
		Link = Target
		CurrentLink.Seek(Position-BackwardOffset)
		
		Return Position
	End
	
	Method ReadShort:Int()
		If (BigEndian) Then
			Return NToHS(Super.ReadShort())
		Endif
		
		Return Super.ReadShort()
	End
	
	Method ReadInt:Int()
		If (BigEndian) Then
			Return NToHL(Super.ReadInt())
		Endif
		
		Return Super.ReadInt()
	End
	
	Method ReadFloat:Float()
		If (BigEndian) Then
			Return NToHF(Super.ReadInt())
		Endif
		
		Return Super.ReadFloat()
	End
	
	Method WriteShort:Void(Value:Int)
		If (BigEndian) Then
			Super.WriteShort(HToNS(Value))
		Else
			Super.WriteShort(Value)
		Endif
		
		Return
	End
	
	Method WriteInt:Void(Value:Int)
		If (BigEndian) Then
			Super.WriteInt(HToNL(Value))
		Else
			Super.WriteInt(Value)
		Endif
		
		Return
	End
	
	Method WriteFloat:Void(Value:Float)
		If (BigEndian) Then
			Super.WriteInt(HToNF(Value))
		Else
			Super.WriteFloat(Value)
		Endif
		
		Return
	End
	
	Method Read:Int(Buffer:DataBuffer, Offset:Int, Count:Int)
		Local BytesRead:= CurrentLink.Read(Buffer, Offset, Count)
		
		If (BytesRead < Count) Then
			If (OnFinalLink) Then
				Return 0 ' -1
			Endif
			
			Link += 1
			
			Return (BytesRead + Read(Buffer, Offset+BytesRead, (Count-BytesRead)))
		Endif
		
		Return BytesRead
	End
	
	Method Write:Int(Buffer:DataBuffer, Offset:Int, Count:Int)
		Local BytesWritten:= CurrentLink.Write(Buffer, Offset, Count)
		
		If (BytesWritten < Count) Then
			If (OnFinalLink) Then
				Return 0 ' -1
			Endif
			
			Link += 1
			
			Return (BytesWritten + Write(Buffer, Offset+BytesWritten, (Count-BytesWritten)))
		Endif
		
		Return BytesWritten
	End
	
	' Methods (Protected):
	Protected
	
	' The length of the chain as-of the link specified.
	Method ChainLength:Int(LinkPosition:Int)
		If (LinkPosition < 0 Or LinkPosition > LinkCount) Then
			Return 0
		Endif
		
		Local P:Int = 0
		
		For Local I:= 0 Until LinkPosition
			' Add the length of the previous link in the chain.
			P += Chain.Get(I).Length
		Next
		
		Return (P + Chain.Get(LinkPosition).Position)
	End
	
	Public
	
	' Properties (Public):
	
	' This specifies if we are at the end of the stream.
	' This uses the final chain as a reference, as normal operations
	' will automatically move through each link in the chain.
	Method Eof:Int() Property
		'Return CurrentLink.Eof
		Return FinalLink.Eof
	End
	
	' The overall length of this stream. (Bytes contained)
	Method Length:Int() Property
		Local L:Int = 0
		
		For Local Node:= Eachin Chain
			L += Node.Length
		Next
		
		Return L
	End
	
	' The current "virtual" position in the stream;
	' functions like a normal stream, use as you would normally.
	Method Position:Int() Property
		' Add the previous links' lengths to the current link's position.
		Return (ChainLength(Link))
	End
	
	' A public "accessor" for the internal "chain".
	' Mutation may result in undefined behavior; use at your own risk.
	Method Links:Stack<StreamType>() Property
		Return Self.Chain
	End
	
	' The number of links in the internal "chain".
	Method LinkCount:Int() Property
		Return Chain.Length
	End
	
	' This specifies if we are currently
	' using the final link in the chain.
	Method OnFinalLink:Bool() Property
		Return (Link = FinalChainIndex)
	End
	
	' Properties (Protected):
	Protected
	
	' The final chain-index (Link) in the chain.
	Method FinalChainIndex:Int() Property
		Return Max(LinkCount-1, 0)
	End
	
	' The current stream-link in the chain. (Use at your own risk)
	Method CurrentLink:StreamType() Property
		Return Chain.Get(Link)
	End
	
	' The final stream in the "chain". (Use at your own risk)
	Method FinalLink:StreamType() Property
		Return Chain.Get(FinalChainIndex)
	End
	
	Public
	
	' Fields (Protected):
	Protected
	
	' A "chain" of streams representing
	' the data this stream delegates.
	Field Chain:Stack<StreamType>
	
	' The active element of 'Chain';
	' the stream currently used for I/O.
	Field Link:Int
	
	' Booleans / Flags:
	
	' This specifies if big-endian storage should be used/expected.
	Field BigEndian:Bool
	
	' This specifies if this object has the right to
	' close the elements of the internal "chain".
	Field CanCloseStreams:Bool = True
	
	Public
End