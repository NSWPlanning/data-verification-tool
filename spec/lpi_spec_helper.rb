# Used for testing non-rails LPI code stored in lib/
Dir[
  File.join(
    File.expand_path(File.dirname(__FILE__)),
    ("../lib/extra_libs/dvt/**/*.rb")
  ),
  File.join(
    File.expand_path(File.dirname(__FILE__)),
    ("../lib/extra_libs/lga/**/*.rb")
  ),
  File.join(
    File.expand_path(File.dirname(__FILE__)),
    ("../lib/extra_libs/lpi/**/*.rb")
  )
].each {|f| require f}

module LpiSpecHelpers
  def fixture_filename(filename)
    File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', filename))
  end
end
