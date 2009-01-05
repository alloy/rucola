#!/usr/local/bin/macruby

require File.expand_path('../test_helper', __FILE__)

describe "FSEvents initialization" do
  before do
    @paths = %w(first-directory second-directory).map { |dn| File.join(Tmp.path, dn) }
    @paths.each { |path| FileUtils.mkdir_p(path) }
  end

  it "should raise an ArgumentError if a non existing path is specified" do
    lambda { Rucola::FSEvents.new('/non/existing/path') { |events| nil } }.should.raise ArgumentError
  end
  
  it "should raise an ArgumentError if no block was passed" do
    lambda { Rucola::FSEvents.new(*@paths) }.should.raise ArgumentError
  end
  
  it "should take at minimum an array of paths and a block" do
    fsevents = Rucola::FSEvents.new(*@paths) { |events| nil }
    fsevents.should.be.an.instance_of Rucola::FSEvents
    fsevents.paths.should == @paths
  end
  
  it "should take a list of paths instead of multiple path arguments" do
    fsevents = Rucola::FSEvents.new(@paths) { |events| nil }
    fsevents.should.be.an.instance_of Rucola::FSEvents
    fsevents.paths.should == @paths
  end
  
  it "should have some default values" do
    fsevents = Rucola::FSEvents.new(*@paths) { |events| nil }
    fsevents.allocator.should.be KCFAllocatorDefault
    fsevents.context.should.be nil
    fsevents.since.should.be KFSEventStreamEventIdSinceNow
    fsevents.latency.should == 0.0
    fsevents.flags.should == 0
    fsevents.stream.should.be nil
  end

  it "should be possible to create and start a stream with one call" do
    fsevents = mock('FSEvents')
    Rucola::FSEvents.expects(:new).with(*@paths).returns(fsevents)
    fsevents.expects(:create_stream)
    fsevents.expects(:start)
    
    result = Rucola::FSEvents.start_watching(*@paths) {|events| nil }
    result.should.be(fsevents)
  end
  
  it "should accept options to tweak event parameters" do
    fsevents = Rucola::FSEvents.new(*(@paths+[{ :latency => 5.2, :since => 24051980 }])) { |events| nil }
    fsevents.paths.should == @paths
    fsevents.since.should.be 24051980
    fsevents.latency.should == 5.2
  end
end

describe "FSEvents when setting up the stream" do
  include Tmp
  
  before do
    @paths = %w(first-directory second-directory).map { |dn| File.join(Tmp.path, dn) }
    @paths.each { |path| FileUtils.mkdir_p(path) }
    @fsevents = Rucola::FSEvents.new(@paths) { |events| 'nothing' }
  end
  
  it "should create a real FSEvents stream" do
    @fsevents.create_stream
    @fsevents.stream.should.be.an.instance_of ConstFSEventStreamRef
  end
  
  it "should raise a Rucola::FSEvents::StreamError if the stream could not be created" do
    @fsevents.expects(:FSEventStreamCreate).returns(nil)
    lambda { @fsevents.create_stream }.should.raise Rucola::FSEvents::StreamError
  end
  
  it "should register the stream with the current runloop" do
    stream_mock = mock('Stream')
    @fsevents.expects(:FSEventStreamCreate).returns(stream_mock)
    runloop_mock = mock('Runloop')
    @fsevents.expects(:CFRunLoopGetCurrent).returns(runloop_mock)
    @fsevents.expects(:FSEventStreamScheduleWithRunLoop).with(stream_mock, runloop_mock, KCFRunLoopDefaultMode)
    @fsevents.create_stream
  end
  
  it "should start the stream" do
    stream_mock = mock('Stream')
    @fsevents.instance_variable_set(:@stream, stream_mock)
    @fsevents.expects(:FSEventStreamStart).with(stream_mock).returns(true)
    @fsevents.start
  end
  
  it "should raise a Rucola::FSEvents::StreamError if the stream could not be started" do
    @fsevents.expects(:FSEventStreamStart).returns(false)
    lambda { @fsevents.start }.should.raise Rucola::FSEvents::StreamError
  end
end

describe "FSEvents with a running stream" do
  include Tmp
  
  it "should run the specified block on events in the directory" do
    waiter = :waiting
    
    Thread.new { CFRunLoopRun() }
    fsevents = Rucola::FSEvents.new(Tmp.path) do |events|
      waiter = :done
    end
    fsevents.create_stream
    fsevents.start
    
    new_file = File.join(Tmp.path, 'a-new-file')
    FileUtils.touch(new_file)
    File.should.exist(new_file)
    
    # Busy wait for the block to run
    started = Time.now
    while waiter == :waiting && (Time.now - started) < 60
      sleep 0.1
    end
    waiter.should == :done
    fsevents.stop
  end
end unless ENV['QUICK_RUN']

describe "FSEvent" do
  include Tmp
  
  before do
    @files = %w(first-file second-file).map { |fn| File.join(Tmp.path, fn) }
    @files.each { |fn| FileUtils.touch(fn) }
  end
  
  it "should return an array of file entries in the path that the event occurred in, sorted by modification time (first element = last mod.)" do
    Rucola::FSEvents::FSEvent.new(nil, nil, Tmp.path).files.should == @files.reverse
  end
  
  it "should return the last modified file" do
    Rucola::FSEvents::FSEvent.new(nil, nil, Tmp.path).last_modified_file.should == @files.last
  end
end