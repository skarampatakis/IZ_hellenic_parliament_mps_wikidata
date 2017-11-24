# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful

 require 'scraperwiki'
 #require 'mechanize'
 require 'rest-client'
 require 'json'
 require "dotenv"
 require 'sparql/client'
 #require 'restclient/components'
 #require 'rack/cache'
 #RestClient.enable Rack::Cache
 Dotenv.load

def mpId(value)
  begin
    mpId = value["mpID"].value
  rescue
    mpId = nil
  end
  mpId
end

def birthDate(value)
  begin
    birthDate = value["birthDate"].value
  rescue
    birthDate = nil
  end
  birthDate
end

def birthPlace(value)
  begin
    birthPlace = value["birthPlace"].value
  rescue
    birthPlace = nil
  end
  birthPlace
end

def gender(value)
  begin
    gender = value["gender"].value
  rescue
    gender = nil
  end
  gender
end

def mpStatus(value)
  begin
    mpStatus = value["mpStatus"].value
  rescue
    mpStatus = nil
  end
  mpStatus
end

def getWikidata(id, original)
  begin
    endpoint = "https://query.wikidata.org/sparql"
    sparql = 'select * where{?entity rdfs:label ?label . filter (lang(?label) = "el") optional {?entity wdt:P19 ?birthPlace .} optional {?entity wdt:P569 ?birthDate .}    optional {?entity wdt:P21 ?gender .} optional {?entity wdt:P2278 ?mpID .} bind(exists {?entity wdt:P39 wd:Q18915989} as ?mpStatus) values ?entity { wd:' + id +'}  }'
    client = SPARQL::Client.new(endpoint, :method => :get)
    rows = client.query(sparql)
    original["hellenic_parliament_id"] = mpId(rows[0])
    original["birth_date"] = birthDate(rows[0])
    original["birth_place"] = birthPlace(rows[0])
    original["gender"] = gender(rows[0])
    original["mpStatus"] = mpStatus(rows[0])
    p "Found and updated"
    original
  rescue
    p "Entity does not exist in wikidata"
    original
  end
end
#ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
# # Read in a page
api_key = ENV["MORPH_API_KEY"]
url = "https://api.morph.io/everypolitician-scrapers/hellenic-parliament-wikipedia/data.json?key=" + api_key + "&query=select%20*%20from%20%22data%22"
response = RestClient.get(url)
json = JSON.parse(response)
#
json.each_with_index do |item,key|
    p "-------------------------------------------------------------------------"
    p item["name"]
    json[key] = getWikidata(item["id"], item)
    p "-------------------------------------------------------------------------"
    ScraperWiki.save_sqlite(["name"], json[key])
end


# # Find somehing on the page using css selectors

#
# # Write out to the sqlite database using scraperwiki library


#
# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries.
# You can use whatever gems you want: https://morph.io/documentation/ruby
# All that matters is that your final data is written to an SQLite database
# called "data.sqlite" in the current working directory which has at least a table
# called "data".
