import classes.Util.InCollection;

/*
Flags Key:

PIPPA_RECRUITED : Tracks whether Pippa has been made a crew member
	0/undefined - Pippa has not asked to be made a crew member
	-1 - Pippa has asked to join Steele's crew, but was turned down
	1 - Pippa is part of Steele's crew, and on the ship
	2 - Pippa joined the crew, but was kicked off
PIPPA_RECRUIT_TIMER - Timer for Pippa's email about joining crew
	undefined/0 - Haven't met requirements for her to ask to join crew
	- Set to game time once enough requirements are met
PIPPA_YAMMI_KITCHEN - Checks if Pippa and Yammi are in the kitchen chatting (random chance) and available for a threesome
	undefined/0 - They aren't
	1 - They are
PIPPA_YAMMI_THREESOME - Tracks how many times Steele has had a threesome with Pippa and Yammi
	undefined/0 - Steele has not had a threesome with Pippa and Yammi
*/
	
// Represent reasons for Pippa to request to join crew
public const PIPPA_RECRUIT_YAMMI:int = 0; // Having Yammi on board as your chef, and Pippa knowing about it
public const PIPPA_RECRUIT_REAHA:int = 1; // Having treated Reaha on board as your chef and Pippa knowing about it
public const PIPPA_RECRUIT_TREATED:int = 2; // Being treated
public const PIPPA_RECRUIT_AFFECTION:int = 3; // Having a high affection score with Pippa

public function getPippaRecruitmentReasons():Array
{
	var recruitmentReasons:Array = new Array();
	
	// Must meet a certain affection threshold and have talked to her about money for other reasons to even come into play
	if (pippaAffection() >= PIPPA_AFFECTION_NAME && flags["PIPPA_TALKED_MONEY"] == 1)
	{
		if (flags["PIPPA_TALKED_YAMMI"] == 1) recruitmentReasons.push(PIPPA_RECRUIT_YAMMI);
		if (flags["PIPPA_TALKED_REAHA"] == 1) recruitmentReasons.push(PIPPA_RECRUIT_REAHA);
		if (pc.isTreated()) recruitmentReasons.push(PIPPA_RECRUIT_TREATED);
		if (pippaAffection() >= PIPPA_AFFECTION_CREW) recruitmentReasons.push(PIPPA_RECRUIT_AFFECTION);
	}
	
	return recruitmentReasons;
}

public function pippaCheckRecruitment():void
{
	if (flags["PIPPA_RECRUIT_TIMER"] == undefined && getPippaRecruitmentReasons().length >= 2) flags["PIPPA_RECRUIT_TIMER"] = GetGameTimestamp();
}

public function pippaCrewEmailGet():void
{
	AddLogEvent("<b>New Email From Pippa (pippa_pig@cmail.com)!</b>", "passive");

	MailManager.unlockEntry("pippa_crew", GetGameTimestamp());
}

public function pippaTalkInitialRecruit():void
{
	clearOutput();
	clearMenu();
	showPippa();
	
	output("<i>“I'm glad you stopped by to talk, " + pippaCallsSteele() + ".”</i>  Pippa looks a bit nervous.  <i>“I guess I'll get straight to the point.  I've been thinking about some of the things we've talked about: seeing new places, unique opportunities, and...cutting my parents off.  I want to earn my keep as part of your crew.  Working for you would be worth not working for myself.");
	
	var recruitmentReasons:Array = getPippaRecruitmentReasons();
	
	if (InCollection(PIPPA_RECRUIT_YAMMI, recruitmentReasons)) output("  It sounds like you've got quite a chef on board.");
	
	if (InCollection(PIPPA_RECRUIT_REAHA, recruitmentReasons) && InCollection(PIPPA_RECRUIT_TREATED, recruitmentReasons)) output("  Between you and the cow girl you mentioned, I won't miss New Texas at all.");
	//else if (InCollection(PIPPA_RECRUIT_REAHA, recruitmentReasons)) // Reaha stuff in here when she can be treated
	else if (InCollection(PIPPA_RECRUIT_TREATED, recruitmentReasons)) output("  I don't have to wait for you to visit before I can fuck a Treated " + pc.mf("bull", "cow") + ".");
	
	output("  And, of course, I like you.");
	
	if (InCollection(PIPPA_RECRUIT_AFFECTION, recruitmentReasons)) output("..a lot.");
	
	output("  I hope you don't need much convincing, but if you'll have me, I'll provide my services to the rest of the crew.  Keep them relaxed and happy.  Like I've mentioned, free massages are a great employee benefit.  So?”</i>  She looks more nervous than when she started.");
	
	processTime(2);
	
	addButton(0, "Accept", pippaTalkInitialRecruitAccept, undefined);
	addButton(1, "Decline", pippaTalkInitialRecruitDecline, undefined);
}

