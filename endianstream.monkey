Strict

Public

' Preprocessor related:
#IOUTIL_ENDIANSTREAM_LEGACY_BIG_ENDIAN = True

' Imports (Public):
Import brl.stream

' Imports (Private):
Private

Import wrapperstream

Import regal.byteorder

Import brl.databuffer

Public

' Classes:

' Automatic byte-swapping for 'Streams'.
Class EndianStreamManager<StreamType> Extends WrapperStream<StreamType>
	' Constructor(s):
	Method New(S:StreamType, BigEndianStorage:Bool=False)
		Super.New(S)
		
		Self.BigEndianStorage = BigEndianStorage
	End

	' Methods:
	Method ReadShort:Int()
		' Local variable(s):
		Local Data:= Super.ReadShort()
		
		If (BigEndianStorage) Then
			#If IOUTIL_ENDIANSTREAM_LEGACY_BIG_ENDIAN
				Return NToHS(Data)
			#Else
				Return NToHS_S(Data)
			#End
		Endif
		
		Return Data
	End
	
	Method ReadInt:Int()
		' Local variable(s):
		Local Data:= Super.ReadInt()
		
		If (BigEndianStorage) Then
			Return NToHL(Data)
		Endif
		
		Return Data
	End
	
	Method ReadFloat:Float()
		If (BigEndianStorage) Then
			Return NToHF(Super.ReadInt())
		Endif
		
		Return Super.ReadFloat()
	End
	
	Method WriteShort:Void(Value:Int)
		If (BigEndianStorage) Then
			Value = HToNS(Value)
		Endif
		
		' Call the super-class's implementation.
		Super.WriteShort(Value)
		
		Return
	End
	
	Method WriteInt:Void(Value:Int)
		If (BigEndianStorage) Then
			Value = HToNL(Value)
		Endif
		
		' Call the super-class's implementation.
		Super.WriteInt(Value)
		
		Return
	End
	
	Method WriteFloat:Void(Value:Float)
		' Call the evaluated write command.
		If (BigEndianStorage) Then
			Super.WriteInt(HToNF(Value))
		Else
			Super.WriteFloat(Value)
		Endif
		
		Return
	End
	
	' Fields:
	Field BigEndianStorage:Bool
End

Class BasicEndianStreamManager Extends EndianStreamManager<Stream> Final
	' Constructor(s):
	Method New(S:Stream, BigEndianStorage:Bool=False)
		' Call the super-class's implementation.
		Super.New(S, BigEndianStorage)
	End
End