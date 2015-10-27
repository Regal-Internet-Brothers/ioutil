Strict

Public

' Imports:
Import regal.ioutil.repeater

Import regal.ioutil.publicdatastream
Import regal.ioutil.stdio

' Functions:
Function Main:Int()
	' Create a stream to standard-out, and an input memory-stream.
	Local Console:= New StandardIOStream()
	Local Input:= New PublicDataStream(128)
	
	' Create a repeater with our 'Input' stream.
	' In addition, this will have closing-rights for both input and output.
	Local Output:= New Repeater(Input, False, True, True)
	
	' Add 'Console' as an output-stream.
	Output.Add(Console)
	
	' Write data to our input-stream,
	' se we can repeat to our output(s) later.
	Input.WriteLine("Hello, World.")
	
	' Seek back to the beginning, so we
	' know where to start transferring.
	Input.Seek(0)
	
	' Peform a complete transfer of 'Input'.
	' This will only transfer what has
	' been written; the line we wrote above.
	Output.TransferInput()
	
	' Close everything; 'Console', 'Input', and 'Output'.
	Output.Close()
	
	' Return the default response.
	Return 0
End