#!/usr/bin/env node

const csv = require('csv')
const fs = require('fs')
const Case = require('case')

const OL3_ID_IDX = 11
const OL2_ID_IDX = 9
const FUND_TITLE = 2
const DEPT_TITLE = 6
const OCA_TITLE = 14 // item description in budget tree
const OBJ_LVL_1_TITLE = 8
const OBJ_LVL_2_TITLE = 10
const FIRST_COL_HEADER = 'OBJECTID'

fs.createReadStream(process.argv[2], { encoding: 'utf8' })
  .pipe(csv.parse())
  .pipe(csv.transform(row => {
    if ( // Is this an interfund transfer? Skip it.
      (
        row[FUND_TITLE].toLowerCase() === 'general fund' &&
        row[OCA_TITLE].toLowerCase() === 'appropriated fund balance'
      ) ||
      row[FUND_TITLE].toLowerCase() === 'metro area building & construction fund'
    ) { return null }

    if (row[0] === FIRST_COL_HEADER) {
      return row.concat(['account_type', 'fiscal_year'])
    }

    // The Wichita budget has some entries where the dept title
    // for Public Works mistakenly has two spaces in it, so we
    // consolidate those here.
    if (row[DEPT_TITLE] === 'Public Works  & Utilities') {
      row[DEPT_TITLE] = 'Public Works & Utilities'
    }

    // make all description titles title-case
    row[FUND_TITLE] = Case.title(row[FUND_TITLE])
    row[DEPT_TITLE] = Case.title(row[DEPT_TITLE])
    row[OCA_TITLE] = Case.title(row[OCA_TITLE])
    row[OBJ_LVL_1_TITLE] = Case.title(row[OBJ_LVL_1_TITLE])
    row[OBJ_LVL_2_TITLE] = Case.title(row[OBJ_LVL_2_TITLE])

    let accountType = accountTypeFromRow(row)
    return row.concat([accountType, '2017'])
  }))
  .pipe(csv.stringify())
  .pipe(process.stdout)

function accountTypeFromRow (row) {
  let firstNumber = parseInt(row[OL3_ID_IDX][0])
  return firstNumber <= 5 && firstNumber !== 0 ? 'Expense' : 'Revenue'
}
