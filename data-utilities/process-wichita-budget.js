#!/usr/bin/env node

const csv = require('csv')
const fs = require('fs')
const titleCase = require('title-case')

const OL3_ID_IDX = 10
const OL2_ID_IDX = 8
const FUND_TITLE = 1
const DEPT_TITLE = 5
const OCA_TITLE = 13 // item description in budget tree
const OBJ_LVL_1_TITLE = 7
const OBJ_LVL_2_TITLE = 9
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

    // make all description titles title-case
    row[FUND_TITLE] = titleCase(row[FUND_TITLE])
    row[DEPT_TITLE] = titleCase(row[DEPT_TITLE])
    row[OCA_TITLE] = titleCase(row[OCA_TITLE])
    row[OBJ_LVL_1_TITLE] = titleCase(row[OBJ_LVL_1_TITLE])
    row[OBJ_LVL_2_TITLE] = titleCase(row[OBJ_LVL_2_TITLE])

    let accountType = accountTypeFromRow(row)
    return row.concat([accountType, '2017'])
  }))
  .pipe(csv.stringify())
  .pipe(process.stdout)

function accountTypeFromRow(row) {
  let firstNumber = parseInt(row[OL3_ID_IDX][0])
  return firstNumber <= 5 && firstNumber !== 0 ? 'Expense' : 'Revenue'
}
