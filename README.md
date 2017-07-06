# Open Budget Wichita

[![Build Status](https://api.travis-ci.org/openwichita/openbudgetwichita.svg?branch=master)](https://travis-ci.org/openwichita/openbudgetwichita)

## Chat

Join the Open Wichita Slack room here: https://openwichita-slack.herokuapp.com/. Once there, check out the #openbudget channel for discussion about this project.

## Getting Started

__Fork me!__

Fork and clone the project!

```
$ git clone git@github.com:[your-user]/openbudgetwichita.git
$ cd openbudgetwichita
```

[](TODO: Point to our wiki, once we have one)
[Read helpful info about image sizes, data types and color schemes on the wiki.](https://github.com/openwichita/openbudgetwichita/wiki)

---
## Developing Locally

### D3 Sandbox

Most of the new development on Wichita data visualizations is currently occuring in the sandbox directory. Each of the charts can be viewed by opening them directly in your browser.

```
$ open openbudgetwichita/sandbox/zoomable.html
```

This area is in active development so all of the graphs may not be functioning correctly!


#### Generating json files from a csv

We have a small script written in ruby for generating a json file from a csv of city data. The script asks for the file and then steps through each required field and asks you to specify the correct header which matches. 

To run the script
```
$ cd <project_root>/data-utilities
$ ruby data_to_json.rb
```

### Harp

This site is built on Harp using Node.js That means you can run it locally with minimal setup!

What you'll need:

-  [Node](https://nodejs.org/en/download)
-  [Harp](http://harpjs.com)


### Install & Run

Once you have npm installed,

```
# to install dependencies and run
npm install && npm start

# npm install can be omitted on subsequent runs
npm start
```
#### Pitfalls

* node version 6

Currently, there is a problem with installing on node V6
It can be fixed by changing the harp line to
+ ```  "harp": "https://github.com/sintaxi/harp.git#v0.21.0-pre" ```
in the ``` package.json ``` at the root of this project. 


## Making Changes

This project is coded with:

- [jade](https://pugjs.org) (now called pug)
- [Sass](http://sass-lang.com/)
- [Bootstrap](http://getbootstrap.com/)


## Creating & Editing Pages

- Page content is inserted into the layout.jade file (which includes basic header and footer snippets)
- Create your .jade file
- Add a link to the main nav in the appropriate place
- Add relevant metadata in _data.json (page title, page slug (url), ...)
- If your page uses custom page-specific css, add it to a new .scss partial and import it into the main stylesheet. (Make sure to namespace it the same way the others are.)


### Additional instructions for "flow" diagram pages

To request revenue and expense data for a new fiscal year, submit an Open Records request and type the following in the description field. Update FYXX with the last two digits of the year (ex: FY16).

-A csv file of the City of Wichita revenue and expenditure budget for FYXX, including Fund, Fund name, Operating Unit, Operating Unit Description, Agency, Agency Name, Program ID, Program Name, Line of Business ID, Line of Business name, Account, Account Name, Account Description, Budget Amount. (Budget database query names qry_Current_Yr_Budget_detail and qry_Current_Yr_Budget_Detail_Revenue)

This chart takes as input the full budget datatable from data.oaklandnet.com
(in CSV format)

Right now the 2015-17 Proposed page is an unpublished placeholder, pending the data release. When the data becomes available: 

1. add the CSV to `_src/data/proposed_1517_flow/` and **remove the placeholder file FY13-14__FY14-15.csv**
1. rename the file to include the two fiscal years it includes, separated by two underscores ("FY15-16__FY16-17.csv")
1. open the csv and make sure all column headings are standardized to the following names:
1. Flow pages are built off a template; copy one of the `*-budget-flow.jade` pages and update the content blocks as necessary.
1. Data files must be placed in the `data/flow` directory. Follow the naming convention seen there or your files won't load properly. You also will need to point your page at the appropriate files as seen in the `get_datafiles` content block.
1. the following columns are required in your datafile and their names should be normalized as seen here. Other columns should be removed to minimize the data download.
    - budget_year
    - department
    - fund_code
    - account_type (this should be the Expense/Revenue column, if there are duplicate names)
    - account_category
    - amount

### Additional instructions for treemap diagram pages

1. Treemap pages are built off a template; copy one of the `*-budget-tree.jade` pages and update the content blocks as necessary.
1. Instructions for generating the necessary data files can be found [here](_treemap/README.md). Add them to the `data/tree/` directory following the naming convention seen in the existing files.
1. Update the `datafiles` content block with the appropriate metadata and file path for the data files you generated.

## Contributing

If you're new to contributing to open source projects Github has a pretty great [video series](https://egghead.io/series/how-to-contribute-to-an-open-source-project-on-github).

If you're comfortable already, our workflow is:
- [Fork the repo.](https://help.github.com/articles/fork-a-repo/)
- Make your changes.
- Commit the changes. ([How to write a great commit message!](https://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message))
- Push them to your fork.
- [And open a pull request.](https://help.github.com/articles/using-pull-requests/)
