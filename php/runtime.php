<?php

// This invokes Composer's autoloader so that we'll be able to use Guzzle and any other 3rd party libraries we need.
require __DIR__ . '/vendor/autoload.php';

define(1, 'laravel');
define(2, 'codeigniter');

$platform = 0;

// This is the request processing loop. Barring unrecoverable failure, this loop runs until the environment shuts down.
do {

    // Ask the runtime API for a request to handle.
    $request = getNextRequest();

    //Get invocationId and Payload from request.
    $invocationId = $request->getHeader('Lambda-Runtime-Aws-Request-Id')[0];
    $payLoad =  json_decode((string) $request->getBody(), true);

    require_once $_ENV['LAMBDA_TASK_ROOT'] . '/src/public/index.php';

    if ($platform == 1) {
        $headers['Content-type'] = $response->headers->get('Content-type');
        $statusCode = $response->status();
        $content = $response->content();
    }else if ($platform == 2){
        $headers['Content-type'] = $response->getHeaderLine('Content-type');
        $statusCode = $response->getStatusCode();
        $content = $response->getBody();
    }else{
        $headers['Content-type'] = "text/html; charset=UTF-8";
        $statusCode = 200;
        $content = $response;
    }

   //Prepare response for runtime API.
    $data = [
        'statusCode' => $statusCode,
        'isBase64Encoded' => false,
        'headers' => $headers,
        'body' => $content
    ];

    // Submit the response back to the runtime API.
    sendResponse($invocationId, $data);
} while (true);

function getNextRequest()
{
    $client = new \GuzzleHttp\Client();

    //Send request to lambda function.
    return $client->get('http://' . $_ENV['AWS_LAMBDA_RUNTIME_API'] . '/2018-06-01/runtime/invocation/next');
}

function sendResponse($invocationId, $response)
{
    $client = new \GuzzleHttp\Client();

    //Get response from lambda function and send it to client.
    $client->post(
        'http://' . $_ENV['AWS_LAMBDA_RUNTIME_API'] . '/2018-06-01/runtime/invocation/' . $invocationId . '/response',
        ['body' => json_encode($response)]
    );

}
