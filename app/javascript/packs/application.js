// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import 'bootstrap'

document.addEventListener("turbolinks:load", function() {
  Prism.highlightAll()
  addBootstrapClassesToRenderedMarkdown()
})

const BOOTSTRAP_TABLE_CLASSES = [
  'table',
  'table-sm',
  'table-hover',
  'table-responsive-md',
]

function addBootstrapClassesToRenderedMarkdown() {
  const tables = document.querySelectorAll('.rendered-markdown table')
  for (let table of tables) {
    table.classList.add(...BOOTSTRAP_TABLE_CLASSES)
  }
}
