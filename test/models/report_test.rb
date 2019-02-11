require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  test 'require name' do
    assert_not Report.create.valid?
  end

  test 'create report' do
    assert Report.create(name: 'Test Report').valid?
  end
end
