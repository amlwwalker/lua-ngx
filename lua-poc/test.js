//Stub is not necessary because all code that launches/uses the Signal Manager is in this script file
//Also use of $ character is not easily escapable in a nginx.conf file so I dropped it for now in the sub_filter
//that appends the JS tag and this test.js tag

const signalManager = window.$$$.start({si: 'Test Site'});

window.addEventListener('DOMContentLoaded', () => {

//definition of handler that is called whenever we decide to collect signal
//defined as a handler instead of a function because you might tie to a global event (e.g. window.click)
//or you might just call directly on some repititous setTimeout()

const collectSignalHandler = event => {
    //later you'll see how OZ values are cut down to fit as chunks in cookies
    //reason being that cookies get automatically appended to HTTP Requests of a
    //number of types.
    //
    //Any time we say get new signal, I wipe the old signal. Important to do because the old signal
    //might have been longer than the new signal and hence carry chunks that have nothing to do with the
    //new signal values
    clearOldCookies();
    // Call report to get a promise that resolves into signals which we then pass to the function that appends them as cookies.
    signalManager.report({eventType: '10'}).then(function(signalValues) {
		attachSignal(signalValues);
    }).catch(error => {
      // Promise returned by `report` failed and propagated error here.      
      alert(error);      
    });
  };

    //This is an example of signal that updates itself anytime any click occurs on the page,
    //no matter on what object (i.e. Global Event Hooking). I don't know enough about what our
    //signal collects and how it is then interpreted when it arrives in our detection engine to
    //know how we would react to a click handler that occured and can't be traced back to a specific
    //element within rendered Page DOM or how a delay between the last time a click occured and
    //whatever event delivered the signal would impact our detection approach, but I can say that
    //in my tests it appeared to not negatively impact our current approach to detection.
    window.addEventListener('click', collectSignalHandler);
    //This is an example of causing signal to append itself at some pre-defined time after the page loads
    //in this case 2 seconds. We could also make a function that repeats itself where basically once
    //kicked off, on some interval the collection refreshed. I did note that executing generation of new
    //signal did appear to generate some network traffic, so I understand the impact could be meaningful
    //as it relates to supporting infrastructure, and would need to be considered thoughfully, but this
    //is clear evidence that it could be done, 1 time for a page, X times everytime a user does some
    //specific event type, or X times per X seconds / minutes. It might even be designed to adjust
    //the pace at which it refreshes signal dynamically as the code executes and identifies reasons to
    //do so
    setTimeout(function() { collectSignalHandler(); }, 2000);
});

//this is a simple function that looks for cookie values already set and then wipes them.
//in JS the easiest way to do this is to set their values to nothing and set their expiration
//to a negative number. The reason there are while loops is because of the signal chunking
//I want to go through the cookies until I find a place where there are no longer any chunks
//Code could potentially be enhanced because in this prototype, if you happened to stop execution
//mid cookie clearing, you might have some orphaned cookie values above the last one on file
//better approach might be to use a RegEx in the while loop that returned true if it matches
//then delete the match in the while loop.
function clearOldCookies() {
	var counter = 1;
	//wipe OZ_DT cookie values (no underscore because I am not sure underscores can be used in cookie names)
	while(document.cookie.indexOf('OZDT'+counter+'=') > -1)
	{
		createCookie('OZDT'+counter,"",-1);
		counter+=1;
	}
	//wipe OZ_SG cookie values
	counter = 1;
        while(document.cookie.indexOf('OZSG'+counter+'=') > -1)
        {
                createCookie('OZSG'+counter,"",-1);
                counter+=1;
        }
	//wipe OZ_TC cookie values
	counter = 1;
        while(document.cookie.indexOf('OZTC'+counter+'=') > -1)
        {
                createCookie('OZTC'+counter,"",-1);
                counter+=1;
        }

}

//This is the success handler that executes when report returns signal.
//It is designed to take the passed signal values, encode them so they don't break characters
//allowed in a cookie and break them up into strings of 3000 characters and append them itterating
//on the number after the signal label (i.e. OZDT,OZTC,OZSG - OZDT1, OZDT2, OZDT3)
function attachSignal(signalVal) {
        const json = Object.assign(signalVal);

	//URL Encode (First) - Chunk (Second) - reason being that encoding might convert a single character into
	//2 or 3 characters thus causing it to go above the chunk size
	const ozdtChunks = chunkSubstr(encodeURIComponent(json.OZ_DT),3000);
	const oztcChunks = chunkSubstr(encodeURIComponent(json.OZ_TC),3000);
        const ozsgChunks = chunkSubstr(encodeURIComponent(json.OZ_SG),3000);

	//go through the chunk arrays, and create cookies
	//for testing sake the last paramater (i.e. 1) is the cookie expiration date.
	//which you can see in the cookie generation is multiplied by a few numbers to generate
	//a milisecond timestamp since Unix Epoch
	for(i=0;i<ozdtChunks.length;i++)
	    createCookie("OZDT"+(i+1).toString(),ozdtChunks[i],1);
	for(i=0;i<oztcChunks.length;i++)
            createCookie("OZTC"+(i+1).toString(),oztcChunks[i],1);
	for(i=0;i<ozsgChunks.length;i++)
            createCookie("OZSG"+(i+1).toString(),ozsgChunks[i],1);
	//I decided to use the same script includes on my gate page which is redirected to when the server
	//sees a request that doesn't have signal. Since above we execute signal collection this code block
	//is only reached when the page has successfully executed signal collection and appended the cookies
	//at that point, I'm doing a page reload. I've delayed it by 5 seconds here, but that's entirely for
	//demonstration purposes. If we reach this point in the code, we know that we successfully got signal
	//and appended the signal as cookies so we could just immediately reload. I define the gate variable in
	//a seperate little script block that is appended above the load of this script, so the code is a little
	//so if it doesn't exist, we know we aren't on the gate/waiting room page.
	if (typeof(gate) !== 'undefined')
	{
		setTimeout(function() { location.reload(); },5000);
	}
}

//This function takes a string and breaks it down in an array of chunks that map to the second parameter it is passed
function chunkSubstr(str, size) {
  const numChunks = Math.ceil(str.length / size)
  const chunks = new Array(numChunks)

  for (let i = 0, o = 0; i < numChunks; ++i, o += size) {
    chunks[i] = str.substr(o, size)
  }

  return chunks
}

//This is the function that is called to basically erase a cookie by setting a cookie with the same name to nothing
//with an expiration of a negative number
function eraseCookie(name) {
 createCookie(name,"",-1);
}

//This function creates a cooke with a specified name, value and expiration measured in days. 
function createCookie(name,value,days) {
 if (days) {
  var date = new Date();
  //Calculate miliseconds since Unix Epoch for specified number of seconds
  date.setTime(date.getTime()+(days*24*60*60*1000));
  var expires = "; expires="+date.toGMTString();
 } else {
  var expires = "";
 }
 document.cookie = name+"="+value+expires+"; path=/";
}
