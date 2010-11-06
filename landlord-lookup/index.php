<html>
<head>
<title>
form
</title>
</head>
<body>
<form action="handler.php">
	Street Number: <input type='text' name='number'/><br/>
	Street: <input type='text' name='street'/><br/>
	Borough: <select name="boro">
		<option value="1">Manhattan</option>
		<option value="2">Bronx</option>
		<option value="3">Brooklyn</option>
		<option value="4">Queens</option>
		<option value="5">Staten Island</option>
	</select><br/>
	<input type='submit' value='submit' />
</form>
</body>
</html>