$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tealeaves'
require 'spec'
require 'spec/autorun'

include TeaLeaves

Spec::Runner.configure do |config|
  
end
