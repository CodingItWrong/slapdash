# Pin npm packages by running ./bin/importmap

pin "application"
pin_all_from "vendor/javascript/prism", under: "prism"
pin "bootstrap", to: "vendor/javascript/bootstrap.min.js"
pin "@hotwired/turbo-rails", to: "vendor/javascript/turbo.min.js"
pin "@hotwired/stimulus", to: "vendor/javascript/stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "vendor/javascript/stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
