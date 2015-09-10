Strict

Public

' Preprocessor related:
'#IOUTIL_EXPERIMENTAL = True

' Imports:
Import publicdatastream
Import endianstream
Import errors

' Experimental:
#If IOUTIL_EXPERIMENTAL
	Import wrapperstream
	Import chainstream
	Import repeater
	Import stdio
#End