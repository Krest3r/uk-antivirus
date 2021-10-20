Map([<Rule '/callbacks/sns/s3/uploaded' (POST, OPTIONS) -> callbacks.handle_s3_sns>,
 <Rule '/scan/s3-object' (PUT, POST, OPTIONS) -> main.scan_s3_object>,  wymaga 3 kluczy json: "bucketName", "objectKey", "objectVersionId"
 <Rule '/scan/direct' (POST, OPTIONS) -> main.scan_direct>,
 <Rule '/callbacks' (HEAD, OPTIONS, GET) -> callbacks.callbacks_root>,
 <Rule '/callbacks/' (HEAD, OPTIONS, GET) -> callbacks.callbacks_root>,
 <Rule '/metrics' (HEAD, OPTIONS, GET) -> metrics.metrics>,
 <Rule '/_status' (HEAD, OPTIONS, GET) -> status.status>,
 <Rule '/' (HEAD, OPTIONS, GET) -> main.root>,
 <Rule '/static/<filename>' (HEAD, OPTIONS, GET) -> static>])

