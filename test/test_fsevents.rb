require File.expand_path('../test_helper', __FILE__)
require 'rucola/fsevents'

describe "FSEvents initialization" do
  before do
    @path = File.dirname(__FILE__)
    @paths = [@path]
  end

  it "should raise an ArgumentError if a non existing path is specified" do
    lambda { Rucola::FSEvents.new('/non/existing/path') {|events| 'nothing' } }.should.raise ArgumentError
  end
  
  it "should raise an ArgumentError if no block was passed" do
    lambda { Rucola::FSEvents.new(@paths) }.should.raise ArgumentError
  end
  
  it "should take at minimum an array of paths and a block" do
    fsevents = Rucola::FSEvents.new(@paths) { |events| 'nothing' }
    fsevents.should.be.an.instance_of Rucola::FSEvents
    fsevents.paths.first.should.be @path
  end
  
  it "should have some default values" do
    fsevents = Rucola::FSEvents.new(@paths) { |events| 'nothing' }
    fsevents.allocator.should.be OSX::KCFAllocatorDefault
    fsevents.context.should.be nil
    fsevents.since.should.be OSX::KFSEventStreamEventIdSinceNow
    fsevents.latency.should == 0.0
    fsevents.flags.should == 0
    fsevents.stream.should.be nil
  end

  it "should be possible to create and start a stream with one call" do
    fsevents = mock('FSEvents')
    Rucola::FSEvents.expects(:new).with(@paths).returns(fsevents)
    fsevents.expects(:create_stream)
    fsevents.expects(:start)
    
    result = Rucola::FSEvents.start_watching(@path) {|events| 'nothing' }
    result.should.be(fsevents)
  end
  
  it "should accept options to tweak event parameters" do
    fsevents = Rucola::FSEvents.new(@paths,
      :latency => 5.2,
      :since => 24051980
    ) { |events| 'nothing' }
    fsevents.since.should.be 24051980
    fsevents.latency.should == 5.2
  end
end

describe "FSEvents when setting up the stream" do
  before do
    @path = File.dirname(__FILE__)
    @paths = [@path]
    @fsevents = Rucola::FSEvents.new(@paths) { |events| 'nothing' }
  end
  
  it "should create a real FSEvents stream" do
    @fsevents.create_stream
    @fsevents.stream.should.be.an.instance_of OSX::ConstFSEventStreamRef
  end
  
  it "should raise a Rucola::FSEvents::StreamError if the stream could not be created" do
    OSX.expects(:FSEventStreamCreate).returns(nil)
    lambda { @fsevents.create_stream }.should.raise Rucola::FSEvents::StreamError
  end
  
  it "should register the stream with the current runloop" do
    stream_mock = mock('Stream')
    OSX.expects(:FSEventStreamCreate).returns(stream_mock)
    runloop_mock = mock('Runloop')
    OSX.expects(:CFRunLoopGetCurrent).returns(runloop_mock)
    OSX.expects(:FSEventStreamScheduleWithRunLoop).with(stream_mock, runloop_mock, OSX::KCFRunLoopDefaultMode)
    @fsevents.create_stream
  end
  
  it "should start the stream" do
    stream_mock = mock('Stream')
    @fsevents.instance_variable_set(:@stream, stream_mock)
    OSX.expects(:FSEventStreamStart).with(stream_mock).returns(true)
    @fsevents.start
  end
  
  it "should raise a Rucola::FSEvents::StreamError if the stream could not be started" do
    OSX.expects(:FSEventStreamStart).returns(false)
    lambda { @fsevents.start }.should.raise Rucola::FSEvents::StreamError
  end
end

describe "FSEvents when started the stream" do
  before do
    @paths = [TMP_PATH]
  end
  
  def touch_file
    sleep 0.25
    `touch #{@paths.first}/test.txt`
    sleep 1.5
    `rm #{@paths.first}/test.txt`
  end
  
  def start(fsevents)
    fsevents.create_stream
    fsevents.start
    Thread.new { OSX.CFRunLoopRun }
  end
  
  xit "should run the user specified block when one of the paths that was specified is modified" do
    some_mock = mock
    some_mock.expects(:call!)
    
    fsevents = Rucola::FSEvents.new(@paths) do |events|
      some_mock.call!
      
      events.length.should == 1
      event = events.first
      event.should.be.an.instance_of Rucola::FSEvents::FSEvent
      event.path.should == @paths.first
    end
    p fsevents
    start(fsevents)
    touch_file
    fsevents.stop
  end
end

describe "FSEvent" do
  before do
    @tmp_path = TMP_PATH
    @new_file, @old_file = "#{@tmp_path}/new_file", "#{@tmp_path}/old_file"

    `touch #{@old_file}`
    sleep 1
    `touch #{@new_file}`
  end

  after do
    `rm #{@old_file}`
    `rm #{@new_file}`
  end
  
  it "should return an array of file entries in the path that the event occurred in, sorted by modification time (first element = last mod.)" do
    Rucola::FSEvents::FSEvent.new(nil, 666, @tmp_path).files.should == [@new_file, @old_file]
  end
  
  it "should return the last modified file" do
    Rucola::FSEvents::FSEvent.new(nil, 999, @tmp_path).last_modified_file.should == @new_file
  end
end