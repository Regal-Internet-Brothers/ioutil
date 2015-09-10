Strict

Public

' Imports:
Import brl.stream

' Classes:
Class InvalidOpenOperation Extends StreamError
	' Constructor(s):
	Method New(S:Stream)
		Super.New(S)
	End
	
	' Methods:
	Method ToString:String() ' Property
		Return "Unable to open stream."
	End
End

Class UnsupportedStreamOperation Extends StreamError
	' Constructor(s):
	Method New(S:Stream)
		Super.New(S)
	End
	
	' Methods:
	Method ToString:String() ' Property
		Return "Stream operation unsupported."
	End
End