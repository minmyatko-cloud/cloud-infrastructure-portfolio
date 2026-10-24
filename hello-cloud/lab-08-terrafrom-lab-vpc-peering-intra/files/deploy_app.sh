#!/bin/bash
# Script to deploy a very simple web application.
# The web app has a customizable image and some text.

cat << EOM > /var/www/html/index.html
<html>
  <head><title>Hellooooooooooooooooo!</title></head>
  <body>
  <div style="width:800px;margin: 0 auto">

  <!-- BEGIN -->
  <center><img src="http://${PLACEHOLDER}/${WIDTH}/${HEIGHT}?id=${PLACEHOLDER_ID}"></img></center>
  <center><h2>Hellooooooooooooooo Cloud!</h2></center>
  Welcome to ${PREFIX}'s app. Hellooooooooooooooooooo!!!.

  <!-- END -->

  </div>
  </body>
</html>
EOM

echo "Script complete."
