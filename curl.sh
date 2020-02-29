$ch = curl_init(&quot;http://techmgr.net/&quot;);
$html = curl_exec($ch);
echo $html;
