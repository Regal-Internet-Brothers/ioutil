Strict

Public

' Imports:
Import ioutil.stringstream

' Functions:
Function Main:Int()
	Local S:= New StringStream()
	
	S.WriteString("Hello world.")
	S.EndLine()
	
	S.WriteString("This is a test.~n")
	S.WriteLine("Lines can be written with 'WriteLine' as well as using '~~n' and 'EndLine'.")
	
	S.WriteString("We can also write raw data to a 'StringStream': ")
	
	S.WriteQuote()
	
	Local BeginPoint:= S.Position
	
	S.WriteChar(65)
	S.WriteChar(66)
	
	Local EndPoint:= S.Position
	
	S.Seek(BeginPoint)
	
	Local Data:= S.ReadShort()
	
	S.Seek(BeginPoint)
	
	S.WriteShort(Data)
	
	S.Seek(EndPoint)
	
	S.WriteQuote()
	
	S.EndLine()
	
	Print(S.Echo())
	
	' Return the default response.
	Return 0
End