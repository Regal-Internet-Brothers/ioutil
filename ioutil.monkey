Strict

Public

' Preprocessor related:
'#IOUTIL_EXPERIMENTAL = True

' Imports:

' Internal:
Import util

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