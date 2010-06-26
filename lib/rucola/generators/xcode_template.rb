# encoding: UTF-8

# TODO from http://www.cocoadev.com/index.pl?XcodeProjectTemplates
#
# «DIRECTORY» Full path of the file's parent directory
# «FILENAME» Full file name, as typed by user
# «FILEBASENAME» File name without the extension
# «FILEBASENAMEASIDENTIFIER» File name without the extension, mangled to a legal C-style identifier
# «FILEEXTENSION» Current file's extension
# «TIME»Current time (using NSCalendarDate format "%X")
# «USERNAME» Account name ("short name") of the logged in user

# These should be implemented by the generator.
#
# «PROJECTNAME» Name of the project to which the file was added (blank if none)
# «PROJECTNAMEASIDENTIFIER» Name of the project, mangled to a legal C-style identifier
# «PROJECTNAMEASXML» Name of the project, as a valid XML string

framework 'Foundation'

class XCodeTemplate
  def initialize(context, template)
    @context, @template = context, template
  end
  
  def render
    source = File.read(@template)
    
    if File.basename(@template) == 'InfoPlist.strings'
      source.force_encoding('UTF-16BE')
      source.force_encoding('UTF-16LE') unless source.valid_encoding?
    else
      case File.extname(@template)
      when '.pbxproj', '.plist'
        source.force_encoding('UTF-8')
      else
        source.force_encoding('ISO-8859-1')
      end
    end
    
    raise "Unable to determine encoding of `#{template}'." unless source.valid_encoding?
    
    output = source.encode('UTF-8')
    output.gsub!(/«(.+?)»|Ç(.+?)È/) do
      method = $1 || $2
      if respond_to?(method)
        send(method)
      elsif @context.respond_to?(method)
        @context.send(method)
      else
        raise NoMethodError, "could not find a method to handle the XCode variable `#{method}' in template `#{@template}'"
      end
    end
    
    output.encode(source.encoding)
  end
  
  # «DATE» Current date (using NSCalendarDate format "%x")
  def DATE
    date.strftime("%d-%m-%y")
  end
  
  def YEAR
    date.year
  end
  
  # «FULLUSERNAME» Full name of the logged in user
  def FULLUSERNAME
    NSFullUserName()
  end
  
  # Dummy stub
  def ORGANIZATIONNAME
    '__MyCompanyName__'
  end
  
  private
  
  def date
    @date ||= Date.today
  end
  
  module Actions
    def xcode_template(source, destination = nil)
      destination ||= source
      template = File.join(self.class.source_root, source)
      create_file(destination, XCodeTemplate.new(self, template).render)
    end
  end
end