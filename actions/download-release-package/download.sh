
org=freenet-group
groupId=de.md.mcbs.ms
#artifactId=ms-commondata
artifactId=ms-rating
#version=0.0.0-SNAPSHOT
version=1.9.6-SNAPSHOT
#version=0.0.0-20230119.141912-1
fileName=$artifactId-1.9.6-20230118.143338-13.jar
repo=$artifactId

curl -v -O -L "https://_:$token@maven.pkg.github.com/$org/$repo/$groupId/$artifactId/$version/$fileName"
