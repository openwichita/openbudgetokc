#!/usr/bin/env node

const csv = require('csv')
const fs = require('fs')

const OL3_ID_IDX = 10
const OL2_ID_IDX = 8
const FIRST_COL_HEADER = 'fund'

fs.createReadStream(process.argv[2], { encoding: 'utf8' })
  .pipe(csv.parse())
  .pipe(csv.transform(row => {
    if ( // Is this an interfund transfer? Skip it.
      row[OL2_ID_IDX].toLowerCase() === '510' ||
      row[OL3_ID_IDX].toLowerCase() === '9800'
    ) { return null; }

    if (row[0] === FIRST_COL_HEADER) {
      return row.concat(['account_type', 'fiscal_year'])
    }

    let accountType = accountTypeFromRow(row)
    return row.concat([accountType, '2017'])
  }))
  .pipe(csv.stringify())
  .pipe(process.stdout)

function accountTypeFromRow(row) {
  let firstNumber = parseInt(row[OL3_ID_IDX][0])
  return firstNumber <= 5 && firstNumber !== 0 ? 'Expense' : 'Revenue'
}
