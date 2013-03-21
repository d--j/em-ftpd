module BaseSocket

  attr_reader :aborted, :finished

  def initialize
    @on_stream = nil
    @aborted   = false
    @finished  = false
  end

  def on_stream &blk
    @on_stream = blk if block_given?
    unless data.empty?
      @on_stream.call(data) # send all data that was collected before the stream handler was set
      @data = ""
    end
    @on_stream
  end

  def data
    @data ||= ""
  end

  def receive_data(chunk)
    if @on_stream
      @on_stream.call(chunk)
    else
      data << chunk
    end
  end

  def unbind
    @finished = true
    if @on_stream
      succeed
    else
      succeed data
    end
  end

  def abort
    @aborted = true
    close_connection_after_writing
  end
end
