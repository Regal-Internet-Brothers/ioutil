Strict

Public

' Preprocessor related:
'#IOUTIL_EXPERIMENTAL = True

' Imports:

' Internal:
Import publicdatastream
Import wrapperstream
Import stringstream
Import endianstream
Import chainstream
Import repeater
Import stdio

Import errors

' Experimental:
#If IOUTIL_EXPERIMENTAL
	' Nothing so far.
#End

' External:
Import brl.stream

' Functions:

' This applies 'Mask' to the contents of 'S' (XOR; useful for networking routines)
Function MaskStream:Void(S:Stream, Mask:Int, Length:Int)
	Local SMask:= (((Mask Shr 16) & $FFFF)) ' 16-bit mask. ' ((((Mask Shr 16) | $FFFF0000) & $FFFF))
	Local BMask:= ((Mask Shr 24) & $FF) ' 8-bit mask. ' (((Mask Shr 24) | $FF000000) & $FF)
	
	Local DataPos:= S.Position
	
	For Local I:= 1 To Length Step 4 ' SizeOf_Integer ' SizeOf(Mask)
		Local Session:= S.Position
		
		Try
			Local Data:= S.ReadInt()
			
			S.Seek(Session)
			
			S.WriteInt(Data ~ Mask)
		Catch E:StreamReadError
			Local BytesLeft:= (Length - (Session-DataPos))
			
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