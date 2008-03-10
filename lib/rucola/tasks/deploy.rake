require 'uri'

namespace :deploy do
  DEPLOY_NAME = "#{APPNAME}_#{APPVERSION}"
  PKG = File.join('pkg', "#{DEPLOY_NAME}.dmg")
  
  directory 'pkg'
  
  desc "Package the application as a disk image"
  task :package => :pkg do
    FileUtils.rm(PKG) if File.exist?(PKG)
    puts 'Creating Image...'
    sh "hdiutil create -volname '#{DEPLOY_NAME}' -srcfolder 'build/Release/#{TARGET}' '#{PKG}'"
    puts ''
  end
  
  desc "Write a new appcast rss file"
  task :sparkle_appcast => :pkg do
    check_if_sparkle_info_exists!
    
    puts "Creating appcast..."
    appcast_filename = File.basename(INFO_PLIST['SUFeedURL'])
    
    appcast = %{
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>#{APPNAME} Changelog</title>
    <link>#{INFO_PLIST['SUFeedURL']}</link>
    <description>#{INFO_PLIST['SUAppDescription']}</description>
    <language>en</language>
    <item>
      <title>#{APPNAME} - #{APPVERSION}</title>
      <description>#{INFO_PLIST['SUPublicReleaseNotesURL']}#{DEPLOY_NAME}_release_notes.html</description>
      <pubDate>#{Time.now}</pubDate>
      <enclosure url="#{INFO_PLIST['SUPublicReleaseURL']}#{DEPLOY_NAME}.dmg" length="#{File.size(PKG)}" type="application/octet-stream"/>
    </item>
  </channel>
</rss>}.sub(/^\n/, '')
    
    File.open("pkg/#{appcast_filename}", 'w') { |f| f.write appcast }
    puts "created: pkg/#{appcast_filename}\n\n"
  end
  
  desc 'Removes the pkg/ directory.'
  task :clean do
    build_dir = 'pkg/'
    if File.exist? build_dir
      puts "Removing #{build_dir}"
      FileUtils.rm_rf build_dir
    end
  end
  
  desc "Upload pkg/ files. Specify the uri's with the constants PUBLISH_URI & APPCAST_URI."
  task :upload do
    if File.exist? PKG
      puts "\nUploading: #{PKG}"
      do_upload(PUBLISH_URI, PKG, File.basename(PKG))
      puts "\n\n"
    end
    
    appcast_path = "pkg/#{File.basename(INFO_PLIST['SUFeedURL'])}" if INFO_PLIST['SUFeedURL']
    if appcast_path and File.exist?(appcast_path)
      puts "\nUploading: #{appcast_path}"
      do_upload(APPCAST_URI, appcast_path, File.basename(appcast_path))
      puts "\n\n"
    end
  end
  
  private
  
  def check_if_sparkle_info_exists!
    [
      ['SUFeedURL', 'http://mydomain.com/my_app/appcast.xml'],
      ['SUAppDescription', 'My terrific application!'],
      ['SUPublicReleaseNotesURL', 'http://mydomain.com/my_app/', "Don't forget the last '/' which specifies that it's a directory.\nThe constructed url would look like: http://mydomain.com/my_app/my_app_1.1_release_notes.html"],
      ['SUPublicReleaseURL', 'http://mydomain.com/files/my_app/', "Don't forget the last '/' which specifies that it's a directory.\nThe constructed url would look like: http://mydomain.com/files/my_app/my_app_1.1.dmg"],
    ].each { |x| check_sparkle_for_key(*x) }
  end
  
  def check_sparkle_for_key(key, example_value, notes = nil)
    if INFO_PLIST[key].nil?
      puts "In order to create a sparkle appcast, you need to specify the value for '#{key}' in the Info.plist file."
      puts "Eg:\n\n  <key>#{key}</key>\n  <string>#{example_value}</string>"
      puts "\nNote:\n#{notes}" if notes
      exit
    end
  end
  
  # calls the upload method based on the scheme
  def do_upload(uri, file, dest_file)
    send(uri.scheme, uri, file, dest_file)
  end
  
  def scp(uri, file, dest_file)
    sh "scp -P #{ uri.port || '22' } #{file} #{uri.userinfo}@#{uri.host}:#{uri.path}/#{dest_file}"
  end
end