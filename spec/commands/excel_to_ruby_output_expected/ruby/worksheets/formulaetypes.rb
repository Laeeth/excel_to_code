# FormulaeTypes

require_relative '../examplespreadsheet'

module ExampleSpreadsheet
class Formulaetypes < Spreadsheet
  def a1; "Simple"; end
  def b1; 2; end
  def a2; "Sharing"; end
  def b2; 267.7467614837482; end
  def a3; "Shared"; end
  def b3; 267.7467614837482; end
  def a4; "Shared"; end
  def b4; 267.7467614837482; end
  def a5; "Array (single)"; end
  def b5; 2; end
  def a6; "Arraying (multiple)"; end
  def b6; excel_if(excel_equal?(267.7467614837482,8),"Eight","Not Eight"); end
  def a7; "Arrayed (multiple)"; end
  def b7; excel_if(excel_equal?(267.7467614837482,8),"Eight","Not Eight"); end
  def a8; "Arrayed (multiple)"; end
  def b8; excel_if(excel_equal?(2,8),"Eight","Not Eight"); end

end
end