public function pippaTalkInitialRecruitAccept():void
{
	clearOutput();
	clearMenu();
	showPippa();
	
	flags["PIPPA_RECRUITED"] = 1;
	
	output("You accept Pippa's request to join your crew, and she breathes a sigh of relief.  <i>“I was pretty sure you'd accept, but I couldn't help but be nervous.  Thank you, " + pippaCallsSteele() + ".  This is going to be a great thing.”</i>  She closes the gap between the two of you and plants a kiss right on your lips.  <i>“I need to pack up a few things.  I'll meet you on board, Captain.”</i>");
	
	processTime(1);
	
	addButton(0, "Next", move, rooms[currentLocation].eastExit);
}

public function pippaTalkInitialRecruitDecline():void
{
	clearOutput();
	clearMenu();
	showPippa();
	
	flags["PIPPA_RECRUITED"] = -1;
	
	output("You decline Pippa's request to join your crew, and her nervousness is replaced with a surprised sadness.  <i>“I...really thought you'd accept.  I'm sure you have your reasons, " + pippaCallsSteele() + ", but I hope you'll reconsider.  My offer is still open if you do, but for now, can you leave me alone?”</i>");
	
	processTime(1);
	
	addButton(0, "Next", move, rooms[currentLocation].eastExit);
}

public function pippaTalkRecruit():void
{
	clearOutput();
	clearMenu();
	showPippa();
	
	flags["PIPPA_RECRUITED"] = 1;
	
	output("You inform Pippa that you've changed your mind about her joining your crew, and her face lights up.  <i>“I'm so glad you changed your mind, " + pippaCallsSteele() + "!  I promise you're making the right choice; this is going to be a great thing.”</i>  She closes the gap between the two of you and plants a kiss right on your lips.  <i>“I need to pack up a few things.  I'll meet you on board, Captain.”</i>");
	
	processTime(1);
	
	addButton(0, "Next", move, rooms[currentLocation].eastExit);
}

public function pippaAskToLeave():void
{
	clearOutput();
	clearMenu();
	showPippa();
	
	output("<i>“Pippa, do you still own your house on Uveto?”</i>");
	
	output("\n\n<i>“Yeah, it's still mine....Why?”</i>  She narrows her eyes at you.");
	
	output("\n\n<i>“I'm gonna need you off the ship for a while.”</i>");
	
	output("\n\nShe places her hands on her hips.  <i>“That so?”</i>  She closes the gap between the two of you lightly places her hand on your face.  <i>“Every adventurer could use someone to help work out any kinks.”</i>  She enunciates the end of her sentence.");
	
	output("\n\nAre you sure you want to get rid of Pippa?");
	
	processTime(1);
	
	addButton(0, "Yes", pippaAskToLeaveYes);
	addButton(1, "No", pippaAskToLeaveNo);
}

public function pippaAskToLeaveYes():void
{
	clearOutput();
	clearMenu();
	showPippa();
	
	output("You remove Pippa's hand from your face.  <i>“Just for a while, ok?”</i>");
	
	output("\n\nShe sighs.  <i>“Alright, fine.  Just don't leave me waiting around too long.”</i>  She kisses you on the cheek and goes to gather her things.");
	
	output("\n\n<b>Pippa is no longer on your crew.  She can be found at her house on Uveto.</b>");
	
	processTime(1);
	flags["PIPPA_RECRUITED"] = 2;
	
	addButton(0, "Next", mainGameMenu);
}

public function pippaAskToLeaveNo():void
{
	clearOutput();
	clearMenu();
	showPippa();
	
	output("You place your hand over the one she has on your face.  <i>“Alright, fine.  You can stay for now.  I'll let you know if I need you to leave after all.”</i>");
	
	output("\n\n<i>“Let's hope it doesn't come to that.”</i>  She plants a light kiss on your mouth and walks off.");
	
	processTime(1);
	
	addButton(0, "Next", mainGameMenu);
}

public function pippaTalkTakeBack():void
{
	clearOutput();
	clearMenu();
	showPippa();
	
	flags["PIPPA_RECRUITED"] = 1;
	
	output("You tell Pippa that you'd like to bring her back on board and she smiles at you reluctantly.  <i>“I'd prefer that you hadn't left me back here in the first place, but I'll be happy to be back on the ship.  I'll see you on board.”</i>");
	
	processTime(1);
	
	addButton(0, "Next", move, rooms[currentLocation].eastExit);
}

public function pippaShipBonusText():String
{
	var bonusText:String;
	
	if (rand(3) == 0) bonusText = "Pippa is sitting in the kitchen eating.  She looks quite content with Yammi's cooking.";
	else if (rand(4) == 0)
	{
		if (rand(2) == 0) bonusText = "Pippa is relaxing in the common area " + RandomInCollection("exercising her fingers", "reading a book", "massaging her hands");
		else bonusText = "Pippa, who appears to have just gotten out of the shower, is just relaxing in the common area.";
	}
	else bonusText = "Pippa is in her quarters doing yoga.  When she notices your eyes on her, she goes into a downward dog position and wiggles her ass at you.";
	
	return bonusText;
}