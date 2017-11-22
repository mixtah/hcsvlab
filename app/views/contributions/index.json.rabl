#
# {"contributions" :
#  [{"name" : "ace", "url" : "https://app.alveo.edu.au/contrib/1"},
#  {"name" : "cooee", "url" : "https://app.alveo.edu.au/contrib/2"},
#  {"name" : "ice", "url": "https://app.alveo.edu.au/contrib/3"},
#  {"name" : "austalk", "url": "https://app.alveo.edu.au/contrib/4"}]
#  }
#

collection @contributions => "contributions"
attributes :name
node(:url) {|c| contrib_show_url(c.id)}