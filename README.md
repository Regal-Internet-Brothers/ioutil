# ioutil
A module for the [Monkey programming language](https://github.com/blitz-research/monkey), providing several useful I/O components.

### Features (Some are experimental):
* '**ChainStream**': A tool for turning a set of 'Stream' objects into a continuous I/O stream. ('SpecializedChainStream')
* '**Repeater**': A 'WrapperStream' that allows you to output to multiple 'Stream' objects at once. This is also useful when transferring data from one input 'Stream' to one or more output 'Streams'. ('SpecializedRepeater')
* '**WrapperStream**': An interface layer between an enclosed 'Stream' and the code using it; allows for method overrides without class-extension. Useful for things like byte-swapping, encapsulation, etc.
* '**StandardIOStream**': A standard binary I/O stream; console input and output, file streaming, etc. Uses either the C standard library, or the OS's native I/O API(s).
* '**BasicEndianStreamManager**': A 'WrapperStream' that automates byte swapping based on your preferences. Useful for network I/O. ('EndianStreamManager')
* '**PublicDataStream**': An alternative implementation to 'brl.datastream.DataStream', providing memory I/O and buffer management utilities.
* '**StringStream**': A 'PublicDataStream' geared towards 'String' storage, creation, and management. (Class extension reference)

For details on which feature is experimental, please review the [main source file](/ioutil.monkey).
