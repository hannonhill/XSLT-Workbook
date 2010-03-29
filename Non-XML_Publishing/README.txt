json-template.xml should be created as a Template whose Configuration (Set) publishes
with serialization type XML and whatever file extension is desired on the server
(e.g. .js, .json)

json-output.xsl should be attached to the JSON region of the template with an
Index Block that returns all the desired pages.

The final comment in the template terminates the JSON output, allowing the preceding
<xml> element to be suppressed. Final output will look like:

({
 "items":
 	[ {"name": "case-studies"}, 
      {"name": "awards"}, 
      {"name": "Conference-Registration-Open"}, 
      {"name": "cs-6"}, 
      {"name": "index"}, 
      {"name": "uas"}, 
      {"name": "index"}, 
      {"name": "cs-57"}, 
      {"name": "white-papers"}, 
      {"name": "index"}, 
      {"name": "inc-500"}, 
      {"name": "gonzaga-seo"}, 
      {"name": "buyers-guide"}, 
      {"name": "north-highland"}, 
      {"name": "seo-panel"}, 
      {"name": "index"}, 
      {"name": "secureworks"}, 
      {"name": "index"}, 
      {"name": "best-of-show"}, 
      {"name": "index"}, 
      {"name": "index"}, 
      {"name": "archives"}, 
      {"name": "others"}, 
      {"name": "partnerships"}, 
      {"name": "upgrades"}, 
      {"name": "resources"}, 
      {"name": "events"}, 
      {"name": "test-json"}],
 "bogus": "<xml></xml>"
})