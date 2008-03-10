require File.expand_path('../test_helper', __FILE__)
require 'rucola/log'

describe "Log" do
  it "should be a singleton class" do
    Rucola::Log.instance.object_id.should == Rucola::Log.instance.object_id
  end
end

describe "A Log instance" do
  class LogCall < Exception; end
  
  before do
    @log = Rucola::Log.instance
    OSX.stubs(:NSLog).raises(LogCall)
  end
  
  after do
    @log.level = @log.level_for_env
  end
  
  it "should return the default level for a certain env" do
    with_env('test') { @log.level_for_env.should == Rucola::Log::SILENT }
    with_env('debug') { @log.level_for_env.should == Rucola::Log::DEBUG }
    with_env('release') { @log.level_for_env.should == Rucola::Log::ERROR }
  end
  
  it "should only log messages of the right level" do
    @log.level = Rucola::Log::SILENT
    lambda { @log.debug('-') }.should.not.raise(LogCall)
    lambda { @log.error('-') }.should.not.raise(LogCall)
    @log.level = Rucola::Log::DEBUG
    lambda { @log.debug('-') }.should.raise(LogCall)
    lambda { @log.error('-') }.should.raise(LogCall)
    @log.level = Rucola::Log::ERROR
    lambda { @log.debug('-') }.should.not.raise(LogCall)
    lambda { @log.error('-') }.should.raise(LogCall)
  end
  
  it "should allow a change of log level" do
    @log.level = Rucola::Log::DEBUG
    @log.level.should == Rucola::Log::DEBUG
  end
end