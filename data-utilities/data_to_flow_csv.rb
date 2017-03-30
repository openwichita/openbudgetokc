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
idx[:fundtype] = headers.find_index(options[:fundtype])

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
    #
    # Only collecting expenses here
        budgetYear = "2017"
        fund = row[idx[:fund]].strip
        accountType = ([1,2,3,4,5].include? fund[0].to_i) ? "Revenue" : "Expense"
        program = row[idx[:program]].strip
        value = row[idx[:value]].gsub('$', '').gsub(',', '').gsub('.00', '')
        fundType = row[idx[:fundtype]].strip

        csvout << [budgetYear, accountType, nil, fund, program, value, fundType]  
    end
end

# if options[:fileout]
#   file = File.new(options[:fileout] , 'w')
#   file.write data
# else
#   puts data
# end
