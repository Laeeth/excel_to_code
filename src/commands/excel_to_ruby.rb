require 'fileutils'
require_relative '../extract'
require_relative '../rewrite'

class ExcelToRuby
  
  attr_accessor :excel_file, :output_directory, :xml_dir
  
  def go!
    sort_out_output_directories
    unzip_excel
    process_workbook
    initial_extract_from_worksheets
  end
  
  def sort_out_output_directories
    self.excel_file = File.expand_path(excel_file)
    self.output_directory = File.expand_path(output_directory)
    FileUtils.mkdir_p(File.join(output_directory,'intermediate'))
  end
  
  def unzip_excel
    self.xml_dir = File.join(output_directory,'xml')
    puts `unzip -uo '#{excel_file}' -d '#{xml_dir}'`
  end

  # Extract the shared strings    
  # Extract the sheet names, initialy with relationship references
  # Extract the workbook relationships
  # Use these to create the sheet names and filenames
  def process_workbook    
    extract ExtractSharedStrings, 'sharedStrings.xml', 'shared_strings'
    extract ExtractWorksheetNames, 'workbook.xml', 'worksheet_names_without_filenames'
    extract ExtractRelationships, File.join('_rels','workbook.xml.rels'), 'workbook_relationships'
    rewrite RewriteWorksheetNames, 'worksheet_names_without_filenames', 'workbook_relationships', 'worksheet_names'
  end
  
  def initial_extract_from_worksheets
    worksheets do |name,xml_filename|
      fork do
        $0 = "ruby initial extract #{name}"
        initial_extract_from_worksheet(name,xml_filename)
      end
    end
    Process.waitall
  end
  
  # Extracts:
  # Values
  # Formulae (simple, shared and array)
  # Rewrites:
  # the formulae to ast
  # the values to replace shared strings with their values
  def initial_extract_from_worksheet(name,xml_filename)
    worksheet_directory = File.join(output_directory,'intermediate',name)
    FileUtils.mkdir_p(worksheet_directory)
    worksheet_xml = File.open(xml_filename,'r')
    { ExtractValues => 'values', 
      ExtractSimpleFormulae => 'simple_formulae',
      ExtractSharedFormulae => 'shared_formulae',
      ExtractArrayFormulae => 'array_formulae'
    }.each do |_klass,output_filename|
      worksheet_xml.rewind
      extract _klass, worksheet_xml, File.join(name,output_filename)
      if _klass == ExtractValues
        rewrite RewriteValuesToIncludeSharedStrings, File.join(name,output_filename), 'shared_strings', File.join(name,"#{output_filename}_no_shared_strings")
      else
        rewrite RewriteFormulaeToAst, File.join(name,output_filename), File.join(name,"#{output_filename}.ast")
      end  
    end
    close(worksheet_xml)
  end
  
  def worksheets
    IO.readlines(File.join(output_directory,'intermediate','worksheet_names')).each do |line|
      name, filename = *line.split("\t")
      filename = File.expand_path(File.join(xml_dir,'xl',filename.strip))
      yield name, filename
    end
  end
  
  def extract(_klass,xml_name,output_name)
    i = xml_name.is_a?(String) ? xml(xml_name) : xml_name
    o = output(output_name)
    _klass.extract(i,o)
    if xml_name.is_a?(String)
      close(i)
    end
    close(o)
  end
  
  def rewrite(_klass,*args)
    o = output(args.pop)
    inputs = args.map { |name| input(name) }
    _klass.rewrite(*inputs,o)
    close(*inputs,o)
  end
  
  def xml(*args)
    File.open(File.join(xml_dir,'xl',*args),'r')
  end
  
  def input(*args)
    File.open(File.join(output_directory,'intermediate',*args),'r')
  end
  
  def output(*args)
    File.open(File.join(output_directory,'intermediate',*args),'w')
  end
  
  def close(*args)
    args.map(&:close)
  end
  
end