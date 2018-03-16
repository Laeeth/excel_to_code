# coding: utf-8

require_relative 'excel_to_x'
require 'pathname'

class ExcelToGo < ExcelToX

  attr_accessor :excel_go_lib
  
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
    o.puts "import #{excel_go_lib.inspect}"
    o.puts

    c = CompileToGo.new
    c.settable = settable
    c.gettable = gettable
    c.rewrite @formulae, @worksheet_c_names, o
    o.puts

    close(o)
    log.info "Finished writing code"

    copy_to_output 'src/compile/go/excel.go', 'excel.go'
  end

  def write_out_test_as_code
    log.info "Starting to write out test"
    
    o = output("#{output_name.downcase}_test.go")

    o.puts "// Test of compiled version of #{excel_file}"
    o.puts "package #{output_name.downcase}"
    o.puts
    o.puts "import ("
    o.puts "    #{excel_go_lib.inspect}"
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
    log.info "Running the resulting tests"
    log.info `cd #{File.join(output_directory)}; go test`
  end

  def excel_go_lib
    @excel_go_lib || guess_excel_go_lib
  end

  def guess_excel_go_lib
    log.info "Calculating --import-excel-go path"
    gohome = `go env GOPATH`
    if $?.exitstatus != 0
      gohome = ENV['GOPATH']
    end
    if File.exists?(gohome)

    end
    log.info gohome
    
  end
end