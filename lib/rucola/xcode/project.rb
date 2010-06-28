module Rucola
  module XCode
    class Project
      def initialize(path)
        @path = path
      end
      
      def data
        @data ||= Hash.dictionaryWithContentsOfFile(File.join(@path, 'project.pbxproj'))
      end
      
      def objects
        data['objects']
      end
      
      def file_objects
        objects.select { |_, object| object['isa'] == 'PBXFileReference' }
      end
      
      def group_objects
        objects.select { |_, object| object['isa'] == 'PBXGroup' }
      end
      
      def file_object(filename)
        file_objects.find { |_, object| object['path'] == filename }
      end
      
      def group_object(group_name)
        group_objects.find { |_, object| object['path'] == group_name }
      end
      
      def group_objects_by_child_uuid(child_uuid)
        group_objects.select { |_, object| object['children'].include? child_uuid }
      end
      
      def remove_file(filename)
        uuid, _ = file_object(filename)
        if uuid
          objects.delete(uuid)
          group_objects_by_child_uuid(uuid).each do |_, group|
            group['children'].delete(uuid)
          end
        end
      end
      
      def remove_group(group_name)
        uuid, _ = group_object(group_name)
        objects.delete(uuid) if uuid
      end
    end
  end
end