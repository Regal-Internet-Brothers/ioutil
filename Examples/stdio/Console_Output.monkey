Strict

Public

' Imports:
Import ioutil.stdio

' Functions:
Function Main:Int()
	Local Console:= New StandardIOStream()
	
	Console.WriteLine("Hello, World.")
	
	'Print(Console.ReadLine())
	
	Console.Close()
	
	' Return the default response.
	Return 0
End