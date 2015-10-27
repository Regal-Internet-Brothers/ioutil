Strict

Public

' Imports:
Import regal.ioutil.stdio

' Functions:
Function Main:Int()
	Local Console:= New StandardIOStream("test.txt", "r", True)
	
	'Console.WriteLine("Hello, World.")
	
	'Local InputLength:= Console.Length
	
	Local Data:= Console.ReadAll()
	
	Console.WriteAll(Data, 0, Data.Length)
	
	Data.Discard()
	
	Console.WriteByte(13)
	Console.WriteByte(10)
	
	Console.WriteLine("Done.")
	
	Console.Close()
	
	' Return the default response.
	Return 0
End