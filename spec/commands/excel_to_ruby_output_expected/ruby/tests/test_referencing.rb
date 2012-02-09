# Test for Referencing
require 'test/unit'
require_relative '../examplespreadsheet'

module ExampleSpreadsheet
class TestReferencing < Test::Unit::TestCase
  def worksheet; Referencing.new; end
  def test_a4; assert_equal(10,worksheet.a4); end
  def test_b4; assert_equal(11,worksheet.b4); end
  def test_c4; assert_equal(12,worksheet.c4); end
end
end
