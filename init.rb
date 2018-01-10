require 'redmine'
require File.dirname(__FILE__) + "/lib/traceability_matrix_macros"

Redmine::Plugin.register :traceability_matrix do
  name 'Redmine Traceability Matrix'
  author 'SeaSideTech'
  version '0.3.1'
  description 'Plugin to show the traceability matrix between two lists of issues'
  author_url 'http://www.seasidetech.net/en/index.php'


  # This plugin adds a project module
  # It can be enabled/disabled at project level (Project settings -> Modules)
  project_module :traceability do
    # This permission has to be explicitly given
    # It will be listed on the permissions screen
    permission :view_mt, {:mt => [:index]}
  end

end
