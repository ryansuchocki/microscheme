<?php
header('Content-type: application/json');

$json_url = 'http://api.steampowered.com/IPlayerService/GetRecentlyPlayedGames/v0001/?key=7E520D8ECEBA43FFBE4EF0742324C56C&steamid=76561197989546737&format=json';
  $curl_handle=curl_init();
  curl_setopt($curl_handle,CURLOPT_URL,$json_url);
  curl_setopt($curl_handle,CURLOPT_CONNECTTIMEOUT,2);
  curl_setopt($curl_handle,CURLOPT_RETURNTRANSFER,1);
  $buffer = curl_exec($curl_handle);
  curl_close($curl_handle);
  if (empty($buffer)){
      print "{}";
  }
  else{
      print $buffer;
  }
?>