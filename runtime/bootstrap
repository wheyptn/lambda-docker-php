#!/usr/bin/php
<?php

// This invokes Composer's autoloader so that we'll be able to use Guzzle and any other 3rd party libraries we need.
$vendor_dir = '/opt/vendor';
require $vendor_dir . '/autoload.php';

// This is the request processing loop. Barring unrecoverable failure, this loop runs until the environment shuts down.
do {
  // Ask the runtime API for next to handle.
  $next = getNext();
  try {
    // Obtain the function name from the _HANDLER environment variable and ensure the function's code is available.
    $handlerFunction = explode(".", getenv('_HANDLER'));
    require_once getenv('LAMBDA_TASK_ROOT') . '/' . $handlerFunction[0] . '.php';
    try {
      // Execute the desired function and obtain the response.
      $response = $handlerFunction[1]($next['event'], $next['context']);
      // Submit the response back to the runtime API.
      sendResponse($next['context']['aws_request_id'][0], $response);
    } catch (Throwable $e) {
      // Submit the error back to the runtime API.
      sendError($next['context']['aws_request_id'][0], $e);
    }
  } catch (Throwable $e) {
    // Submit the init error back to the runtime API.
    sendInitError($e);
  }
} while (true);

function getNext()
{
  $client = new \GuzzleHttp\Client();
  $response = $client->get('http://' . getenv('AWS_LAMBDA_RUNTIME_API') . '/2018-06-01/runtime/invocation/next');
  return [
    'event' => json_decode((string) $response->getBody(), true),
    'context' => [
      'function_name' => getenv('AWS_LAMBDA_FUNCTION_NAME'),
      'function_version' => getenv('AWS_LAMBDA_FUNCTION_VERSION'),
      'invoked_function_arn' => $response->getHeader('Lambda-Runtime-Invoked-Function-Arn'),
      'memory_limit_in_mb' => getenv('AWS_LAMBDA_FUNCTION_MEMORY_SIZE'),
      'aws_request_id' => $response->getHeader('Lambda-Runtime-Aws-Request-Id'),
      'log_group_name' => getenv('AWS_LAMBDA_LOG_GROUP_NAME'),
      'log_stream_name' => getenv('AWS_LAMBDA_LOG_STREAM_NAME'),
      'deadline_ms' => $response->getHeader('Lambda-Runtime-Deadline-Ms'),
      'trace_id' => $response->getHeader('Lambda-Runtime-Trace-Id'),
      'x_amzn_trace_id' => getenv('_X_AMZN_TRACE_ID'),
      'identity' => $response->getHeader('Lambda-Runtime-Cognito-Identity'),
      'client_context' => $response->getHeader('Lambda-Runtime-Client-Context')
    ]
  ];
}

function sendResponse($requestId, $response)
{
  $client = new \GuzzleHttp\Client();
  $client->post(
    'http://' . getenv('AWS_LAMBDA_RUNTIME_API') . '/2018-06-01/runtime/invocation/' . $requestId . '/response',
    ['body' => $response]
  );
}

function sendError($requestId, $error)
{
  $response = json_encode(array('errorMessage' => $error->getMessage(), 'errorType' => get_class($error)));
  $client = new \GuzzleHttp\Client();
  $client->post(
    'http://' . getenv('AWS_LAMBDA_RUNTIME_API') . '/2018-06-01/runtime/invocation/' . $requestId . '/error',
    [
      'body' => $response,
      'headers' => [
        'Lambda-Runtime-Function-Error-Type' => 'Unhandled'
      ]
    ]
  );
}

function sendInitError($error)
{
  $response = json_encode(array('errorMessage' => $error->getMessage(), 'errorType' => get_class($error)));
  $client = new \GuzzleHttp\Client();
  $client->post(
    'http://' . getenv('AWS_LAMBDA_RUNTIME_API') . '/2018-06-01/runtime/init/error',
    [
      'body' => $response,
      'headers' => [
        'Lambda-Runtime-Function-Error-Type' => 'Unhandled'
      ]
    ]
  );
}
