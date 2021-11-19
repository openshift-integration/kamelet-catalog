'use strict'

const manifest = {
  "css/site.css": "css/site-a192e92461.css",
  "js/site.js": "js/site-0d18f68ee9.js",
  "js/vendor/algoliasearch.js": "js/vendor/algoliasearch-8fe81df376.js",
  "js/vendor/highlight.js": "js/vendor/highlight-a988c6fdd9.js",
  "js/vendor/svg4everybody.js": "js/vendor/svg4everybody-195d47ce7d.js"
}

module.exports = (resource) => {
  return '/' +  manifest[resource]
}

