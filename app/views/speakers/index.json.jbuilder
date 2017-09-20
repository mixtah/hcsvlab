#
# GET returns a list of speaker identifiers (URIs) associated with this collection
#
# format:
# {
#   "speakers": [
#     "URI1",
#     "URI2"
#   ]
# }
#
# e.g.,
# {
#   "speakers": [
#       "https://app.alveo.edu.au/speakers/austalk/1_116",
#       "https://app.alveo.edu.au/speakers/austalk/1_117"
#   ]
# }


json.speakers do
  json.array! @speaker_uri
end



