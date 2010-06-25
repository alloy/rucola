# encoding: UTF-8

# TODO from http://www.cocoadev.com/index.pl?XcodeProjectTemplates
#
# «DATE» Current date (using NSCalendarDate format "%x")
# «DIRECTORY» Full path of the file's parent directory
# «FILENAME» Full file name, as typed by user
# «FILEBASENAME» File name without the extension
# «FILEBASENAMEASIDENTIFIER» File name without the extension, mangled to a legal C-style identifier
# «FILEEXTENSION» Current file's extension
# «FULLUSERNAME» Full name of the logged in user
# «PROJECTNAME» Name of the project to which the file was added (blank if none)
# «PROJECTNAMEASIDENTIFIER» Name of the project, mangled to a legal C-style identifier
# «PROJECTNAMEASXML» Name of the project, as a valid XML string
# «TIME»Current time (using NSCalendarDate format "%X")
# «USERNAME» Account name ("short name") of the logged in user

class XCodeTemplate
  def initialize(context, template)
    @context, @template = context, template
  end
  
  def render
    source = File.read(@template)
    source.gsub!(/«(.+?)»/) do
      method = $1
      if respond_to?(method)
        send(method)
      elsif @context.respond_to?(method)
        @context.send(method)
      else
        raise NoMethodError, "could not find a method to handle the XCode variable `#{method}' in template `#{@template}'"
      end
    end
    source
  end
  
  module Actions
    def xcode_template(source, destination)
      template = File.join(self.class.source_root, source)
      create_file(destination, XCodeTemplate.new(self, template).render)
    end
  end
end