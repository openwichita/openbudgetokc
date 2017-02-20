#!/usr/bin/env ruby
#
# This script converts city data in csv format to json consumable by the webapp.
# Use the script arguments to match the csv headers to the correct json keys.
#
# Sample call that uses some defaults:
# ./data-utilities/data_to_json.rb \
#   -i _src/data/fy2017/wichita_2017_adopted_budget.csv \
#   -o _src/data/fy2017/wichita_2017_adopted_budget.json
#
# Sample call to map json keys to specific csv header names:
# ./data-utilities/data_to_json.rb \
#   -i _src/data/fy2017/wichita_2017_adopted_budget.csv \
#   -o _src/data/fy2017/wichita_2017_adopted_budget.json \
#   --agency=dept_title \
#   --fund=org_cost_acct \
#   --lob=oca_title \
#   --program=obj_lvl_3_title \
#   --key=obj_lvl_3_title \
#   --value=appropriation_amt

require 'csv'
require 'json'
require 'optparse'

options = {}

# Maybe sane defaults
options[:fileout] = nil
options[:agency] = 'dept_title'
options[:fund] = 'org_cost_acct'
options[:lob] = 'oca_title'
options[:program] = 'obj_lvl_3_title'
options[:key] = 'obj_lvl_3_title'
options[:value] = 'appropriation_amt'

OptionParser.new do |opts|
  opts.banner = "Usage: data_to_json.rb [options]"
  opts.on('-i', '--inputfile filename', '') { |v| options[:filein] = v }
  opts.on('-o', '--outputfile filename', '') { |v| options[:fileout] = v }
  opts.on('-a', '--agency columnName', 'csv column representing the "agency"') { |v| options[:agency] = v }
  opts.on('-f', '--fund columnName', 'csv column representing the "fund"') { |v| options[:fund] = v }
  opts.on('-l', '--lob columnName', 'csv column representing the "lob"') { |v| options[:lob] = v }
  opts.on('-p', '--program columnName', 'csv column representing the "program"') { |v| options[:program] = v }
  opts.on('-k', '--key columnName', 'csv column representing the "key"') { |v| options[:key] = v }
  opts.on('-v', '--value columnName', 'csv column representing the "value"') { |v| options[:value] = v }
end.parse!

if options[:filein] == nil || !File.file?(options[:filein])
  raise "Input file does not exist"
end

# Note this encoding seems to work with utf8-bom and ascii files.
csv = CSV.read(options[:filein], headers: true, encoding: 'bom|utf-8')
headers = csv.headers

idx = {}
idx[:obj_lvl_3_id] = 6
idx[:agency] = headers.find_index(options[:agency])
idx[:fund] = headers.find_index(options[:fund])
idx[:lob] = headers.find_index(options[:lob])
idx[:program] = headers.find_index(options[:program])
idx[:key] = headers.find_index(options[:key])
idx[:value] = headers.find_index(options[:value])

idx.each do |k, v|
  if v == nil || !(v.to_i >= 0 && v.to_i < headers.length)
    raise "Json key #{k} does not match a header in csv. Validate input."
  end
end

data = []

csv.each do |row|
  # In the Wichita dataset, the `obj_lvl_3` column (which correlates to
  # "account" here) determines whether the line is revenue or an expenditure. If
  # it begins with 1-5, it's an expense, and 6-9 notates revenue.
  #
  # Only collecting expenses here
  next unless [1,2,3,4,5].include? row[idx[:obj_lvl_3_id]][0].to_i

  data << {
    # Some data have extra whitespace. Strip 'em all.
    agency: row[idx[:agency]].strip,
    fund: row[idx[:fund]].strip,
    lob: row[idx[:lob]].strip,
    program: row[idx[:program]].strip,
    key: row[idx[:key]].strip,
    # TODO Some of these expenditures are negative. Intentional?
    value: row[idx[:value]].gsub('$', '').gsub(',', '').gsub('.00', '')
  }
end

if options[:fileout]
  file = File.new(options[:fileout] , 'w')
  file.write JSON.pretty_generate(data)
else
  puts JSON.pretty_generate(data)
end
