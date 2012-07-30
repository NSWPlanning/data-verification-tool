RSpec::Matchers.define :have_page_title do |expected|
  match do |actual|
    actual.title == expected
    !actual.title.match(expected).nil?
  end

  failure_message_for_should do |actual|
    "expected page title '#{actual.title}' to match #{expected}"
  end

  failure_message_for_should_not do |actual|
    "expected page title '#{actual.title}' not to match #{expected}"
  end

  description do
    "have a title matching #{expected}"
  end
end
