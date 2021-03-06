Strict

Public

' Imports:
Import brl.stream

' Functions:

' This applies 'Mask' to the contents of 'S' (XOR; useful for networking routines)
Function MaskStream:Void(S:Stream, Mask:Int, Length:Int)
	Local DataPos:= S.Position
	
	For Local I:= 1 To Length Step 4 ' SizeOf_Integer ' SizeOf(Mask)
		Local Session:= S.Position
		
		Try
			Local Data:= S.ReadInt()
			
			S.Seek(Session)
			
			S.WriteInt(Data ~ Mask)
		Catch E:StreamReadError
			Local BytesLeft:= (Length - (Session-DataPos))
			
			Local SMask:= (((Mask Shr 16) & $FFFF)) ' 16-bit mask. ' ((((Mask Shr 16) | $FFFF0000) & $FFFF))
			Local BMask:= ((Mask Shr 24) & $FF) ' 8-bit mask. ' (((Mask Shr 24) | $FF000000) & $FF)
			
			S.Seek(Session)
			
			While (BytesLeft > 0 And BytesLeft < 4)
				Local SubSession:= S.Position
				
				Select BytesLeft
					Case 1
						Local Data:= (S.ReadByte() & $FF)
						
						S.Seek(SubSession)
						
						S.WriteByte(Data ~ BMask)
						
						BytesLeft -= 1
					Case 2, 3
						Local Data:= (S.ReadShort() & $FFFF)
						
						S.Seek(SubSession)
						
						S.WriteShort(Data ~ SMask)
						
						BytesLeft -= 2
				End Select
			Wend
		End Try
	Next
				
	S.Seek(DataPos)
	
	Return
End

Function SeekForward:Int(S:Stream, Bytes:Int)
	Local NewPosition:= (S.Position + Bytes)
	
	S.Seek(NewPosition)
	
	Return NewPosition
End

Function SeekBackward:Int(S:Stream, Bytes:Int)
	Local NewPosition:= (S.Position - Bytes)
	
	S.Seek(NewPosition)
	
	Return NewPosition
End

Function SeekBegin:Int(S:Stream)
	Local Position:= S.Position
	
	S.Seek(0)
	
	Return Position
End