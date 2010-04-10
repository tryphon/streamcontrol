module LinkToMatcher
  include Spec::Rails::Matchers
 
  def have_link_to(url)
    AssertSelect.new(:assert_select, self, "a[href=#{url}]")
  end
end

Spec::Runner.configure do |config|
  config.include LinkToMatcher, :type => :view
end
