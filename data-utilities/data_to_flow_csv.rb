#!/usr/bin/env ruby
#
# This script converts city data in csv format to a csv format consumable by the flow diagram.
# Use the script arguments to match the csv headers to the correct csv column keys.
#
# Sample call that uses some defaults:
# ./data-utilities/data_to_flow_csv.rb 
#   -i data/2017-wichita-adopted-budget-processed.csv 
#   -o _src/data/flow/2017__adopted.csv
#
# Sample call to map json keys to specific csv header names:
# ./data-utilities/data_to_flow_csv.rb 
#   -i data/2017-wichita-adopted-budget-processed.csv 
#   -o _src/data/flow/2017__adopted.csv
#   --agency=dept_title \
#   --fund=org_cost_acct \
#   --lob=oca_title \
#   --program=obj_lvl_3_title \
#   --key=obj_lvl_3_title \
#   --value=appropriation_amt

require 'csv'
require 'optparse'

options = {}

# Maybe sane defaults
options[:fileout] = nil
options[:agency] = 'dept_title'
options[:fund] = 'obj_lvl_3'
options[:fundtype] = 'fund'
options[:lob] = 'oca_title'
options[:program] = 'obj_lvl_1_title'
options[:key] = 'obj_lvl_3_title'
options[:value] = 'appropriation_amt'
options[:accounttype] = 'account_type'

OptionParser.new do |opts|
  opts.banner = "Usage: data_to_json.rb [options]"
  opts.on('-i', '--inputfile filename', '') { |v| options[:filein] = v }
  opts.on('-o', '--outputfile filename', '') { |v| options[:fileout] = v }
  opts.on('-a', '--agency columnName', 'csv column representing the "agency"') { |v| options[:agency] = v }
  opts.on('-f', '--fund columnName', 'csv column representing the "fund"') { |v| options[:fund] = v }
  opts.on('-p', '--program columnName', 'csv column representing the "program"') { |v| options[:program] = v }
  opts.on('-k', '--key columnName', 'csv column representing the "key"') { |v| options[:key] = v }
  opts.on('-v', '--value columnName', 'csv column representing the "value"') { |v| options[:value] = v }
  opts.on('-t', '--fundtype columnName', 'csv column representing the "fund type"') { |v| options[:fundtype] = v }
  opts.on('-c', '--accounttype columnName', 'csv column representing the "account type"') { |v| options[:accounttype] = v }
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
idx[:program] = headers.find_index(options[:program])
idx[:key] = headers.find_index(options[:key])
idx[:value] = headers.find_index(options[:value])
idx[:fundtype] = headers.find_index(options[:fundtype])
idx[:accounttype] = headers.find_index(options[:accounttype])

idx.each do |k, v|
  if v == nil || !(v.to_i >= 0 && v.to_i < headers.length)
    raise "Json key #{k} does not match a header in csv. Validate input."
  end
end

CSV.open(options[:fileout], "w") do |csvout|
  csvout << ["budget_year","account_type","department","fund_code","account_category","amount","fund_type"]

    csv.each do |row|
    # In the Wichita dataset, the `obj_lvl_3` column (which correlates to
    # "account" here) determines whether the line is revenue or an expenditure. If
    # it begins with 1-5, it's an expense, and 6-9 notates revenue.
    
        budgetYear = "2017"
        fund = row[idx[:fund]].strip
        accountType = row[idx[:accounttype]].strip
        value = row[idx[:value]].gsub('$', '').gsub(',', '').gsub('.00', '')
        fundType = row[idx[:fundtype]].strip

        program = accountType == "Revenue" ? row[idx[:program]].strip : nil
        department = accountType == "Revenue" ? nil : row[idx[:agency]].gsub(/\s+/, ' ').strip

        csvout << [budgetYear, accountType, department, fund, program, value, fundType]  
    end
end
