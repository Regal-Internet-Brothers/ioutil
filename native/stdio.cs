
// Classes:
class BBStandardIOStream : BBStream
{
	// Destructor(s):
	public override void Close()
	{
		// Check for errors:
		if (input == null && output == null)
			return;
		
		//input.Close();
		//output.Close();
		
		input = null;
		output = null;
	}
	
	// Methods:
	public virtual bool Open()
	{
		// Check for errors:
		if (output != null || input != null)
			return false;
		
		input = System.Console.OpenStandardInput();
		output = System.Console.OpenStandardOutput();
		
		// Return the default response.
		return true;
	}
	
	public override int Eof()
	{
		if (input == null)
			return ((output != null) ? 1 : -1);
		
		return 0;
	}
	
	public override int Length()
	{
		return 0;
	}
	
	public override int Position()
	{
		return 0;
	}
	
	public override int Seek(int position)
	{
		return 0;
	}
		
	public override int Read(BBDataBuffer buffer, int offset, int count)
	{
		if (input == null)
			return 0;

		try
		{
			return input.Read(buffer._data, offset, count);
		}
		catch (IOException ex)
		{
		}
		
		return 0;
	}
	
	public override int Write( BBDataBuffer buffer,int offset,int count )
	{
		if (output == null)
			return 0;
		
		try
		{
			output.Write(buffer._data, offset, count);
			
			return count;
		}
		catch (IOException ex)
		{
		}
		
		return 0;
	}
	
	// Fields:
	Stream input;
	Stream output;
}
