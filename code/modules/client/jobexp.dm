/*
			J.				E.				X.				P.

	This is a new system which is being put into place to ensure only well-suited people are able to have the ability to play head roles, which objective was originally to replace the way the age system works.
	The creator of this system is Super3222, and idea brought up by them.

	The age system had some easy exploits like this:
			* log in one afternoon
			* play assistant
			* log off, don't play SS13 or whatever you wanna do for a month
			* play as captain or any other head role and not know anything.

	The way it works:
	- In preferences DM, it does a check to see whether the client can have a certain role
	- These roles are usually:
			* Head Roles: HoP, CMO, RD, CE, and HoS
			* Warden and the Security Officer

	- The check works by looking inside of the database at an SQL table, and extracting the data of what is believed to be the amount of times a person has played a role
	- If that role meets up to the specific expectations, then it'll pass. Otherwise, it will fail and that job will not be avaliable to them.

	- Sometimes, the client can be exempted from a certain job. If their name is found on one of the "exemption" lists.
	- There is an exemption list for each of the roles written above.
	- There is also an "exempt all" list which is preferablly for testing only.

	After a round ends, data is gained from the client. It will only work if they aren't dead, ghosted, or commit suicide.
	That data is then sent to the database, to be stored for later use.
	gain_jexp() is called in /datum/game_mode/declare_completion() inside of game_mode.dm

	JEXP is not a datum, period.
	It relies on config files to gauage how much a 'new player' needs to play.
	Usually small values but eh, whatever.




*/

var/global/list/jexpjobs = list ("Warden", "Security Officer", "Security Deputy", "Scientist", "Roboticist", "Cargo Technician", "Quartermaster", "Medical Doctor", "Chemist", "Geneticist", "Station Engineer", "Atmospheric Technician")

/client/proc/gain_jexp(mob/M)
	if(!dbcon.IsConnected())
		return

	var/assigned_job = M.job

	if(!assigned_job)
		return

	if(!jexpjobs.Find(assigned_job))
		return

	var/DBQuery/query_jexp = dbcon.NewQuery("SELECT `count` FROM [format_table_name("jexp")] WHERE `job` = '[assigned_job]' AND `ckey` = '[sanitizeSQL(get_ckey(M))]'")

	if(!query_jexp.Execute())
		var/DBQuery/jexp_insert = dbcon.NewQuery("INSERT INTO `[format_table_name("jexp")]` (`ckey`, `job`) VALUES ('[get_ckey(M)]', '[assigned_job]') ON DUPLICATE KEY IGNORE")
		jexp_insert.Execute()
		gain_jexp(M)
		return


	var/newcount

	while(query_jexp.NextRow())
		newcount = text2num(query_jexp.item[1])

	if(M)
		if(!M.key || !M.client || (M.client.is_afk(INACTIVITY_KICK)))
			return

	newcount++
	var/DBQuery/query = dbcon.NewQuery("UPDATE [format_table_name("jexp")] SET `count` = [newcount] WHERE `ckey` = '[get_ckey(M)]' AND `job` = '[assigned_job]'")
	if(!query.Execute())
		return


/proc/load_jexp_values(only_one, client/CO)

	if(!dbcon.IsConnected())
		return

	var/list/used_clients = list ()

	if(only_one)
		if(CO)
			used_clients += CO

	else
		for(var/client/client in clients)
			used_clients += client



	for(var/client/C in used_clients)
		var/ckeygained = sanitizeSQL(get_ckey(C))

		for(var/t in jexpjobs)
			var/DBQuery/jexp_insert = dbcon.NewQuery("INSERT INTO [format_table_name("jexp")] (ckey, job) VALUES ('[ckeygained]', '[t]') ON DUPLICATE KEY IGNORE")
			jexp_insert.Execute()

			var/DBQuery/query_jexp = dbcon.NewQuery("SELECT `count` FROM [format_table_name("jexp")] WHERE `ckey` = '[ckeygained]' AND `job` = '[t]'")
			query_jexp.Execute()

			var/counts
			while(query_jexp.NextRow())
				counts = text2num(query_jexp.item[1])
			C.cachedjexp["[t]"] = counts

///////////////////////////
/// 	CLIENT VERBS    ///
//////////////////////////

/client/verb/jexpstats()
	set name = "Job Stats"
	set category = "OOC"
	set desc = "Shows how much progress you have made with obtainable ranks."


	src << "<span class='italics'>When the amount of times you've played a certain job is over it's cap, it means that you are able to unlock more jobs within that division.</span>"
	src << "<span class='italics'>Remember that blank values mean they are either not cached or equal 0.</span>"
	my_jexpstats()
	var/notification = input(src, "Department", "Department") as null|anything in list("Security", "Science", "Engineering", "Supply", "Medical")
	if(!notification)
		return

	switch(notification)
		if("Security")
			src << "<span class='italics'>You have played as a Warden [cachedjexp["Warden"]]/[config.jexpvalues["hos_one"]] times, and as a Security Officer [cachedjexp["Security Officer"]]/[config.jexpvalues["warden"]] times to participate as a Warden.</span>"
			src << "<span class='italics'>You have played as a Security Deputy [cachedjexp["Security Deputy"]]/[config.jexpvalues["officer"]] times. If this is completed, you could potentially start a shift as a full fledged officer.</span>"
		if("Science")
			src << "<span class='italics'>You have played as a Roboticist [cachedjexp["Roboticist"]]/[config.jexpvalues["science"]] times and as a Scientist [cachedjexp["Scientist"]]/[config.jexpvalues["science"]] times.</span>"
		if("Engineering")
			src << "<span class='italics'>You have played as a Station Engineer [cachedjexp["Station Engineer"]]/[config.jexpvalues["engineering"]] times and as a Atmopsheric Technician [cachedjexp["Atmospheric Technician"]]/[config.jexpvalues["engineering"]] times."
		if("Medical")
			src << "<span class='italics'>You have played as a Medical Doctor [cachedjexp["Medical Doctor"]]/[config.jexpvalues["medical"]] times, as a Chemist [cachedjexp["Chemist"]]/[config.jexpvalues["medical"]] times, and as a Genticist [cachedjexp["Geneticist"]]/[config.jexpvalues["medical"]] times.</span>"
		if("Supply")
			src << "<span class='italics'>You have played as a Quartermaster [cachedjexp["Quartermaster"]]/[config.jexpvalues["cargo"]] times and as a Cargo Technician [cachedjexp["Cargo Technician"]]/[config.jexpvalues["cargo"]] times."



/client/verb/my_jexpstats()
	set name = "Reload JobStats"
	set category = "OOC"
	set desc = "This will update your jexp cache, allowing you to see your job stats. Automatically happens when you log in, remember."


	load_jexp_values(only_one = TRUE, src)
	src << "<span class=boldnotice'>Your JEXP stats have been successfully reloaded.</span>"