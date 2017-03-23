#!/usr/bin/env node

const csv = require('csv')
const fs = require('fs')

const OL3_ID_IDX = 10
const FIRST_COL_HEADER = 'fund'

fs.createReadStream(process.argv[2], { encoding: 'utf8' })
  .pipe(csv.parse())
  .pipe(csv.transform(row => {
    if (row[0] === FIRST_COL_HEADER) {
      return row.concat(['account_type', 'fiscal_year'])
    }

    let firstNumber = parseInt(row[OL3_ID_IDX][0])
    let accountType = firstNumber <= 5 ? 'Expense' : 'Revenue'

    return row.concat([accountType, '2017'])
  }))
  .pipe(csv.stringify())
  .pipe(process.stdout)

