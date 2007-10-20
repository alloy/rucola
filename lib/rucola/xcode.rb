require 'osx/cocoa'
require 'pathname'

module Rucola
  class Xcode
    # FIXME: We should probably generate random id keys!
    
    attr_reader :project
    attr_reader :project_path
    attr_reader :project_data
    
    def initialize(project_path)
      @project_path = Pathname.new(project_path)
      @project = @project_path.basename.to_s.sub(/\.xcodeproj$/, '')
      @project_path_data = @project_path + 'project.pbxproj'
      @project_data = OSX::NSDictionary.dictionaryWithContentsOfFile(@project_path_data.to_s)
    end
    
    # Saves the project data atomically.
    # Returns +false+ if it failed.
    def save
      # FIXME: Because we use non generated id's atm (which is bad!)
      # we should first make a bakup of the project.
      puts "\n========================================================================="
      puts "Backing up project #{@project}.xcodeproj to /tmp/#{@project}.xcodeproj.bak"
      puts "Please retrieve that one if for some reason the project was damaged!\n"
      backup = "/tmp/#{@project}.xcodeproj.bak"
      Kernel.system("rm -rf #{backup}") if File.exists?(backup)
      Kernel.system("cp -R #{project_path} #{backup}")
      
      # this writes the plist as a new xml style plist,
      # but luckily xcode recognizes it as well and
      # writes it back out as an old style plist.
      @project_data.writeToFile_atomically(@project_path_data.to_s, true)
    end
    
    def nil_if_empty(result)
      result.empty? ? nil : result
    end
    private :nil_if_empty
    
    # Get's the id & values for a object which name is the one passed to this method.
    # Returns an array: [id, values]
    def object_for_name(name)
      nil_if_empty @project_data['objects'].select { |object| object.last['name'] == name }.flatten
    end
    
    # Get's the id & values for a object which type and name is the one passed to this method.
    # Returns an array: [id, values]
    def object_for_type_and_name(type, name)
      nil_if_empty @project_data['objects'].select { |object| object.last['isa'] == type and object.last['name'] == name }.flatten
    end
    
    # Returns the object that represents this projects target.
    # Returns an array: [id, values]
    def object_for_project_target
      nil_if_empty object_for_type_and_name('PBXNativeTarget', @project)
    end
    
    # Returns the object for a given name.
    # Returns an array: [id, values]
    def object_for_id(object_id)
      @project_data['objects'][object_id].nil? ? nil : [object_id, @project_data['objects'][object_id]]
    end
    
    # Adds an object to the objects.
    def add_object(object_id, object_values)
      @project_data['objects'][object_id] = object_values
    end
    
    # Adds a build phase specified by +object_id+ to the build phases of the project target.
    def add_build_phase_to_project_target(object_id)
      # Add the new build phase to the main project target if it doesn't already exist
      build_target_id, build_target_values = object_for_project_target
      build_target_values['buildPhases'].push(object_id) unless build_target_values['buildPhases'].include?(object_id)
    end
    
    def add_object_to_build_phase(object_id, build_phase_id)
      build_phase = object_for_id(build_phase_id).last
      build_phase['files'].push(object_id) unless build_phase['files'].include?(object_id)
    end
    
    NEW_COPY_FRAMEWORKS_BUILD_PHASE = ['519A79DB0CC8AE6B00CBE85D', {
      'name' => 'Copy Frameworks',
      'isa' => 'PBXCopyFilesBuildPhase',
      'buildActionMask' => '2147483647',
      'dstPath' => '',
      'dstSubfolderSpec' => 10, # TODO: is 10 the number for the location popup choice: Frameworks
      'runOnlyForDeploymentPostprocessing' => 0,
      'files' => []
    }]
    # Creates a new framework copy build phase.
    # It does not add it to the objects nor the build phases,
    # do this with +add_object+ and +add_build_phase_to_project_target+.
    #
    # FIXME: Need to generate the id's instead of static.
    def new_framework_copy_build_phase
      NEW_COPY_FRAMEWORKS_BUILD_PHASE
    end
    
    # Changes the path of the framework +framework_name+ to the path +new_path_to_framework+.
    def change_framework_location(framework_name, new_path_to_framework)
      framework_id, framework_values = object_for_name(framework_name)
      framework_values['path'] = new_path_to_framework
      framework_values['sourceTree'] = '<group>'
    end
    
    # Changes the path of the RubyCocoa framework to +new_path_to_framework+.
    def change_rubycocoa_framework_location(new_path_to_framework)
      change_framework_location 'RubyCocoa.framework', new_path_to_framework
    end
    
    # Bundles the given framework in the application.
    def bundle_framework(framework_name)
      framework_id, framework_values = object_for_name(framework_name)
      
      # create a new file wrapper for in the copy build phase
      framework_in_build_phase_id = '511E98590CC8C5940003DED9'
      framework_in_build_phase_values = {
        'isa' => 'PBXBuildFile',
        'fileRef' => framework_id
      }
      add_object(framework_in_build_phase_id, framework_in_build_phase_values)
      
      # get or define the Copy Frameworks build phase
      build_phase = object_for_name('Copy Frameworks')
      if build_phase.nil?
        build_phase_id, build_phase_values = new_framework_copy_build_phase
        # add the new build phase to the objects
        add_object(build_phase_id, build_phase_values)
        
        # add the new build phase to the project target
        add_build_phase_to_project_target(build_phase_id)
      else
        build_phase_id, build_phase_values = build_phase
      end
      # add the framework to the build phase
      add_object_to_build_phase(framework_in_build_phase_id, build_phase_id)
    end
    
    # Bundles the RubyCocoa framework in the application.
    def bundle_rubycocoa_framework
      bundle_framework 'RubyCocoa.framework'
    end
  end
end