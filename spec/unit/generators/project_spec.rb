# encoding: UTF-8
require File.expand_path("../../../spec_helper", __FILE__)
require 'rucola/generators/rucola/project/project_generator'

TEMPLATE_ROOT = '/Library/Application Support/Developer/Shared/Xcode/Project Templates'

describe "Rucola::Generators::Project::Base" do
  extend Rucola::Generators::Project
  
  it "holds a list of generator names of subclasses" do
    Base.generators.should.include "document_app"
  end
  
  it "returns the root of the XCode project templates" do
    Base.source_root.should == TEMPLATE_ROOT
  end
  
  describe "subclassed for a specific project type" do
    extend Rucola::Generators::Project
    
    it "returns the xcodeproj" do
      AppGenerator.xcodeproj_template.should == File.join(AppGenerator.source_root, 'MacRubyApp.xcodeproj')
    end
    
    it "returns a hash with the contents of TemplateInfo.plist" do
      path = File.join(AppGenerator.xcodeproj_template, 'TemplateInfo.plist')
      hash = NSDictionary.dictionaryWithContentsOfFile(path)
      AppGenerator.xcodeproj_template_info.should == hash
    end
    
    it "returns the description from the TemplateInfo.plist" do
      AppGenerator.desc.should == AppGenerator.xcodeproj_template_info['Description']
    end
  end
end

describe "A project generator" do
  extend Rucola::Generators::Project
  
  it "returns the correct source_root" do
    root = File.join(TEMPLATE_ROOT, 'Application/MacRuby Application')
    File.should.exist root
    AppGenerator.source_root.should == root
    
    root = File.join(TEMPLATE_ROOT, 'Application/MacRuby Core Data Application')
    File.should.exist root
    CoreDataAppGenerator.source_root.should == root
    
    root = File.join(TEMPLATE_ROOT, 'Application/MacRuby Document-based Application')
    File.should.exist root
    DocumentAppGenerator.source_root.should == root
    
    root = File.join(TEMPLATE_ROOT, 'System Plug-in/MacRuby Preference Pane')
    File.should.exist root
    PrefPaneGenerator.source_root.should == root
  end
end