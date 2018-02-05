# coding: utf-8

require_relative 'excel_to_x'

class ExcelToGo < ExcelToX
  
  def language
    'go'
  end  
  
  # Skip this
  def replace_values_with_constants    
  end
  
  # These actually create the code version of the excel
  def write_code
    write_out_excel_as_code
    write_out_test_as_code
  end
    
  def write_out_excel_as_code
    log.info "Starting to write out code"
    
    o = output("#{output_name.downcase}.go")

    o.puts "// Compiled version of #{excel_file}"
    o.puts "package #{output_name.downcase}"
    o.puts
    o.puts "import \"./excel\""
    o.puts

    c = CompileToGo.new
    c.settable = settable
    c.gettable = gettable
    c.rewrite @formulae, @worksheet_c_names, o
    o.puts

    close(o)
    log.info "Finished writing code"
  end

  def write_out_test_as_code
    log.info "Starting to write out test"
    
    o = output("#{output_name.downcase}_test.go")

    o.puts "// Test of compiled version of #{excel_file}"
    o.puts "package #{output_name.downcase}"
    o.puts
    o.puts "import ("
    o.puts "    \"./excel\""
    o.puts "    \"testing\""
    o.puts ")"
    o.puts

    c = CompileToGoTest.new
    c.settable = settable
    c.gettable = gettable
    c.rewrite @formulae, @worksheet_c_names, o
    o.puts

    close(o)
    log.info "Finished writing tests"
  end
  
  def compile_code
    # Not needed
  end
  
  def run_tests
    return unless actually_run_tests
    puts "Running the resulting tests"
    puts `cd #{File.join(output_directory)}; go test #{output_name.downcase}`
  end
  
end
