$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'confluencer'
require 'spec'
require 'spec/autorun'
require 'yaml'

require 'log4r/yamlconfigurator'

Spec::Runner.configure do |config|
  config.before :suite do
    Log4r::YamlConfigurator.load_yaml_file(File.join(File.dirname(__FILE__), 'confluence.yaml'))
  end
end

module ConfigurationHelperMethods
  def config
    # load configuration
    @config ||= YAML.load(File.open(File.join(File.dirname(__FILE__), 'confluence.yaml')))[:test]
  end
end

module SessionHelperMethods
  include ConfigurationHelperMethods
  
  def new_session
    if block_given?
      # initialize session and yield
      Confluence::Session.new(config) {|client| yield client }
    else
      # initialize session and return
      Confluence::Session.new config
    end
  end
end

module PageHelperMethods
  include SessionHelperMethods
  
  def create_test_page(content = "foobar")
    Confluence::Page.new :space => config[:space], :title => config[:page_title], :content => content
  end
    
  def with_test_page
    new_session do
      begin
        # yield created test page
        yield page = create_test_page.store
      ensure
        # remove test page
        page.remove
      end
    end
  end
end  
