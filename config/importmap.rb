# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "dropzone" # @6.0.0
pin "just-extend" # @5.1.1
pin "@rails/activestorage", to: "@rails--activestorage.js" # @7.1.3
pin "jquery" # @3.7.1
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "flatpickr" # @4.6.13
pin "fullcalendar" # @6.1.11
pin "moment" # @2.30.1
pin "@rails/actioncable", to: "actioncable.esm.js"
pin_all_from "app/javascript/recurring_select", under: "recurring_select"
pin_all_from "app/javascript/channels", under: "channels"
