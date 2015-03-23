require '../test_helper'

class PropertiesTest < ActionController::TestCase
  setup do
    @property = Property.first
  end

  test "should get record" do
    assert @property.pin == "05-21-100-003-0000"
  end

end