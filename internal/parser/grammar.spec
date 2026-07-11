event = name [ "{" label "}" ] ":" value
label = name "=" name
name = letter { letter }
value = [ "-" ] digit { digit }
