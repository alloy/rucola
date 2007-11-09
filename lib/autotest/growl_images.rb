# Copyright John Nunemaker
# See: http://railstips.org/2007/7/23/autotest-growl-pass-fail-notifications

require 'autotest'
require 'autotest/redgreen'
require 'autotest/timestamp'

# To use this autotest plugin add the following to your autotest config file (~/.autotest):
#
#   require 'autotest/growl_images'
#
# At this moment growlnotify still has a few issues on Leopard.
# This means that sometimes the notification will show up and sometimes not.
module Autotest::Growl
  # Override this to specify an alternative path to your pass/fail images.
  #
  #  def self.images_path
  #    File.expand_path('..', __FILE__)
  #  end
  def self.images_path
    File.expand_path('..', __FILE__)
  end

  def self.growl(title, msg, img, pri=0, sticky="")
    system "growlnotify -n autotest --image #{img} -p #{pri} -m #{msg.inspect} #{title} #{sticky}" 
  end

  Autotest.add_hook :ran_command do |at|
    results = [at.results].flatten.join("\n")
    output = results.slice(/(\d+)\stests,\s(\d+)\sassertions,\s(\d+)\sfailures,\s(\d+)\serrors/)
    if output
      if $~[3].to_i > 0 || $~[4].to_i > 0
        growl "FAIL", "#{output}", "#{images_path}/fail.png", 2
      else
        growl "Pass", "#{output}", "#{images_path}/pass.png" 
      end
    end
  end
end