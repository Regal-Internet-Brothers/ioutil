Strict

Public

' Imports:
Import ioutil.repeater

Import ioutil.publicdatastream
Import ioutil.stdio

' Functions:
Function Main:Int()
	' Create a stream to standard-out, and an input memory-stream.
	Local Console:= New StandardIOStream()
	Local Input:= New PublicDataStream(128)
	
	' Create a repeater with our 'Input' stream.
	' In addition, this will have closing-rights for both input and output.
	Local Output:= New Repeater(Input, False, True, True)
	
	Output.Add(Console)
	
	Input.WriteLine("Hello, World.")
	Input.Seek(0)
	
	Output.TransferInput()
	
	Output.Close()
	
	' Return the default response.
	Return 0
End