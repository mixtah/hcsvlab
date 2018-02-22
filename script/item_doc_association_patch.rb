# Script to patch mismatch item to document association.
#
# Karl Li

# read corrected info from corrected-item-doc.csv

require 'csv'

script_dir = File.join(File.expand_path("~"), 'tmp')
csv_file = File.join(script_dir, 'corrected-item-doc.csv')
sql_file = File.join(script_dir, 'corrected-item-doc.patch.sql')

total_lines = CSV.read(csv_file).length

sql = ''

CSV.foreach(csv_file, headers: true).with_index(1) do |csv_line, i|

  item_id = csv_line['item.id']
  item_handle = csv_line['item.handle']
  doc_id = csv_line['doc.id']
  doc_filepath = csv_line['doc.file_name']
  doc_filename = File.basename(doc_filepath)

  progress = (i*1.0 / total_lines) * 100
  printf "Processing document[%s]...(%2.2f%%) \r", doc_id, progress

  # check file existence
  if File.exists?(doc_filepath)
    sql += "update documents set file_name='#{doc_filename}', file_path='#{doc_filepath}' where id='#{doc_id}';\n"
  else
    puts "File[#{doc_filepath}] not found. item_id[#{item_id}] item_handle[#{item_handle}] doc_id[#{doc_id}]"
  end

end

File.open(sql_file, 'w') {|file| file.write(sql)}

puts "result: #{sql_file}"