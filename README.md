# Timebomb
Timebomb is a simple HTTP request scheduling app. Users schedule requests via Timebomb's REST API.

## Quick Start
The easiest way to use Timebomb is as a service. Simply send a `POST` request to `/bombs` with three values: `request_params` as JSON, `timestamp`, and `url`. These can be sent in the request body as JSON or as querystring parameters.

Sample parameters:
``` json
{
  "request_params": "{\"foo\": 1, \"bar\": 2}",
  "timestamp": 505371600,
  "url": "http://example.com"
}
```
*NOTE: Authorization token must be included with all requests. See Authorization section further down.*

### Creating a Bomb
#### The Query

In `curl` with body JSON:
``` shell
curl -X POST -H "Content-Type: application/json" -d '{"request_params":{"foo":1,"bar":2},"timestamp":505371600,"url":"http://example.com"}' http://localhost:9292/bombs
```
In `curl` with querystring parameters:
``` shell
curl --data "request_params=%7B%22foo%22%3A1%2C%22bar%22%3A2%7D&timestamp=505371600&url=http%3A%2F%2Fexample.com" http://localhost:9292/bombs
```
#### The Response
If the request is successful, the response will be a JSON representation of the `Bomb`. If it is unsuccessful, you'll receive a simple HTTP response with the appropriate status code but no body.
``` json
{
  "_id": "522a4f1030de59a7a9000001",
  "request_params": "{\"foo\":1,\"bar\":2}",
  "timestamp":505371600,
  "url": "http://example.com",
  "user_id": "522a4ee130de5996ac000001"
}
```
### Retrieving a Bomb
#### The Query

In `curl`:
``` shell
curl http://localhost:9292/bombs/522a4f1030de59a7a9000001
```

### The Response
``` json
{
  "_id": "522a4f1030de59a7a9000001",
  "request_params": "{\"foo\":1,\"bar\":2}",
  "timestamp":505371600,
  "url": "http://example.com",
  "user_id": "522a4ee130de5996ac000001"
}
```


## Authentication
For the purposes of throttling,  Timebomb uses a simple token authentication system. When you sign up for an account, you'll be given a `token`. You can send this along with each `POST` request as a querystring parameter or in the header.

As a parameter:
```
http://localhost:9292/bombs?token=RWh2RWWpAFpBGklr-DvP4Q
```

In the header:
```
Authorization: Token RWh2RWWpAFpBGklr-DvP4Q
```

## Example Use Case
You could use Timebomb to schedule and queue reminder emails. Let's say you wanted to remind a user to upgrade 10 days after they signed into their account for the first time. You'd build an endpoint that you'd point a Bomb to with your desired parameters (e.g. email address or user ID, message type, etc.).


*****
# Credit
Timebomb was built by Nick Rivadeneira as part of CMP.LY's infrastructure.

# License
The MIT License (MIT)

Copyright (c) 2013 Nicholas Rivadeneira

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
