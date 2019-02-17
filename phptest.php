<?php

require('HTTP/Request.php');
require('Services/JSON.php');

function getPeople($url,$username,$password) {
  $json = new Services_JSON();
  $request =& new HTTP_Request($url);
  $request->setBasicAuth($username, $password);
  if (!PEAR::isError($request->sendRequest())) {
    $response = $request->getResponseBody();
    $people = $json->decode($response);
    return $people;
  } else {
    return 0;
  }
}

$username = 'kmullins';
$password = 'tompetty';

$friends = array();
$followers = array();

$friends_response = getPeople('http://twitter.com/statuses/friends.json',$username,$password);
if ($friends_response) {
  foreach ($friends_response as $friend) {
    $friends[$friend->screen_name] = array($friend->name, $friend->url);
  }
}

$followers_response = getPeople('http://twitter.com/statuses/followers.json',$username,$password);
if ($followers_response) {
  foreach ($followers_response as $follower) {
    $followers[$follower->screen_name] = array($follower->name, $follower->url);
  }
}

$only_followers = array_diff_key($followers,$friends);

if (count($only_followers) != 0) {
  echo '<ul>';
  foreach ($only_followers as $name => $details) {
    if ($details[1]) {
      echo '<li><a href="http://twitter.com/' . $name . '">' . $details[0] .
      '</a> - <a href="' . $details[1] .
      '">' . $details[1] . '</a></li>';
    } else {
      echo '<li><a href="http://twitter.com/' . $name .
      '">' . $details[0] . '</a></li>';
    }
  }
  echo '</ul>';
} else {
  echo '<p>no followers who are not already friends!</p>';
}

?>