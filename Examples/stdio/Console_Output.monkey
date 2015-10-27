Strict

Public

' Imports:
Import regal.ioutil.stdio

' Functions:
Function Main:Int()
	Local Console:= New StandardIOStream()
	
	Console.WriteLine("Hello world.")
	
	'Console.WriteLine(Console.ReadLine())
	
	Console.Close()
	
	' Return the default response.
	Return 0
End