# Pin npm packages by running ./bin/importmap

pin "application"
pin "chartkick" # @5.0.1
pin "chart.js", to: "https://cdn.jsdelivr.net/npm/chart.js"

pin "@kurkle/color", to: "@kurkle--color.js" # @0.3.4
pin "@rails/actioncable", to: "@rails--actioncable.js" # @8.0.100
#pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2

pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.2/dist/stimulus.js"
pin "@hotwired/stimulus-loading", to: "https://ga.jspm.io/npm:@hotwired/stimulus-loading@3.2.2/dist/stimulus-loading.js"
