Dir[
  File.join(
    File.expand_path(File.dirname(__FILE__)),
    ("../lib/dvt/**/*.rb")
  )
].each {|f| require f}

module LibSpecHelpers
  def fixture_filename(filename)
    File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', filename))
  end
end
