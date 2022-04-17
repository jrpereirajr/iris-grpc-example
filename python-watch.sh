# used to copy all python code to IRIS python dir
while inotifywait -r -e modify /irisrun/repo/jrpereira/python; do
    iris session iris "##class(%ZPM.PackageManager).Shell(\"load /irisrun/repo/ -v\",1,1)"
    iris session iris "##class(%ZPM.PackageManager).Shell(\"test iris-grpc-example -v\",1,1)"
done