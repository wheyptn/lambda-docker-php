<?php

function handler($event, $context)
{
  echo json_encode($context);
  return response("queryStringParameters, ". json_encode($event['queryStringParameters']));
}

function response($body)
{
  $headers = array(
    "Content-Type"=>"application/json"
  );
  return json_encode(array(
    "statusCode"=>200,
    "headers"=>$headers,
    "body"=>$body
  ));
}
