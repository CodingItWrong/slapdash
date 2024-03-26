# Pin npm packages by running ./bin/importmap

pin "application"
pin_all_from "app/javascript/prism", under: "prism"
pin "bootstrap", to: "bootstrap.min.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
