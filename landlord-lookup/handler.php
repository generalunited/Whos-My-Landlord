<?php 
/************
* @author Paul Tepper <paul.tepper@gmail.com>
*
************/

include('simple_html_dom.php');

if($_GET['fromwiki']=='true'){
	$street = str_replace('_',' ',$_GET['address']);
	$sp = explode(' ',$street);
	$no = $sp[0];
	$street = implode(' ',array_slice($sp,1));
	
	$boros = array(
		'Manhattan' => 1,
		'Bronx' => 2,
		'Brooklyn' => 3,
		'Queens' => 4,
		'Staten Island' => 5
	);
	$boro = $boros[$_GET['boro']];
}
else{
	$no =  $_GET['number'];
	$street = $_GET['street'];
	$boro =  $_GET['boro'];
}

$street = urlencode($street);

$url1 = "http://a810-bisweb.nyc.gov/bisweb/PropertyProfileOverviewServlet?boro=$boro&houseno=$no&street=$street&go2=+GO+&requestid=0";

$html = file_get_html($url1);

$table = $html->find('table',3);
$block = substr($table->find('tr',1)->children(9)->innertext,2);
$lot = substr($table->find('tr',2)->children(8)->innertext,2);

$bl = "http://api.blocksandlots.com/blankslate/json/data/743cd788-eb98-4fb6-af18-0811261ad168/records/search?apikey=cvq842zthjdvr25cq9p5s6db&Block=$block&Lot=$lot&rp=350&em=true&_=1289069608577";

//echo $bl;
/*echo $url1;*/

$json = file_get_html($bl);

$jsarray = json_decode($json);
//print_r($jsarray);
//echo '<br><br>';
$owner =  $jsarray->application[0]->entity[0]->record[0]->field[5]->fieldValue;


$ch = curl_init("http://appext9.dos.state.ny.us/corp_public/CORPSEARCH.SELECT_ENTITY");

curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch,CURLOPT_POST,true);
curl_setopt($ch,CURLOPT_POSTFIELDS,array(
	'p_entity_name' => $owner,
	'p_name_type' =>'A',
	'p_search_type' => 'BEGINS'));
$str =  curl_exec($ch);
curl_close($ch);

$html = str_get_html($str); 
$link = $html->find('a[title]',0);

$ch = curl_init('http://appext9.dos.state.ny.us/corp_public/'.$link->href);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$str = curl_exec($ch);
curl_close($ch);

$content = "<table id='table'>
<tr><td>Block:</td><td>$block</td></tr>
<tr class='alt'><td>Lot:</td><td>$lot</td></tr>
<tr><td>Owner:</td><td>$owner</td></tr>
";

if($str!=''){
	$html = str_get_html($str); 
	$addr = $html->find('table[id=tblAddr]',0)->find('tr',1)->children(0)->innertext;

	$content.= "<tr class='alt'>
		<td class='label'>NYS Department of State<br/> 
		Divsion of Corporations<br/> 
		Search Results:</td>
		<td>$addr</td>
	</tr>
	";
}
$content.= "
</table>
";

?>
<html>
	<head>
		<title>Landlord Lookup Results</title>
		<link rel="stylesheet" type="text/css" href="style.css" />
	</head>
	<body>
<h1>Landlord Lookup</h1>
<?php echo $content; ?>
	</body>	
</html
