$: << "#{File.dirname(__FILE__)}/../../vendor/plugins/user_interface/lib"
require 'user_interface/tasks'

UserInterface::Tasks::Css.new :stylesheet, :color => "#ae0000", :logo => 'streambox'
UserInterface::Tasks::Install.new :logo => 'streambox'

