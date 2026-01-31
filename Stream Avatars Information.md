# \# API Reference & Tips

\# API Reference & Tips

Press F5 to reload and replay scripts while Stream Avatars is connected\!  
To view the console log, focus Stream Avatars, and press Alt+C, then type: Lua\\  
After hitting enter, a console logger will come up showing you the logs.\\  
Once it is open, you can close the command input by pressing Alt+C again.

You can close the console log by repeating this process.

\#\# Do's and Don'ts

{% tab title="Function Order" %}

\`\`\`lua  
function anotherFunction()  
    \--see how this function is above the return function()?  
      
    \--the double dash is how we make line comments in lua scripting  
      
    \--\[\[  
        this is how we make block comments in lua scripting.  
        multiple lines. woooo  
    \]\]  
      
    log('hello world');  
end

return function()  
    anotherFunction();  
    \--this should be the last function of your script\!   
end \--Don't put anything below the last end  
\`\`\`

{% endtab %}

{% tab title="If Then Else" %}

\`\`\`lua  
return function()  
    local test \= 'hi';  
    local test2 \= false;  
      
    if test2 \== false and test \== 'hi' then  
        log('&& operators is just and');  
    else if test2 \== true or test \== 'bye' then  
        log('|| operators is just or');  
    end  
      
    if test2 \== false then  
        log('simple if');  
    end  
      
    if test2 \== false then  
        log('simple if else');  
    else  
        log('blah');  
    end  
end  
\`\`\`

{% endtab %}

{% tab title="Arrays and Loops" %}

\`\`\`lua  
return function()  
    \--in lua, all arrays start at index 1  
    local test {'one', 'two', 'three' };  
    log(test\[1\]); \--this will print out one  
      
    \--notice \#test is how we get the length of the array. which is 3\.  
    \--a simple for loop  
    for i \= 1, \#test do   
        log(i); \--this will print out: 1, 2, 3  
    end  
      
    \--a simple while loop  
    local test \= 0;  
    while test \< 5 do  
        test \= test \+ 1;  
    end  
      
    local a \= { }  
    a\[1\] \= 'one';  
    a\[2\] \= 'two';  
    a\['hello'\] \= 'hello world';  
      
      
    \--ipairs is indexed \--note hello world does not get printed  
    for key, value in ipairs(a) do  
        log(key .. value);  
    end  
    \--1one  
    \--2two  
     
      
     \--pairs key order is unspecified and not garunteed.  
    for key, value in pairs(a) do  
        log(key .. value);  
    end  
    \--1one  
    \--hello world  
    \--2two  
end  
\`\`\`

{% endtab %}

{% tab title="String Concatenation" %}

\`\`\`lua  
return function()  
    \--how to concatenate strings in lua.   
    \--(two periods is how you add strings together)  
    log('this is how ' .. 'you combine strings');  
end  
\`\`\`

{% endtab %}

{% tab title="Coroutines" %}  
coroutines are unique in SA Lua. They allow for scripts to wait for something to finish before continuing. Do not cross global variables between coroutines\! \\  
\\  
This can be tricky to use but is very powerful for scripting sequences of events.

\`\`\`lua  
function exampleCoroutine()  
    \--code in this function does not have access to global scope variables  
    \--Do not reference myGlobalScopeVariable directly\!  
      
     
    local myVar \= get('myGlobalScopeVariable');   
     \--grab the global var and make it local  
    log(myVar); \--prints hi  
      
    myVar \= 'bye';  
      
    \--set the global var to the local variable.  
    set('myGlobalScopeVariable', myVar);  
end

\--this variable belongs to the main coroutine and nowhere else\!  
myGlobalScopeVariable \= 'hi';   
return function()  
    wait(1);   
    \--a really basic coroutine yield   
    \--that waits 1 second before continuing.  
      
    local coroutineId \= async('exampleCoroutine');  
    waitForAsync(coroutineId);  
      
    log(myGlobalScopeVariable);   
    \--this prints bye because we waited for it to be set.  
      
    keepAlive();   
    \--Pauses this coroutine indefinitely, allowing the other coroutines to exist.  
end  
\`\`\`

{% endtab %}  
{% endtabs %}

\#\# Pre-existing Functions and Data \<a href="\#pre-data" id="pre-data"\>\</a\>

With LUA scripting in stream avatars, there are some addons your your script behind the scenes that you should know about\!

{% tabs %}  
{% tab title="JSON Serialization" %}

\`\`\`lua  
return function()  
    local a \= { someData \= 'hi', otherData \= { 1, 2, 3 }};  
    \--some data table...  
      
    local makeItString \= json.serialize(a);  
    \--convert a to a JSON string  
      
    log(makeItString);  
    \--prints the data structure.  
      
    local b \= json.parse(makeItString);  
    \--parse the string back into a table  
      
    log(b\['someData'\]); \--prints hi  
      
      
    \--DO NOT TRY TO SERIALIZE NON-ARRAYS ALONG SIDE OF ARRAYS\!  
    local h \= { };  
    h\[1\] \= 'hey'; \--h is array  
    h\[2\] \= 'dont'; \--h is array  
    h\['example'\] \= 'do'; \--h is not array  
    h\['example2'\] \= 'this'; \--h is not array  
    local j \= json.serialize(h); \--stop\! this breaks.  
      
    \--instead option 1:  
    local k \= { };  
    k\[1\] \= 'hey'; \--k is array  
    k\[2\] \= 'DO'; \--k is array  
    k\[3\] \= { }; \--k is array  
    k\[3\]\['example'\] \= 'do'; \--k is array  
    k\[3\]\['example2'\] \= 'this'; \--k is array  
    local l \= json.serialize(k); \--works  
      
    \--instead option 2:  
    local m \= { };  
    m\['n'\] \= { };  
      
    m\['n'\]\[1\] \= 'hey';  \--m is not array  
    m\['n'\]\[2\] \= 'DO';  \--m is not array  
    m\['example'\] \= 'do'; \--m is not array  
    m\['example2'\] \= 'this'; \--m is not array  
    local o \= json.serialize(m); \--works  
      
      
      
end  
\`\`\`

{% endtab %}

{% tab title="On Command Call" %}  
{% hint style="warning" %}  
Only exists when the custom command is set to Run As: On Command Call

commandUser is the user that issued the command causing this script to run.

commandMessage is the message that was sent to issue the command.  
{% endhint %}

\`\`\`lua  
return function()  
    \--this script is ran by someone running the command...  
    log(commandUser.displayName);  
    log(commandMessage); \--prints the full message of the command  
    \--if the custom command is set to "exact match \= false",   
    \--the commandMessage could be more than just the commandName  
      
    \--example:  
    \--commandMessage could be: \!steal clonzeh  
    \--where the command is actually \!steal  
    \--but since it doesn't have to match exactly, users can add info after it  
end  
\`\`\`

{% content-ref url="api-reference-and-tips/classes/user" %}  
\[user\](https://docs.streamavatars.com/lua-scripting-api/api-reference-and-tips/classes/user)  
{% endcontent-ref %}

\<figure\>\<img src="https://2994430787-files.gitbook.io/\~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FYvA0UlM6GCcOd8hKhafT%2Fuploads%2FaoKljx8yyjYjSvRSh3Gn%2FiklxSWoOCG.png?alt=media&\#x26;token=1f7cad66-b1c6-4859-ae1f-55879136b94e" alt=""\>\<figcaption\>\<p\>example \!steal settings\</p\>\</figcaption\>\</figure\>  
{% endtab %}

{% tab title="Trigger Type" %}

\`\`\`lua  
\--Scripts are able to control it's own trigger type with a setting.   
\--(this makes it easier to share commands and keep their settings)

script\_trigger\_type \= 'On Connect';   
\--with this line uncommented, the script will be forced to run as OnConnect

\--with this line uncommented, the script will be forced to run as OnCommand  
\--script\_trigger\_type \= 'On Command';

return function()  
    log('script was triggered\! the trigger type is: ' .. script\_trigger\_type);  
end  
\`\`\`

{% endtab %}  
{% endtabs %}

# \# Global Functions

\# Global Functions

\- \[log\](/lua-scripting-api/api-reference-and-tips/global-functions/log.md): API \- prints a message to console log  
return function()  
    log('hello world');  
end

\- \[wait\](/lua-scripting-api/api-reference-and-tips/global-functions/wait.md): API \- pauses the script for x amount of seconds. (essentially a timer)  
return function()  
    wait(3.5); \--3.5 seconds.  
    log('hello world');  
end

\- \[yield\](/lua-scripting-api/api-reference-and-tips/global-functions/yield.md): API \- pauses the script for x amount of seconds.  
return function  
    local timeCounter \= 0;  
    local x \= 0;  
    local speed \= 5;  
      
    wait(3.5); \--pauses script 3.5 seconds before continuing...  
      
    while timeCounter \< 5 do \--after 5 seconds this while loop will end  
      
        local delta \= yield();  \--useful for doing work over a period of time  
          
        \--yield returns the time it took from last frame to this frame in seconds.  
        \--yield also pauses the script each frame so the while loop doesn't lock the application up  
        \--while doing work.  
          
        timeCounter \= timeCounter \+ delta;  
          
        \--you can also use the deltaTime to advance the position of something  
        x \= x \+ speed \* delta; \--at a rate of 5units per second, x moves right.  
    end  
end

\- \[yieldBreak\](/lua-scripting-api/api-reference-and-tips/global-functions/yieldbreak.md): API \- pauses the script for x amount of seconds.  
return function  
    local x \= 0;  
    while x \< 5000 do  
      
        yield(); \--yield works in combination with deltaTime  
          
        if x \> 30 then  
            yieldBreak(); \--causes this coroutine to close out immediately  
        end  
          
        \--without yield, the application would freeze & be stuck in a loop.  
        \--until x is equal to 5000  
        x \= x \+ 1;  
    end  
      
    log('this will never be reached.');  
end

\- \[async functions\](/lua-scripting-api/api-reference-and-tips/global-functions/async-functions.md): API \- pauses the script for x amount of seconds.  
function test()   
    wait(3);  
    log('async function completed\!');  
end  
return function()

    for i=0,3,1 do  
        async('test');  
    end  
    log('hello world');  
      
    wait(3.1); \--Wait just long enough for all coroutines to finish  
      
    \--it will print async function completed before finished\!  
    log('finished\!')  
end

\- \[waitForAsync function\](/lua-scripting-api/api-reference-and-tips/global-functions/waitforasync-function.md): API \- pauses the script for x amount of seconds.  
\# waitForAsync function

\`\`\`lua  
function test()   
    wait(3);  
    log('async function completed\!');  
end  
return function()

      
    local coroutineId \= async('test');  
      
    waitForAsync(coroutineId);--pauses script  
      
    \--it will print async function completed before finished\!  
    log('finished\!')  
end  
\`\`\`

\- \[stopAsync function\](/lua-scripting-api/api-reference-and-tips/global-functions/stopasync-function.md): API \- pauses the script for x amount of seconds.  
function test()   
    log('test is starting');  
    wait(3); \--the coroutine will exit before this finishes  
    log('async function completed\!');  
end  
return function()

      
    local coroutineId \= async('test');  
      
    wait(1);  
    \--it will print: test is starting  
    stopAsync(coroutineId);  
    \--it will NOT print async function completed\!  
    log('finished\!')  
end

\- \[get\](/lua-scripting-api/api-reference-and-tips/global-functions/get.md): API \- gets global variables from the main coroutine.  
function test()   
    wait(3);  
    local myValue \= get('testValue'); \--gets the global object/variable testValue from the main script  
    log(myValue);  
end

return function()  
    testValue \= 10;  
    async('test');  
      
    wait(10);  
    \--it will print testValue before finished  
    log('finished');  
end

\- \[set\](/lua-scripting-api/api-reference-and-tips/global-functions/set.md): API \- sets global variables to the main coroutine.  
 function test()   
    wait(3);  
      
    local myValue \= get('testValue'); \--gets the global object/variable testValue from the main script  
      
    log(myValue); \--prints 10

    myValue \= myValue \+ 15; \--adds 15 to the local variable  
      
    set('testValue', myValue) \--sets the main script variable to the local variable here. \*\*25\*\*  
end  
return function()

    testValue \= 10;  
      
    local coroutineId \= async('test');  
      
    waitForCoroutine(coroutineId);  
    \--while waiting the async coroutine is playing it will print  
    \--10  
      
    log(testValue); \--prints 25  
    log('finished');  
end

\- \[applyImage\](/lua-scripting-api/api-reference-and-tips/global-functions/applyimage.md): API \- applies an image or animation to a GameObject.  
return function()  
    wait(2);  
    local app \= getApp();  
    local ob \= app.createGameObject(); \--create object to attach images to  
    applyImage(ob, 'welcomeImage'); \--add the image titled 'welcome' to the object  
    ob.image.anchor('bottom left', true); \--anchors the image to the bottom left... accounting for image dimensions \= true  
    waitForAnimation(ob.image); \--pauses script until finished...  
    wait(2);  
    applyImage(ob, 'byeImage');  
    waitForAnimation(ob.image);  
    log('finished playing two animations\!');  
end  
To create an image for the script to use, go back into Bot Commands \> under advanced select the Images option button, then click "Create New".  
After creating the image, select a .png sprite-sheet to be uploaded. If your image is animated, set the width and height values to be a single frame of the sprite-sheet. (this also works with gifs but it is less optimized.)  
\- \[waitForAnimation\](/lua-scripting-api/api-reference-and-tips/global-functions/waitforanimation.md): API \- pauses script until an image is finished animating  
return function()

    local app \= getApp();  
      
    local ob \= app.createGameObject(); \--create object to attach images to  
      
    \--add the image titled 'welcomeImage' to the object  
    applyImage(ob, 'welcomeImage');   
      
    ob.image.anchor('bottom left', true); \--anchors the image to the bottom left... accounting for image dimensions \= true  
      
    waitForAnimation(ob.image); \--pauses script until finished...  
     
    applyImage(ob, 'byeImage');  
      
    waitForAnimation(ob.image); \--pauses script again until byeImage finished animating  
    log('finished playing two animations\!');  
end

\- \[webrequest get/post\](/lua-scripting-api/api-reference-and-tips/global-functions/webrequest-get-post.md): API  
return function()

(GET)  
    local exampleHeaders \= { myHeader \= 'theHeaderValue' };  
    local dataExample \= "hello this string gets turned into a byte array behind the scenes."  
      
    \-- If we were using headers and body:  
    \-- local response \= getWebRequest("https://type.fit/api/quotes", exampleHeaders, dataExample);  
      
    \-- without headers or body \- set them as nil  
    local response \= getWebRequest("https://type.fit/api/quotes", nil, nil);  
    local jsonObject \= json.parse(response);  
      
    \--this website returns a json blob of quotes and authors. here we are logging the first quote.  
    log(jsonObject\[1\].text);   
end  
(POST)  
return function()  
    local headers \= {};  
    headers\["Content-Type"\] \= "application/json";  
    local body \= '{ "Id": 78912 }';  
    local responseText, responseHeaders \= postWebRequest(  
    'https://reqbin.com/sample/post/json',  
    headers, body);  
      
    \-- log the response as string  
    \--{"success":"true"}  
    log(responseText);  
    local parseJson \= json.parse(responseText);  
    log(parseJson.success);  
    local backToJson \= json.serialize(parseJson);  
    log(backToJson);  
      
      
    \-- uncomment below log all response headers  
    \--\[\[  
    for k, v in pairs(responseHeaders) do  
        log(k .. ': ' .. v);  
    end  
    \]\]  
end

\- \[getUser\](/lua-scripting-api/api-reference-and-tips/global-functions/getuser.md): API \- gets an active User by displayName or ID  
return function()  
    local findUser \= getUser('clonzeh');

    if findUser \~= nil then  
        log('found the user: ' .. findUser.displayName .. '. They are using the avatar: ' .. findUser.avatar);  
    else  
        log('could not find target user');  
    end  
end

\- \[getUsers\](/lua-scripting-api/api-reference-and-tips/global-functions/getusers.md): API \- gets all active users in an array.  
return function()  
    local allActiveUsers \= getUsers();  
    for i,user in pairs(allActiveUsers) do  
        log(user.displayName); \--print all of their display names to console.  
    end  
end

\- \[getUserById\](/lua-scripting-api/api-reference-and-tips/global-functions/getuserbyid.md): API \- gets a User by id  
return function()  
    local findUser \= getUserById('7135267');

    if findUser \~= nil then  
        log('found the user: ' .. findUser.displayName);  
    else  
        log('could not find target user');  
    end  
end

\- \[getCurrency\](/lua-scripting-api/api-reference-and-tips/global-functions/getcurrency.md): API \- gets the target User's currency value  
return function()  
    local findUser \= getUser('clonzeh');  
      
    if findUser \~= nil then  
        local balance \= getCurrency(findUser);  
        log(findUser.displayName .. ' has: ' .. balance);  
    else  
        log('could not find target user');  
    end  
      
end

\- \[addCurrency\](/lua-scripting-api/api-reference-and-tips/global-functions/addcurrency.md): API \- add currency to a target user  
return function()  
    local findUser \= getUser('clonzeh');  
      
    if findUser \~= nil then  
        local amount \= getCurrency(findUser);  
        log(findUser.displayName .. ' has: ' .. amount);  
          
        success, balance \= addCurrency(findUser, 100);   
        log(success .. '\! user currently has ' .. balance);   
    else  
        log('could not find target user');  
    end  
end

\- \[removeCurrency\](/lua-scripting-api/api-reference-and-tips/global-functions/removecurrency.md): API \- remove currency to a target user  
return function()  
    local findUser \= getUser('clonzeh');  
      
    if findUser \~= nil then  
        local balance \= getCurrency(findUser);  
        log(findUser.displayName .. ' has: ' .. amount);  
          
        success, balance \= removeCurrency(commandUser, 100);   
        log(success .. '\! user currently has ' .. balance);   
    else  
        log('could not find target user');  
    end  
end

\- \[adjustCurrency\](/lua-scripting-api/api-reference-and-tips/global-functions/adjustcurrency.md): API \- adjust currency of a target user (sets their currency to specified a amount)  
return function()  
    local findUser \= getUser('clonzeh');  
      
    if findUser \~= nil then  
        local balance \= getCurrency(findUser);  
        log(findUser.displayName .. ' has: ' .. amount);  
          
        success, balance \= adjustCurrency(commandUser, 100);   
        log(success .. '\! user currently has ' .. balance);   
    else  
        log('could not find target user');  
    end  
end

\- \[getBackground\](/lua-scripting-api/api-reference-and-tips/global-functions/getbackground.md): API \- gets the title of the current background level  
return function()  
    local level \= getBackground();  
      
    log('the current background level is: ' .. level);  
end  
\- \[getScriptableBlocks\](/lua-scripting-api/api-reference-and-tips/global-functions/getscriptableblocks.md): API \- gets all of the scriptable blocks on the current background level  
return function()  
    local level \= getBackground();  
       
    \--give an array of all blocks on the current level  
    local scriptBlocks \= getScriptableBlocks();   
      
    log('the list of blocks on ' .. level .. ' are:');  
    for i,block in pairs(scriptBlocks) do  
        log(block.id);  
        log(block.position.x .. ' ' .. block.position.y);  
    end  
end

\- \[getAvatar\](/lua-scripting-api/api-reference-and-tips/global-functions/getavatar.md): API \- gets a specific avatar  
return function()  
    local targetAvatar \= getAvatar('block\_man');  
    if targetAvatar \== nil then  
        log('target avatar could not be found\!')  
    else  
        log (targetAvatar.name);  
        for (i,gear in pairs(targetAvatar.Gear()))  
            log(gear); \--prints the gear sets that are available to the avatar  
        end  
    end  
end

\- \[getAllAvatars\](/lua-scripting-api/api-reference-and-tips/global-functions/getallavatars.md): API \- gets all available avatars  
return function()  
    local allActiveAvatars \= getAllAvatars();  
    for i,avatar in pairs(allActiveAvatars) do  
        log(avatar.name);  
    end  
end

\- \[runCommand\](/lua-scripting-api/api-reference-and-tips/global-functions/runcommand.md): API \- sends a message to the application to run a specific command  
By issuing runCommand, it will send the command as the streamer/broadcaster.  
To send a command as another user, you will need to use the change command:

example: '\!change clonzeh \!jump'

otherwise, you can find a runCommand within the User class.  
In this example, sendQuietly is set to false. (the second paramenter)

This means that command will try not to respond, unless overridden by the command itself.

return function()  
    \--running quietly as true will prevent regular commands from responding in chat.  
    \--however a commany may still output a response  
      
    \--\!mass forces all users to run the command jump   
    \--\*\*assuming nothing else is controlling the state of avatars.  
    \--\*\*assuming everyone has access to the jump command / shop restrictions  
    runCommand('\!mass jump', false);   
      
    \--runCommand('\!change clonzeh \!jump', false);  
    \--\!change will try to run the command as a different user.  
      
    \--runCommand('\!jump', false);   
    \--by just running jump, it will make the broadcaster's avatar jump.  
end

\- \[writeChat\](/lua-scripting-api/api-reference-and-tips/global-functions/writechat.md): API \- sends a message to your live stream chatroom  
return function()  
    writeChat('hello world'); \--prints hello world into your chat\!  
end

\- \[setProperty\](/lua-scripting-api/api-reference-and-tips/global-functions/setproperty.md): API \- this is just a helper function to set a default value, but if a value already exists it will do nothing.  
return function()  
    setProperty(data, 'test', 20);  
    log(data.test); \--prints 20  
      
    data.test \= 30;  
    log(data.test); \--prints 30  
      
    setProperty(data, 'test', 20); \--this will not set the property, since it already exists\!  
    log(data.test); \--prints 30  
end

\- \[getApp\](/lua-scripting-api/api-reference-and-tips/global-functions/getapp.md): API \- returns the App class which gives access to a group of functions and properties related to SA application.  
return function()  
    local app \= getApp();  
    app.setResolution(900, 900); \--sets the app window resolution to 900 by 900  
end

\- \[save\](/lua-scripting-api/api-reference-and-tips/global-functions/save.md): API \- saves the global variable: data on the main coroutine. This data can be found as a .JSON file in the script's folder.  
You can call save() within other coroutines, but it will save the data object from the main coroutine\!  
return function()  
    data \= {};  
    setProperty(data, 'x', 100); \--set the default value to 100\. If x already exists, nothing will happen\!  
      
    save(); \--data.x gets saved as 100  
      
    data.x \= 300; \--since we don't save after settings this, this value will be lost when loaded  
      
    load(); \--data.x gets reset back to 100  
      
    log(data.x); \--prints 100  
end

\- \[load\](/lua-scripting-api/api-reference-and-tips/global-functions/load.md): API \- Loads the .JSON file from the script folder. This can be used to have data persist between streaming sessions, or to just store script settings in a single location.  
return function()  
    \--usually you call load at the top of a script.  
    load(); \--makes the data global variable exist with all previously stored/saved data.  
      
    \-- \---------------  
    \--note this is not needed in this example. it's just for show\!  
    local mdata \= get('data'); \--note this is only needed if you   
    \-- are accessing the data from a subcoroutine\!  
      
    \--if you want to save data from a subcoroutine, first make a copy like above  
    \--then use set('data', mdata);  
    \--then use save();  
    \-- \---------------  
      
    if data.x \== nil then  
        data.x \= 1;  
    else   
        data.x \= data.x \+ 1;  
    end  
      
    save(); \--data gets saved in the json settings\!  
end

\- \[addEvent\](/lua-scripting-api/api-reference-and-tips/global-functions/addevent.md): API \- subscribe to an event to receive data and a trigger of when certain situations occur  
\--note this specific event has 2 parameters  
function yourFunctionName(user, string\_message)  
    log(user.displayName .. ' has said ' .. string\_message);  
end  
   
return function()  
      
    \--attaches the event to yourFunctionName()  
    addEvent('chatMessage', 'yourFunctionName');   
      
      \--make sure this script is kept alive so the event can be processed\!  
    keepAlive();  
end

\- \[removeEvent\](/lua-scripting-api/api-reference-and-tips/global-functions/removeevent.md): API \- unsubscribe to an event that you previously subscribed to.  
\--note this specific event has 2 parameters  
function yourFunctionName(user, string\_message)  
    log(user.displayName .. ' has said ' .. string\_message);  
end  
   
return function()  
      
    \--attaches the event to yourFunctionName()  
    addEvent('chatMessage', 'yourFunctionName');   
    wait(3);  
      
    \--unsubscribe your function from receiving events  
    removeEvent('chatMessage');   
      
      
    \--make sure this script is kept alive so the event can be processed\!  
    keepAlive();  
end

\- \[keepAlive\](/lua-scripting-api/api-reference-and-tips/global-functions/keepalive.md): API \- Keep the script alive by pausing it. This allows for other coroutines to be processed while the main script doesn't really do much.  
keepAlive(); is often used with scripts that are set to Run as "On Connect" and scripts that subscribe to specific events.  
\--note this specific event has 2 parameters  
function yourFunctionName(user, string\_message)  
    log(user.displayName .. ' has said ' .. string\_message);  
end  
   
return function()  
      
    \--attaches the event to yourFunctionName()  
    addEvent('chatMessage', 'yourFunctionName');   
      
    \--make sure this script is kept alive so the event can be processed\!  
    keepAlive();  
      
    \--nothing below keepAlive() will ever be reached.  
end

# \# Events

\# Events

\- \[BankController\](/lua-scripting-api/api-reference-and-tips/events/bankcontroller.md): API \-  
The bank controller's purpose is to allow for custom currency integrations.

All functions shown below are required and the data you provide is completely up to you.

(Usually currency integrations will use [Websockets](https://docs.streamavatars.com/lua-scripting-api/api-reference-and-tips/events/websockets) or [WWWRequests](https://docs.streamavatars.com/lua-scripting-api/api-reference-and-tips/global-functions/webrequest-get-post) to be the middle-man for talking between applications)

First you have to enable the LuaScript Integration found in: Shop Editing \> Currency Settings.

script\_trigger\_type \= 'On Connect';

\--note:  
\--the withdraw, deposit, getBalance, getRichest, fixedAdjustment   
\--MUST return value(s);

function fixedAdjustment(viewerId, amount)

    \--code to set the viewerId's currency to the exact amount  
      
      
    return amount; \--return the new balance  
end

function getRichest(howMany)  
    \--this is used for extension leaderboard data. the data returned here will be displayed on the extension

    \--try to grab the top howMany requested and put it into a richest array like so...  
    \--this array will be sorted correctly so order doesnt matter, just ensure it's the richest users.

    local richestArray \= {  
        { displayName \= 'clonzeh', points \= 1234 },  
        { displayName \= 'Person2', points \= 442 },  
        { displayName \= 'Person3', points \= 14532 }  
    };

    return richestArray; \--return the richest users array  
end

function getBalance(viewerId)  
    \--code to check lua balance of viewerId;  
    return 1234; \--return the balance of the viewer  
end

function deposit(viewerId, amount)  
    \--code to add points to the viewerid  
    local newBalance \= 1234 \+ amount;  
    \--finish code  
      
    return newBalance; \--return the new balance of the viewer  
end

function withdraw(viewerId, amount)

    local balanceFound \= 1234;  
    local success \= false;  
      
    if balanceFound \> amount then  
        \--code to subtract points from the viewerId  
        local newBalance \= balanceFound \- amount;  
        \--if the subtraction works then  
        \--set success to true...  
        success \= true;  
        return success, newBalance;  
    end

    return success, balanceFound; \--return the new balance of the user  
end

function massDeposit(viewerIds, amounts)

    \--efficiently deposit large amounts points to users...  
    \--this is useful if a custom bot currency system has an endpoint to adjust multiple users at once.

    \--or just do it one at a time inside a loop the deposit(viewerId, amount); function  
    for key, value in ipairs(viewerIds) do  
        deposit(value, amounts\[key\]);  
    end  
end

return function()  
    setupBankController(); \--adds all required events for the bank controlling system.  
    \--NOTE: All functions above must exist with the same parameters specificed.  
      
    keepAlive();  
end

\- \[ServiceController\](/lua-scripting-api/api-reference-and-tips/events/servicecontroller.md): API \-  
function output(string\_message)  
The service controller's purpose is to enable SA to allow hooking up custom stream services or chat-based programs to stream avatars. (Note: you cannot get the extension to work with it\!)

First you must use the custom-lua streaming service found in Login Details.

    log('the app wants to send a message to your viewers...');  
    log(string\_message);  
end

return function()  
    local app \= getApp();  
    addEvent('luaPlatformOutput', 'output'); \--attaches the event to output()

    local myUserId \= 1234;  
    local myUserName \= 'clonzeh\_lua';

    app.platformServiceSettings.SetStreamer(myUserId, myUserName);  
    wait(3);  
    app.platformServiceSettings.SetUserJoin(myUserId, myUserName);  
    wait(3);  
    app.platformServiceSettings.AddMessage(myUserId, myUserName, 'hello test');  
    wait(3);  
    app.platformServiceSettings.AddMessage(myUserId, myUserName, '\!mass jump');  
    wait(3);  
    app.platformServiceSettings.AddMessage(myUserId, myUserName, '\!currency');  
    wait(3);  
    app.platformServiceSettings.SetFollower(myUserId, true);  
    app.platformServiceSettings.SetSubscriber(myUserId, true);  
    app.platformServiceSettings.SetModerator(myUserId, true);  
    wait(1);  
      
    app.platformServiceSettings.PlatformCurrencyDonation(myUserId, myUserName, 50, 1000);   
    \--they donated 50, the lifetime total is now 1000

    app.platformServiceSettings.CustomCommandRedemption(myUserId, myUserName, 'Redemption Title Here',  
        'extra user input here');  
    wait(1);  
    app.platformServiceSettings.SetUserLeave(myUserId);  
    keepAlive();  
end

\- \[Read Chat\](/lua-scripting-api/api-reference-and-tips/events/read-chat.md): API \-  
function yourEvent(user, string\_message)  
    log(user.displayName .. ' has said ' .. string\_message);  
end

return function()  
    addEvent('chatMessage', 'yourEvent'); \--attaches the event to yourEvent()  
    keepAlive();  
end

\- \[Websockets\](/lua-scripting-api/api-reference-and-tips/events/websockets.md): API \-  
Events are asynchronous coroutines.  
function yourEvent(title, type, message, code)  
   
    if title \~= socket then \--make sure we're using the socket title we want\!  
        return; \--otherwise exit out early :)  
    end  
      
    if type \== 'OnMessage' then  
        \--route all messages here\!  
        \--the code will be blank. ''  
        log('receiving message: ' .. message);  
    end  
    if type \== 'OnOpen' then  
        \--the socket opened\!\!  
        \--the message and code will be blank. ''  
        log('socket was opened\!');  
    end  
      
    if type \== 'OnClose' or type \== 'OnError' then  
        \--if the message type is OnClose or OnError, let's clean up the socket...  
        local app \= getApp();  
        app.removeWebSocket(socket);  
        log('socket is closed\!');  
        log(message);  
        log(code);  
    end  
end

socket \= 'my\_socket\_title'; \--just storing the title in a global variable...  
return function()  
    local app \= getApp();  
      
    \--remove old existing websocket just incase...  
    app.removeWebSocket(socket);  
    wait(1); \--give it time to remove the old one  
    addEvent('websocket', 'yourEvent'); \--subscribe to all websockets that exist...  
      
    \--this wss server will echo whatever you send\!  
    app.createWebsocket(socket, 'wss://ws.ifelse.io/'); \--title a websoscket and connect to a server...  
    wait(2); \--give it time to connect  
    app.sendWebsocketMessage(socket, 'gogo\!');  
    wait(2);  
    log('nice job... we gunna wait until close now\!');  
    keepAlive();  
end

\- \[Scriptable Block Trigger\](/lua-scripting-api/api-reference-and-tips/events/scriptable-block-trigger.md): API \-  
function yourEvent(user, block)

    log('block hit\! ' .. block.id .. ' by ' .. user.displayName .. ' at block position: ' .. block.position.x .. ' ' .. block.position.y);  
      
    local level \= getBackground();  
    log('current level is: ' .. level);  
      
    if level \== 'green\_grass\_background' then   
    \--this would be whatever your background name is\!  
      
        local cd\_ready \= helper.checkCooldown('cd');  
        local cd\_timeLeft \= helper.cooldownTimeLeft('cd');  
          
        if cd\_ready \== false then  
            log('cannot run yet for another ' .. cd\_timeLeft .. ' seconds.');  
            return;  
        end  
          
          
        if block.id \== 1 then   
            \--remember that this id is specific to the current background level,  
            \--so you might also want to check the level.  
            user.runCommand('\!jump' );  
        end  
          
        helper.setCooldown('cd');   
        \--reset the cooldown timer so we have to wait again\!  
      
    end  
end  
   
return function()  
    addEvent('scriptableBlocks', 'yourEvent'); \--attaches the event to yourEvent()  
      
    \--vv none of this is actually needed it's just showing what else is possible.  
    cd \= helper.createCooldown(15, true); \--15 seconds, starts ready=true  
    local level \= getBackground();  
      
    local scriptBlocks \= getScriptableBlocks();  
     \--give a list of all blocks on the current level  
       
    log('the list of blocks on ' .. level .. ' are:');  
    for i,block in pairs(scriptBlocks) do  
        log(block.id);  
        log(block.position.x .. ' ' .. block.position.y);  
    end  
      
    \--^^ none of this is actually needed it's just showing what else is possible.  
    keepAlive(); \--this is needed.  
end

\- \[Platform Donation\](/lua-scripting-api/api-reference-and-tips/events/platform-donation.md): API   
function yourEvent(user, donationInfo)  
    log(user.displayName .. ' donated: ' .. donationInfo.amount\_donated);  
      
      
    \--twitch has removed lifeTime\_donated data and it is no longer available.  
    \--log('total bits donated: ' .. donationInfo.lifeTime\_donated);   
end

return function()  
    log('starting up func')  
    addEvent('platformDonation', 'yourEvent'); \-- attaches the event to yourEvent()  
      
    keepAlive();  
end  
\-  
\- \[App State Change\](/lua-scripting-api/api-reference-and-tips/events/app-state-change.md): API  
function appStateChange(string\_stateName)  
    log('app is switching to state: ' .. string\_stateName);  
end

return function()  
    addEvent('appState', 'appStateChange'); \--subscribe to appState changes  
    keepAlive();  
end  
\-  
\- \[Custom Command\](/lua-scripting-api/api-reference-and-tips/events/custom-command.md): API \-  
function yourEvent(user, string\_message)  
    log(user.displayName .. ' issued a custom command with the message: ' .. string\_message);  
end

return function()  
    addEvent('customCommand', 'yourEvent'); \--attaches the event to yourEvent()  
    keepAlive();  
end  
\- \[Basketball Outcome\](/lua-scripting-api/api-reference-and-tips/events/basketball-outcome.md): API \-  
function yourEvent(winners, losers, mvp, winnerScores, loserScores)  
    if losers \== nil then  
        log('the game was cancelled\!');  
        return;  
    end  
    if winners \== nil then  
        log('the game was drawn\!');  
        log('everyone is a losers... their stats and order will exist in parameters, as well as the highest scorer as mvp');  
    end

    log('the winners are...');  
    wait(1);

    local str \= '';  
      
    for i,user in pairs(winners) do  
      str \= str .. ' ' .. user.displayName .. '\#=' .. winnerScores\[i\];  
    end  
    log(str); \--prints all winners like:  
    \-- clonzeh\#=10 someonelse\#=2 yetanother\#=5  
    wait(1);  
    log('and the mvp is: ' .. mvp);  
end

return function()  
    addEvent('basketballOutcome', 'yourEvent');  
    keepAlive();  
end

\- \[BattleRoyale Outcome\](/lua-scripting-api/api-reference-and-tips/events/battleroyale-outcome.md): API \-  
function yourEvent(winner, earnings)  
     log('the winner is: ' .. winner.displayName);  
     log('earnings: ' .. earnings); \--earnings does not include lootbox  
end

return function()  
     addEvent('battleRoyaleOutcome', 'yourEvent');  
     keepAlive();  
end

\- \[Boss Battle Outcome\](/lua-scripting-api/api-reference-and-tips/events/boss-battle-outcome.md): API \-  
function yourEvent(users, boss\_name, difficulty, result)  
    if result \== 'cancelled' or users \== nil or boss\_name \== nil or difficulty \== 'none' then  
        return;  
    end

    if result \== 'players' then  
        local str \= 'players won... ';  
        for i,user in pairs(users) do  
            str \= str .. ' ' .. user.displayName;  
        end  
        log(str);  
    end

    if result \== 'boss' then  
        log('boss: ' .. boss\_name .. ' won.');  
    end

    log('boss difficulty was: ' .. difficulty); \--difficulty can be: easy, normal, hard, none  
end

return function()  
    addEvent('bossBattleOutcome', 'yourEvent');  
    keepAlive();  
end

\- \[Boss Battle Player Joined\](/lua-scripting-api/api-reference-and-tips/events/boss-battle-player-joined.md): API \-  
function yourEvent(user, class\_name)  
     
    log('boss player: ' .. user.displayName .. ' has joined as ' .. class\_name);  
end

return function()  
    addEvent('bossBattlePlayerJoined', 'yourEvent');  
    keepAlive();  
end

\- \[Duel Outcome\](/lua-scripting-api/api-reference-and-tips/events/duel-outcome.md): API \-  
function yourEvent(winner, loser, earnings, initiator) \--if winner and loser are \== nil, then the duel was cancelled.  
    log(initiator.displayName .. ' started this duel...');  
    log('the winner is: ' .. winner.displayName .. ' and the loser is: ' .. loser.displayName);  
    log('earnings: ' .. earnings); \--earnings does not include lootbox  
end

return function()  
    addEvent('duelOutcome', 'yourEvent');  
    keepAlive();  
end

\- \[On JumpCatch Star\](/lua-scripting-api/api-reference-and-tips/events/on-jumpcatch-star.md): API \-  
function yourEvent(user)  
    log(user.displayName .. ' caught a star\!');  
end

return function()  
    addEvent('jumpCatchStar', 'yourEvent');  
    keepAlive();  
end

\- \[On Background Switch\](/lua-scripting-api/api-reference-and-tips/events/on-background-switch.md): API \-  
function yourEvent(user, string\_message)

    if user \== nil then   
        \-- if user is nil, that means the bg was changed by a non-user  
        \-- (or manually by streamer via level select dropdown)  
        log('the level has switched to: ' .. string\_message);  
    else  
        log(user.displayName .. ' has switched the level to: ' .. string\_message); \-- changed via command  
    end  
      
    if string\_message \~= 'forest' then \--prevent infinite loop of event procing  
      
        runCommand('\!background forest nightbot');   
        \-- runs the background command to switch level as the broadcaster, but also passes along who issued the command as well.  
        \-- this is useful for making custom commands to allow viewers to switch levels and passing along the information that they issued it.  
    end  
end

return function()  
    addEvent('backgroundSwitch', 'yourEvent'); \-- attaches the event to yourEvent()  
    keepAlive();  
end

\- \[On Avatar Change\](/lua-scripting-api/api-reference-and-tips/events/on-avatar-change.md): API \-  
function yourEvent(user, avatar)  
    log(user.displayName .. ' has changed their avatar to ' .. avatar .. '\!');  
end

return function()  
    addEvent('changeAvatar', 'yourEvent'); \--attaches the event to yourEvent()  
    keepAlive();  
end

\- \[On New Viewer\](/lua-scripting-api/api-reference-and-tips/events/on-new-viewer.md): API \-  
function yourEvent(user)  
    log(user.displayName .. ' is a new viewer to your channel\!');  
end

return function()

    addEvent('newViewer', 'yourEvent'); \--attaches the event to yourEvent()  
    keepAlive();  
end

\- \[On InitializeNewViewer\](/lua-scripting-api/api-reference-and-tips/events/on-initializenewviewer.md): API \-  
function yourEvent(user)  
    \--note  this is similar to OnNewViewer event. The difference is that this event fires before the avatar spawns.  
    \--also note: under General \> Avatar Settings, there's an option to disable "force free avatar" which lets you set everything in shop as gift only  
    \--which makes this even able to completely handle the first avatar a viewer will get.  
     log(user.displayName .. ' is being initialized. you can make changes to them before they spawn\!');  
end

return function()

    addEvent('selectInitialAvatar', 'yourEvent'); \--attaches the event to yourEvent()  
    keepAlive();  
end

\- \[On Follower\](/lua-scripting-api/api-reference-and-tips/events/on-follower.md): API \-  
function yourEvent(user)  
    log('Thanks for following' .. user.displayName);  
end

return function()  
    addEvent('follower', 'yourEvent');  
    keepAlive();  
end

\- \[On Raid\](/lua-scripting-api/api-reference-and-tips/events/on-raid.md): API \-  
function yourEvent(user)  
    log('Thanks for raiding me @' .. user.displayName);  
end

return function()  
    addEvent('raid', 'yourEvent');  
    keepAlive();  
end

\- \[On Subscriber\](/lua-scripting-api/api-reference-and-tips/events/on-subscriber.md): API \-  
function yourEvent(user, cumulativeCount, tier)  
    log('Thanks for subbing ' .. user.displayName .. '\! x' .. tier);  
end

return function()  
    addEvent('subscriber', 'yourEvent');  
    keepAlive();  
end

\- \[On Avatar Spawn\](/lua-scripting-api/api-reference-and-tips/events/on-avatar-spawn.md): API \-  
function yourEvent(user)  
    log(user.displayName .. ' has spawned\!');  
end

return function()  
    addEvent('spawn', 'yourEvent'); \--attaches the event to yourEvent()  
    keepAlive();  
end

\- \[On Trigger Object\](/lua-scripting-api/api-reference-and-tips/events/on-trigger-object.md): API \-  
function yourEvent(user, object, eventType)  
    if user \~= nil then  
        if eventType \== 'enter' then  
            log(user.displayName .. 'entered');  
        end  
        if eventType \== 'exit' then  
            log(user.displayName .. 'exited');  
        end  
    else  
        if eventType \== 'mouseEntered' then  
        end  
        if eventType \== 'mouseExited' then  
        end  
        if eventType \== 'mouseDown\_0' then  
        end  
        if eventType \== 'mouseUp\_0' then  
        end  
     end  
end

return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();  
    wait(3);  
    myObject.physics.addBoxTrigger();  
    myObject.physics.mouseTrigger \= true; \--enables mouse tracking on object  
    log(myObject.physics.hasTrigger);  
      
    app.addEvent('triggerObject', 'yourEvent');  
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

\- \[On Hotkey\](/lua-scripting-api/api-reference-and-tips/events/on-hotkey.md): API \-  
function yourEvent(string\_modifier, string\_hotkey)  
    \--isFocused is where the application is focused or not  
    \--string modifier will contain all modifiers that are held.  
    \--control+alt+shift  
    \--hotkey will contain a string based on which key is pressed  
    \--example: pressing 8 would give: N8  
end

return function()  
    addEvent('hotkeyPress', 'yourEvent');  
    keepAlive();  
end

\- \[On Purchase\](/lua-scripting-api/api-reference-and-tips/events/on-purchase.md): API \-  
function yourEvent(user, receiptData)  
    \--possible types are: avatar, color, action, gear, nametag  
    log(user.displayName .. ' bought ' .. receiptData.name);  
      
    \--if the type is gear, color, or action,   
    \--that means there will be a ":" in the item name \-\> block\_man:blue  
      
    \--you can use   
    \--local blah \= helper.split(receiptData.name, ':');   
    \--then the item name will be. \-\> blah\[2\] \-\> blue  
      
    log('type of item: ' .. receiptData.type);  
    log('currency cost: ' .. receiptData.cost);  
    log('platformCurrency cost: ' .. receiptData.platformCurrencyCost);  
    log('was the item a gift? ' .. tostring(receiptData.gifted));  
end

return function()  
    addEvent('receipts', 'yourEvent'); \--attaches the event to yourEvent()  
    keepAlive();  
end

# \# Classes

\# Classes

\- \[App\](/lua-scripting-api/api-reference-and-tips/classes/app.md): API \-

\- \[globalAvatarScale {get;set}\](/lua-scripting-api/api-reference-and-tips/classes/app/globalavatarscale-get-set.md): API \-  
return function()  
    local app \= getApp();  
    app.globalAvatarScale \= 2; \--accepts values between 0.1 and 2  
end

\- \[globalNametagScale {get;set}\](/lua-scripting-api/api-reference-and-tips/classes/app/globalnametagscale-get-set.md): API \-  
return function()  
    local app \= getApp();  
    app.globalNametagScale \= 2; \--accepts values etween 0.5 and 1.5  
end

\- \[globalChatBubbleScale {get;set}\](/lua-scripting-api/api-reference-and-tips/classes/app/globalchatbubblescale-get-set.md): API \-  
return function()  
    local app \= getApp();  
    app.globalChatBubbleScale \= 2; \--accepts values between 1 and 4  
end

\- \[globalNametagStack {get;set}\](/lua-scripting-api/api-reference-and-tips/classes/app/globalnametagstack-get-set.md): API \-  
return function()  
    local app \= getApp();  
    app.globalNametagStack \= 3; \--accepts values between 0 and 30  
end

\- \[getResolution\](/lua-scripting-api/api-reference-and-tips/classes/app/getresolution.md): API \-  
return function()  
    local app \= getApp();  
    local res \= app.getResolution();  
      
    log('current window resolution is ' .. res.x .. ', ' .. res.y);  
end  
The resolution refers to the window size, not game coordinates\! look at [convertPercentToPosition](https://docs.streamavatars.com/lua-scripting-api/api-reference-and-tips/classes/app/convertpercenttoposition) for in-game coordinate system.  
\- \[platformServiceSettings\](/lua-scripting-api/api-reference-and-tips/classes/app/platformservicesettings.md): API \- Allows controlling of the custom lua streaming platform  
You can use this to hook Stream Avatars up to any service you want.  
It is not possible to allow the extension to work with a custom platform service.

function output(string\_message)  
    log('the app wants to send a message to your viewers...');  
    log(string\_message);  
end

return function()

    local app \= getApp();

    addEvent('luaPlatformOutput', 'output'); \--attaches the event to output()

    local myUserId \= 1234;  
    local myUserName \= 'clonzeh\_lua';

    app.platformServiceSettings.SetStreamer(myUserId, myUserName);  
    wait(3);  
    app.platformServiceSettings.SetUserJoin(myUserId, myUserName);  
    wait(3);  
    app.platformServiceSettings.AddMessage(myUserId, myUserName, 'hello test');  
    wait(3);  
    app.platformServiceSettings.AddMessage(myUserId, myUserName, '\!mass jump');  
    wait(3);  
    app.platformServiceSettings.AddMessage(myUserId, myUserName, '\!currency');  
    wait(3);  
    app.platformServiceSettings.SetFollower(myUserId, true);  
    app.platformServiceSettings.SetSubscriber(myUserId, true);  
    app.platformServiceSettings.SetModerator(myUserId, true);  
    wait(1);  
      
    app.platformServiceSettings.PlatformCurrencyDonation(myUserId, myUserName, 50, 1000);   
    \--they donated 50, the lifetime total is now 1000

    app.platformServiceSettings.CustomCommandRedemption(myUserId, myUserName, 'Redemption Title Here',  
        'extra user input here');  
    wait(1);  
    app.platformServiceSettings.SetUserLeave(myUserId);  
    keepAlive();  
end

\- \[setResolution\](/lua-scripting-api/api-reference-and-tips/classes/app/setresolution.md): API \-  
return function()  
    local app \= getApp();  
    app.setResolution(900, 900); \--this removes fullscreen toggle and becomes windowed  
end

\- \[setFullscreen\](/lua-scripting-api/api-reference-and-tips/classes/app/setfullscreen.md): API \-  
return function()  
    local app \= getApp();  
    app.setFullscreen();  
end

\- \[getStreamer\](/lua-scripting-api/api-reference-and-tips/classes/app/getstreamer.md): API \-  
return function()  
    local app \= getApp();  
    local user \= app.getStreamerUser();  
    if user \== nil then  
        return;  
    end  
      
    log(user.displayName .. ' is the streamer.');  
end

\- \[convertPositionToPercent\](/lua-scripting-api/api-reference-and-tips/classes/app/convertpositiontopercent.md): API \-  
return function()  
    local app \= getApp();  
    local percent \= app.convertPositionToPercent(120, 300);  
    log(percent.x .. ', ' .. percent.y);  
end

\- \[convertPercentToPosition\](/lua-scripting-api/api-reference-and-tips/classes/app/convertpercenttoposition.md): API \-  
x=0 is the left side of the screen, x=1 is the right side.  
y=0 is the bottom of the screen, y=1 is the top.  
return function()  
    local app \= getApp();  
    local position \= app.convertPercentToPosition(0.5, 0.5);  
    \--position.x will be 0 because the center.x of the screen is 0\.   
    log(position.x .. ', ' .. position.y);   
end

\- \[playSound\](/lua-scripting-api/api-reference-and-tips/classes/app/playsound.md): API \-  
return function()  
    local app \= getApp();  
    local soundId \= app.playSound('myCustomSound', false); \--sound name, loops  
end

\- \[createBomb\](/lua-scripting-api/api-reference-and-tips/classes/app/createbomb.md): API \-  
return function()  
    local app \= getApp();  
      
    \--create bomb at x:0 y:0  
    app.createBomb(0, 0);  
end

\- \[pitchSound\](/lua-scripting-api/api-reference-and-tips/classes/app/pitchsound.md): API \-  
return function()  
    local app \= getApp();  
    local soundId \= app.playSound('myCustomSound', false);  
    app.pitchSound(soundId, 2);  
end

\- \[stopSound\](/lua-scripting-api/api-reference-and-tips/classes/app/stopsound.md): API \-  
return function()  
    local app \= getApp();  
    local soundId \= app.playSound('myCustomSound', false);  
    app.stopSound(soundId);  
end

\- \[soundIsPlaying\](/lua-scripting-api/api-reference-and-tips/classes/app/soundisplaying.md): API   
return function()  
    local app \= getApp();  
    local soundId \= app.playSound('myCustomSound', false);  
      
    wait(1);  
    if app.soundIsPlaying(soundId) \== true then  
        log('the sound is playing\!');  
    end  
end

\- \[createGameObject\](/lua-scripting-api/api-reference-and-tips/classes/app/creategameobject.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject(); \--objects can be used for adding images  
end

\- \[getGameObject\](/lua-scripting-api/api-reference-and-tips/classes/app/getgameobject.md): API \-  
This is how you get objects to be shared between sub coroutines.  
function test()  
    local id \= get('objectId');  
    local app \= getApp();  
    local ob \= app.getGameObject(id);  
end  
objectId \= '';  
return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject(); \--objects can be used for adding images  
    objectId \= myObject.id;  
    async('test');  
end  
\- \[createChatBubble\](/lua-scripting-api/api-reference-and-tips/classes/app/createchatbubble.md):   
For emotes on twitch to display, they must first be read from chat before they can be used in chat bubble. For example 'kappa' will use the kappa emote only if someone has previously types Kappa into chat.  
API \-  
return function()  
    local app \= getApp();  
      
    local position \= app.convertPercentToPosition(0.5, 0.5);  
    \--creates a chat bubble in the center of the screen for 30 seconds with  
    \--'test' as the text.  
    app.createChatBubble(position.x, position.y, 30, 'test')  
end

\- \[createWebsocket\](/lua-scripting-api/api-reference-and-tips/classes/app/createwebsocket.md): API \-  
function yourEvent(title, type, message, code)  
   
    if title \~= socket then \--make sure we're using the socket title we want\!  
        return; \--otherwise exit out early :)  
    end  
      
    if type \== 'OnMessage' then  
        \--route all messages here\!  
        \--the code will be blank. ''  
        log('receiving message: ' .. message);  
    end  
    if type \== 'OnOpen' then  
        \--the socket opened\!\!  
        \--the message and code will be blank. ''  
        log('socket was opened\!');  
    end  
      
    if type \== 'OnClose' or type \== 'OnError' then  
        \--if the message type is OnClose or OnError, let's clean up the socket...  
        local app \= getApp();  
        app.removeWebSocket(socket);  
        log('socket is closed\!');  
        log(message);  
        log(code);  
    end  
end

return function()  
    local app \= getApp();  
      
    \--remove old existing websocket just incase...  
    app.removeWebSocket(socket);  
    wait(1); \--give it time to remove the old one  
    addEvent('websocket', 'yourEvent'); \--subscribe to all websockets that exist...  
      
    \--this wss server will echo whatever you send\!  
    local protocols \= { 'headerKey', 'headerValue', 'headerKey2', 'headerValue2' };  
    app.createWebsocket(socket, 'wss://ws.ifelse.io/', protocols);  
    keepAlive();  
end

\- \[removeWebsocket\](/lua-scripting-api/api-reference-and-tips/classes/app/removewebsocket.md): API \-  
This is designed to be used with applyImage()...  
function yourEvent(title, type, message, code)  
   
    if title \~= socket then \--make sure we're using the socket title we want\!  
        return; \--otherwise exit out early :)  
    end  
      
    if type \== 'OnMessage' then  
        \--route all messages here\!  
        \--the code will be blank. ''  
        log('receiving message: ' .. message);  
    end  
    if type \== 'OnOpen' then  
        \--the socket opened\!\!  
        \--the message and code will be blank. ''  
        log('socket was opened\!');  
    end  
      
    if type \== 'OnClose' or type \== 'OnError' then  
        \--if the message type is OnClose or OnError, let's clean up the socket...  
        local app \= getApp();  
        app.removeWebSocket(socket);  
        log('socket is closed\!');  
        log(message);  
        log(code);  
    end  
end

return function()  
    local app \= getApp();  
      
    \--remove old existing websocket just incase...  
    app.removeWebSocket(socket);  
    wait(1); \--give it time to remove the old one  
    addEvent('websocket', 'yourEvent'); \--subscribe to all websockets that exist...  
      
    \--this wss server will echo whatever you send\!  
    app.createWebsocket(socket, 'wss://ws.ifelse.io/');  
    wait(3);  
    app.removeWebSocket(socket);  
end

\- \[sendWebsocketMessage\](/lua-scripting-api/api-reference-and-tips/classes/app/sendwebsocketmessage.md): API \-  
function yourEvent(title, type, message, code)  
   
    if title \~= socket then \--make sure we're using the socket title we want\!  
        return; \--otherwise exit out early :)  
    end  
      
    if type \== 'OnMessage' then  
        \--route all messages here\!  
        \--the code will be blank. ''  
        log('receiving message: ' .. message);  
    end  
    if type \== 'OnOpen' then  
        \--the socket opened\!\!  
        \--the message and code will be blank. ''  
        log('socket was opened\!');  
    end  
      
    if type \== 'OnClose' or type \== 'OnError' then  
        \--if the message type is OnClose or OnError, let's clean up the socket...  
        local app \= getApp();  
        app.removeWebSocket(socket);  
        log('socket is closed\!');  
        log(message);  
        log(code);  
    end  
end

return function()  
    local app \= getApp();  
      
    \--remove old existing websocket just incase...  
    app.removeWebSocket(socket);  
    wait(1); \--give it time to remove the old one  
    addEvent('websocket', 'yourEvent'); \--subscribe to all websockets that exist...  
      
    \--this wss server will echo whatever you send\!  
    local protocols \= { 'headerKey', 'headerValue', 'headerKey2', 'headerValue2' };  
    app.createWebsocket(socket, 'wss://ws.ifelse.io/', protocols);  
    wait(3);  
    app.sendWebsocketMessage(socket, 'gogo\!');  
    keepAlive();  
end

\- \[getAppState\](/lua-scripting-api/api-reference-and-tips/classes/app/getappstate.md): API \-  
return function()  
    local app \= getApp();  
    local state \= app.getAppState();  
      
    log('the current appState is: ' .. state);  
end

\- \[sha256\\\_base64\](/lua-scripting-api/api-reference-and-tips/classes/app/sha256\_base64.md): API \-  
return function()  
    local app \= getApp();  
    local state \= app.getAppState();  
      
    \--encryption and base64 shortcut  
    local sha256AndBase64 \= app.sha256\_base64('somestring');  
    log(sha256AndBase64);  
end  
**EXAMPLE SCRIPT FOR OBS WEBSOCKET:**  
function authentication(ob)  
    local challenge \= ob\['d'\]\['authentication'\]\['challenge'\];  
    local salt \= ob\['d'\]\['authentication'\]\['salt'\];

    set('rpcVersion', ob\['d'\]\['authentication'\]\['rpcVersion'\])

    local app \= getApp();  
    local salted\_sha\_base64 \= app.sha256\_base64(password .. salt);   
    local password\_challenge\_sha\_base64 \= app.sha256\_base64(salted\_sha\_base64 .. challenge); 

    local m\_data \= {};  
    m\_data\['op'\] \= 1;  
    m\_data\['d'\] \= {};

    m\_data\['d'\]\['rpcVersion'\] \= rpcVersion;  
    m\_data\['d'\]\['authentication'\] \= password\_challenge\_sha\_base64;  
    m\_data\['d'\]\['eventSubscriptions'\] \= 33; \--these are events you can subscribe to

    app.sendWebsocketMessage(socket, json.serialize(m\_data));

end

function yourEvent(title, type, message, code)

    if title \~= socket then \--make sure we're using the socket title we want\!  
        return; \--otherwise exit out early :)  
    end

    if type \== 'OnMessage' then  
        \--route all messages here\!  
        \--the code will be blank. ''

        log('receiving message: ' .. message);

        local ob \= json.parse(message);  
        if ob\['op'\] \== 0 then  
            authentication(ob);  
        end

        if ob\['op'\] \== 2 then  
           switchToScene(gamePlaySceneName);  
        end  
    end  
    if type \== 'OnOpen' then  
        \--the socket opened\!\!  
        \--the message and code will be blank. ''  
        log('socket was opened\!');  
    end

    if type \== 'OnClose' or type \== 'OnError' then  
        \--if the message type is OnClose or OnError, let's clean up the socket...  
        local app \= getApp();  
        app.removeWebSocket(socket);  
        log('socket is closed\!');  
        log(message);  
        log(code);  
    end  
end

function switchToScene(scene)  
    local m\_data \= {};  
    m\_data\['op'\] \= 6;  
    m\_data\['d'\] \= {};  
    local app \= getApp();  
    m\_data\['d'\]\['requestType'\] \= 'SetCurrentProgramScene';  
    m\_data\['d'\]\['requestId'\] \= 'f819dcf0-89cc-11eb-8f0e-382c4ac93b9c';  
    m\_data\['d'\]\['requestData'\] \= {};  
    m\_data\['d'\]\['requestData'\]\['sceneName'\] \= scene;  
    app.sendWebsocketMessage(socket, json.serialize(m\_data));  
end

\--retrieved from json data  
ip \= 'ws://192.168.1.70:4444';  
password \= 'your\_websocket\_password\_in\_obs';  
gamePlaySceneName \= 'your scene title';  
\--  
rpcVersion \= 1;  
socket \= 'obs\_socket\_holder'; 

return function()

    load();  
    log('OBS websocket tutorial');  
    local app \= getApp();

    \--remove old existing websocket just incase...  
    app.removeWebSocket(socket);  
    wait(1); \--give it time to remove the old one  
    addEvent('websocket', 'yourEvent'); \--subscribe to all websockets that exist...

      
    local params \= {};  
    params\[1\] \= 'Sec-WebSocket-Protocol';  
    params\[2\] \= 'obswebsocket.json';  
    app.createWebsocket(socket, ip, params); \--title a websoscket and connect to a server...

    keepAlive();  
end

\- \[getUserFromData\](/lua-scripting-api/api-reference-and-tips/classes/app/getuserfromdata.md): API \-  
return function()  
    local app \= getApp();  
    local user \= app.getUserFromData('clonzeh');  
      
    if user \== nil then  
        log('could not find target user');  
        return;  
    end  
      
    if user.isActive \== false then  
        log('this is not an active user...');  
        \--this means you cannot modify live-settings on the avatar directly  
        \--such as the temporaryScale  
    end  
      
end

\- \[getIdsFromData\](/lua-scripting-api/api-reference-and-tips/classes/app/getidsfromdata.md): API \-  
return function()  
    local app \= getApp();  
    local users \= app.getIdsFromData();  
      
    local counter \= 0;  
      
    for i, value in ipairs(users) do  
          
        if counter \> 50 then \--handle 50 users before yielding  
            counter \= 0;  
            yield();   
            \--we yield here because looping over ALL users with getUserFromData()   
            \--could be extremely taxing and soft-lock the app due to how much  
            \--work is being done.  
        end  
          
        local user \= app.getUserFromData(value);   
        \--NOTE: this user's avatar might not be actively spawned  
          
        if user.isActive \== false then  
            log('this is not an active user...');  
            \--this means you cannot modify live-settings on the avatar directly  
            \--such as the temporaryScale  
        end  
          
        \--do work with user user...  
          
        counter \= counter \+ 1; \--increase counter  
    end  
end

\- \[deleteUser\](/lua-scripting-api/api-reference-and-tips/classes/app/deleteuser.md): API \-  
return function()  
    local app \= getApp();  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    app.deleteUser(user); \--removes clonzeh's data.  
end

\- \[exportAvatarImage\](/lua-scripting-api/api-reference-and-tips/classes/app/exportavatarimage.md): API \-  
\-   
return function()  
    local app \= getApp();  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    \--path, filename, user, facingRight, animation, frameOfAnimation, left,right,top,bottom, scale  
    app.exportAvatarImage('', 'exportName', user, true, 'sit', 1, 20, 20, 20, 0, 1);   
    \--0.5 is the smallest possible size before it starts distorting image quality.  
    \--0.5,1,2,3,4 are the only possible scales for pixel perfect rendering.

    \--left,right,top,bottom is the padding/whitespace around the avatar.  
      
    \--examples for path are:  
      
    \--direct path on your PC:   (note: syntax of \[\[string\]\] ignores escaped characters \\ )  
    \--app.exportAvatarImage(\[\[C:\\Users\\your\_user\\Desktop\\avatar\_exports\]\], 'block\_man' ...   
      
    \--root folder of the script that is running this  
    \--app.exportAvatarImage('', 'blockman\_left\_idle', user, false, 'idle' ...  
      
    \--root folder of the script and creating subfolders  
    \--app.exportAvatarImage('exportImages/blockman', 'blockman\_sit' ...  
end  
\[translateCommand\](/lua-scripting-api/api-reference-and-tips/classes/app/translatecommand.md): API \- Used for getting the real translation settings of a command  
return function()  
    local app \= getApp();  
    local avatarCmd \= app.translateCommand('avatar');  
      
    log(avatarCmd); \--this will now be the user's custom input for the command\!  
    \--if the user changed the command fromn  avatar to character  
    \--it would log 'character')  
      
    \--this is useful for making a lua script that functions for users without worrying  
    \--about their settings  
end

# \# User

\# User

\- \[id {get}\](/lua-scripting-api/api-reference-and-tips/classes/user/id-get.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
    log(user.id); \--prints the ID of the user.  
    \--id is based on platform id \- is prefixed by platform letter code.  
    \--twitch has no platform character: 70349853  
    \--trovo example would be: T40930943908  
    \--youtube example would be Y34UG49034MN  
end

\- \[isActive {get}\](/lua-scripting-api/api-reference-and-tips/classes/user/isactive-get.md): API \-  
return function()  
    local app \= getApp();  
      
    local user \= app.getUserFromData('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
    if user.isActive \== false then  
        log('this users avatar is not actively spawned/alive');  
    end  
end

\- \[isFake {get}\](/lua-scripting-api/api-reference-and-tips/classes/user/isfake-get.md): API \- "fake" is an avatar spawned from other places than via your chatroom.  
return function()  
    local app \= getApp();  
      
    local user \= app.getUserFromData('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
    if user.isFake \== false then  
        log('this is an actual viewer.');  
    end  
end

\- \[lastActiveDate {get}\](/lua-scripting-api/api-reference-and-tips/classes/user/lastactivedate-get.md): API \-  
return function()  
    local app \= getApp();  
      
    local user \= app.getUserFromData('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    \-- string formatted  
    log(user.secondsSinceLastActive); \--the last date this avatar was spawned   
end

\- \[secondsSinceLastActive {get}\](/lua-scripting-api/api-reference-and-tips/classes/user/secondssincelastactive-get.md): API \-  
return function()  
    local app \= getApp();  
      
    local user \= app.getUserFromData('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    if user.secondsSinceLastActive \> 2592000 then \--2592000 \= 1 month in seconds  
        \--if the user last login is older than 1 month delete it...  
        app.deleteUser(user);  
    end  
     
end

\- \[displayName {get}\](/lua-scripting-api/api-reference-and-tips/classes/user/displayname-get.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
    log('user display name is: ' .. user.displayName);  
end

\- \[channelName {get}\](/lua-scripting-api/api-reference-and-tips/classes/user/channelname-get.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
    log('user channel name is: ' .. user.channelName); \--this will be an empty string if data is not available  
end

\- \[follower {get}\](/lua-scripting-api/api-reference-and-tips/classes/user/follower-get.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
    log('user is following: ' .. user.follower);  
end

\- \[vip {get}\](/lua-scripting-api/api-reference-and-tips/classes/user/vip-get.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
    log('user is a twitch vip: ' .. user.vip);  
end

\- \[subscriber {get}\](/lua-scripting-api/api-reference-and-tips/classes/user/subscriber-get.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
    log('user is subscribing: ' .. user.subscriber);  
end

\- \[moderator {get}\](/lua-scripting-api/api-reference-and-tips/classes/user/moderator-get.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
    log('user is a moderator: ' .. user.moderator);  
end

\- \[platformModerator {get}\](/lua-scripting-api/api-reference-and-tips/classes/user/platformmoderator-get.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
    log('user is a platform moderator: ' .. user.platformModerator );  
end

\- \[platform {get}\](/lua-scripting-api/api-reference-and-tips/classes/user/platform-get.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
    log('user is a from the platform: ' .. user.platform);  
end

\- \[streamer {get}\](/lua-scripting-api/api-reference-and-tips/classes/user/streamer-get.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
    log('user is the streamer: ' .. user.streamer);  
end

\- \[avatar {get;set}\](/lua-scripting-api/api-reference-and-tips/classes/user/avatar-get-set.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    log('user is currently using avatar: ' .. user.avatar);  
      
    user.avatar \= 'block\_man';  
end

\- \[scale {get;set}\](/lua-scripting-api/api-reference-and-tips/classes/user/scale-get-set.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    user.scale \= 2; \--the same as runCommand('\!scale ' .. user.id .. ' 2 60');  
      
    local getScaleValue \= user.scale;   
    log(getScaleValue); \--prints 2

    \--note this only refers to command\_scale\!  
      
    \--state\_scale is set by a state the avatar is running  
    \--global\_scale is set by the scale slider in quickaccess for all avatars  
    \--command\_scale is set by the command\_scale\!

    \--there is a 4th scale parameter which overrides all of these when set.  
end

\- \[override\\\_scale {get;set}\](/lua-scripting-api/api-reference-and-tips/classes/user/override\_scale-get-set.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    user.override\_scale \= 2; \--sets the avatars scale to 2 disregarding any other modifiers\!  
    \--this value will be reset upon restarting application.  
      
    \--to turn off the override scale, set it's value to \-1  
    \--warning: other commands or games might use this value and return it to \-1 upon finishing.  
end

\- \[color {get;set}\](/lua-scripting-api/api-reference-and-tips/classes/user/color-get-set.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    log('user\\'s avatar is currently using palette-color: ' .. user.color);  
      
    user.color= 'beige\_palette';  
end

\- \[nametag {get;set}\](/lua-scripting-api/api-reference-and-tips/classes/user/nametag-get-set.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    log('user is currently using nametag: ' .. user.nametag);  
      
    user.nametag= 'subOnly\_tag';  
end

\- \[getState\](/lua-scripting-api/api-reference-and-tips/classes/user/getstate.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    log(user.getState());  
end

\- \[getGear\](/lua-scripting-api/api-reference-and-tips/classes/user/getgear.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    local equippedGear \= user.getGear();  
    for key, value in pairs(equippedGear) do  
        log('wearing set: ' .. key .. ' piece: ' .. value);  
    end  
end

\- \[setGear\](/lua-scripting-api/api-reference-and-tips/classes/user/setgear.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    \--set, piece  
    user.setGear('hats', 'tophat'); \--user must have access to item  
end

\- \[setPosition\](/lua-scripting-api/api-reference-and-tips/classes/user/setposition.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
    local app \= getApp();  
    local p \= app.convertPercentToPosition(0.5, 0.5); \--center of the screen  
    user.setPosition(p.x,p.y);  
      
    wait(3);  
      
    user.setPosition(0, 800); \--center x but really high up on y  
end

\- \[getPosition\](/lua-scripting-api/api-reference-and-tips/classes/user/getposition.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end

    local currentPosition \= user.getPosition();  
    log('the avatar is currently at position: ' .. currentPosition.x .. ', ' .. currentPosition.y);  
end

\- \[getWearableAvatars\](/lua-scripting-api/api-reference-and-tips/classes/user/getwearableavatars.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    \--gets all available avatars to the user  
    local availAvatars \= user.getWearableAvatars();  
      
    local str \= '';  
    for key, value in pairs(availAvatars) do  
        str \= str .. value .. ', ';  
    end  
      
    log('available avatars are: ');  
    log(str);  
      
end

\- \[getWearableAvatarColors\](/lua-scripting-api/api-reference-and-tips/classes/user/getwearableavatarcolors.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    \--checks available colors the user has on specified avatar: block\_man  
    local availColors \= user.getWearableAvatarColors('block\_man');  
      
    local str \= '';  
    for key, value in pairs(availColors) do  
        str \= str .. value .. ', ';  
    end  
      
    log('block\_man options for colors are: ');  
    log(str);  
      
end

\- \[getWearableGearSetPieces\](/lua-scripting-api/api-reference-and-tips/classes/user/getwearablegearsetpieces.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    \--checks available pieces the user on specified gear set: hats  
    local availGearSetPieces \= user.getWearableGearSetPieces('hats');  
      
    local str \= '';  
    for key, value in pairs(availGearSetPieces) do  
        str \= str .. value .. ', ';  
    end  
      
    log('available gear set pieces for hats are: ');  
    log(str);  
      
end

\- \[getWearableNametags\](/lua-scripting-api/api-reference-and-tips/classes/user/getwearablenametags.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    \--checks available nametags the user has  
    local availNametags \= user.getWearableNametags();  
      
    local str \= '';  
    for key, value in pairs(availNametags ) do  
        str \= str .. value .. ', ';  
    end  
      
    log('available nametags are: ');  
    log(str);  
      
end

\- \[setTemporaryAvatar\](/lua-scripting-api/api-reference-and-tips/classes/user/settemporaryavatar.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
      
    user.setTemporaryAvatar('random', 30); \--random and none works here  
    \--sets a temporary avatar regardless of user's ownership/statuses for 30 seconds  
      
    wait(1);  
      
    user.setTemporaryAvatar('block\_man', 120);  
      
    wait(1);  
      
    user.setTemporaryAvatar('block\_man', 1);   
    \--best way to remove the temporaryAvatar \-   
    \--reset the timer to 1 so it ticks off right away.  
      
    wait(1);  
      
     user.setTemporaryAvatar('block\_man', 0);   
     \--0 lasts until application restart or until set to a different timer.  
end

\- \[setTemporaryColor\](/lua-scripting-api/api-reference-and-tips/classes/user/settemporarycolor.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
      
    user.setTemporaryColor('random', 30); \--random and none works here  
    \--sets a temporary avatar regardless of user's ownership/statuses for 30 seconds  
      
    wait(1);  
      
    user.setTemporaryColor('blue', 120);  
      
    wait(1);  
      
    user.setTemporaryColor('blue', 1);   
    \--best way to remove the temporaryAvatar \-   
    \--reset the timer to 1 so it ticks off right away.  
      
    wait(1);  
      
     user.setTemporaryColor('blue', 0);   
     \--0 lasts until application restart or until set to a different timer.  
end

\- \[setTemporaryNametag\](/lua-scripting-api/api-reference-and-tips/classes/user/settemporarynametag.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
      
    user.setTemporaryNametag('random', 30); \--random and none works here  
    \--sets a temporary avatar regardless of user's ownership/statuses for 30 seconds  
      
    wait(1);  
      
    user.setTemporaryNametag('subOnlyTag', 120);  
      
    wait(1);  
      
    user.setTemporaryNametag('subOnlyTag', 1);   
    \--best way to remove the temporaryAvatar \-   
    \--reset the timer to 1 so it ticks off right away.  
      
    wait(1);  
      
     user.setTemporaryNametag('subOnlyTag', 0);   
     \--0 lasts until application restart or until set to a different timer.  
end

\- \[setTemporaryGear\](/lua-scripting-api/api-reference-and-tips/classes/user/settemporarygear.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
      
    user.setTemporaryGear('random', 'random', 30); \--random and none works here  
    \--random and none keywords are based on language setting   \--sets a temporary avatar regardless of user's ownership/statuses for 30 seconds  
      
    wait(1);  
      
    user.setTemporaryNametag('hat', 'tophat', 120);  
      
    wait(1);  
      
    user.setTemporaryNametag('hat', 'tophat', 1);   
    \--best way to remove the temporaryAvatar \-   
    \--reset the timer to 1 so it ticks off right away.  
      
    wait(1);  
      
     user.setTemporaryNametag('hat', 'tophat', 0);   
     \--0 lasts until application restart or until set to a different timer.  
end

\- \[setTemporaryNone\](/lua-scripting-api/api-reference-and-tips/classes/user/settemporarynone.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    user.setTemporaryNone(30); \--Sets color and gear items to none  
end

\- \[clearAllTemporarySelections\](/lua-scripting-api/api-reference-and-tips/classes/user/clearalltemporaryselections.md): API \-  
For emotes on twitch to display, they must first be read from chat before they can be used in chat bubble. For example 'kappa' will use the kappa emote only if someone has previously types Kappa into chat.  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
    \--clears all temporary selections for avatar, color, gear, and nametags  
    user.clearAllTemporarySelections();   
end

\- \[chatBubble\](/lua-scripting-api/api-reference-and-tips/classes/user/chatbubble.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end

    user.chatBubble('this is going display above the avatar\\'s head\!');  
end

\- \[look\](/lua-scripting-api/api-reference-and-tips/classes/user/look.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end

    user.look(1); \--changes avatar's facing direction to be right  
    user.look(-1); \-- ... changes ... left  
end

\- \[runCommand\](/lua-scripting-api/api-reference-and-tips/classes/user/runcommand.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end

    user.runCommand('\!jump'); \--tells the user's avatar to jump  
end

\- \[physics\](/lua-scripting-api/api-reference-and-tips/classes/user/physics.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    \--x, y  
    user.physics.setVelocity(0, 300); \--throws the avatar upwards\!  
    wait(1);  
    log(user.physics.grounded); \--should log false because we're not touching the ground  
      
    user.physics.grounded \= true; \--temporarily sets grounded to true  
    \--but it will update back to false if it's not actually grounded.  
end

\- \[saveUserData\](/lua-scripting-api/api-reference-and-tips/classes/user/saveuserdata.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    local mData \= {};  
    mData.test \= 5;  
    mData.testa \= 'hi';  
    mData.testb \= {};  
    mData.testb.a \= 4;  
    user.saveUserData('custom name', mData);   
    \--A quick and easy way to store data on a specific user\!  
      
    \--This can also be useful for using similar data for multiple scripts.  
      
    \--make sure to look at loadUserData\!  
end

\- \[loadUserData\](/lua-scripting-api/api-reference-and-tips/classes/user/loaduserdata.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    local mData \= user.loadUserData('custom name');  
    if mData \~= nil then   
          
        \--make sure to look at docs for saveUserData to know how to make data exist\!  
          
        local str \= json.serialize(mData); \--this prints what the data looks like.  
        log(str);  
          
        \--example of using the data:  
        log(mData.test); \--if you use the saveUserData example, this will print 5  
    else  
        log('the user data does not exist\!');  
    end  
end

# \# Physics

\# Physics

\- \[grounded {get;set}\](/lua-scripting-api/api-reference-and-tips/classes/physics/grounded-get-set.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end

    log(user.physics.grounded);  
    \--detects whether the avatar is on the ground or not.  
      
    user.physics.grounded \= true; \--temporarily sets grounded to true  
    \--but it will update back to false if it's not actually grounded.  
end

\- \[setVelocity\](/lua-scripting-api/api-reference-and-tips/classes/physics/setvelocity.md): API \-  
return function()  
    local user \= getUser('clonzeh');  
    if user \== nil then  
        log('user does not exist\!');  
        return;  
    end  
      
    \--x, y  
    user.physics.setVelocity(0, 300); \--throws the avatar upwards\!  
end

# \# ObjectPhysics

\# ObjectPhysics

\- \[hasTrigger {get}\](/lua-scripting-api/api-reference-and-tips/classes/objectphysics/hastrigger-get.md): API \-  
function yourEvent(user, object, eventType)  
    if user \~= nil then  
        if eventType \== 'enter' then  
            log(user.displayName .. 'entered');  
        end  
        if eventType \== 'exit' then  
            log(user.displayName .. 'exited');  
        end  
    else  
        if eventType \== 'mouseEntered' then  
        end  
        if eventType \== 'mouseExited' then  
        end  
        if eventType \== 'mouseDown' then  
        end  
        if eventType \== 'mouseUp' then  
        end  
     end  
end

return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();  
    wait(3);  
    myObject.physics.addBoxTrigger();  
    myObject.physics.mouseTrigger \= true; \--enables mouse tracking on object  
    log(myObject.physics.hasTrigger);  
      
    app.addEvent('triggerObject', 'yourEvent');  
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

\- \[hasRigidBody {get}\](/lua-scripting-api/api-reference-and-tips/classes/objectphysics/hasrigidbody-get.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();  
    wait(3);  
    myObject.physics.addBoxTrigger();  
    myObject.physics.hasRigidBody \= true; \--creates a rigidbody on the object.  
      
    log(myObject.physics.hasRigidBody);  
      
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

\- \[layer {get;set}\](/lua-scripting-api/api-reference-and-tips/classes/objectphysics/layer-get-set.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();  
    wait(3);  
    myObject.physics.addBoxCollider();  
    myObject.physics.hasRigidBody \= true; \--creates a rigidbody on the object.  
      
    myObject.physics.layer \= 'ground+avatars';  
    \--myObject.physics.layer \= 'ground';  
    \--myObject.physics.layer \= 'unique';  
      
    log(myObject.physics.hasRigidBody);  
      
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

\- \[kinemetic {get;set}\](/lua-scripting-api/api-reference-and-tips/classes/objectphysics/kinemetic-get-set.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();  
    wait(3);  
    myObject.physics.addBoxCollider();  
    myObject.physics.hasRigidBody \= true; \--creates a rigidbody on the object.  
    myObject.physics.layer \= 'unique';  
      
    myObject.physics.kinemetic \= true;  
    \--other objects that are not kinemetic will treat this object as static  
    \--for the unique layer  
      
    log(myObject.physics.hasRigidBody);  
      
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

\- \[setVelocity\](/lua-scripting-api/api-reference-and-tips/classes/objectphysics/setvelocity.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();  
    wait(3);  
    myObject.physics.hasRigidBody \= true;  
    myObject.physics.addBoxCollider();  
    myObject.physics.setVelocity(0, 100);  
      
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

\- \[addBoxCollider\](/lua-scripting-api/api-reference-and-tips/classes/objectphysics/addboxcollider.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();  
    wait(3);  
    myObject.physics.hasRigidBody \= true;  
    myObject.physics.addBoxCollider();  
    keepAlive();  
end  
\- \[addCircleCollider\](/lua-scripting-api/api-reference-and-tips/classes/objectphysics/addcirclecollider.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();  
    wait(3);  
    myObject.physics.hasRigidBody \= true;  
    myObject.physics.addCircleCollider();  
    keepAlive();  
end

\- \[addBoxTrigger\](/lua-scripting-api/api-reference-and-tips/classes/objectphysics/addboxtrigger.md): API \-  
function yourEvent(user, object, eventType)  
    if user \~= nil then  
        if eventType \== 'enter' then  
            log(user.displayName .. 'entered');  
        end  
        if eventType \== 'exit' then  
            log(user.displayName .. 'exited');  
        end  
    else  
        if eventType \== 'mouseEntered' then  
        end  
        if eventType \== 'mouseExited' then  
        end  
        if eventType \== 'mouseDown' then  
        end  
        if eventType \== 'mouseUp' then  
        end  
     end  
end

return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();  
    wait(3);  
    myObject.physics.addBoxTrigger();  
    app.addEvent('triggerObject', 'yourEvent');  
    keepAlive();  
end

\- \[addCircleTrigger\](/lua-scripting-api/api-reference-and-tips/classes/objectphysics/addcircletrigger.md): API \-  
function yourEvent(user, object, eventType)  
    if user \~= nil then  
        if eventType \== 'enter' then  
            log(user.displayName .. 'entered');  
        end  
        if eventType \== 'exit' then  
            log(user.displayName .. 'exited');  
        end  
    else  
        if eventType \== 'mouseEntered' then  
        end  
        if eventType \== 'mouseExited' then  
        end  
        if eventType \== 'mouseDown' then  
        end  
        if eventType \== 'mouseUp' then  
        end  
     end  
end

return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();  
    wait(3);  
      
    myObject.physics.addCircleTrigger();  
    app.addEvent('triggerObject', 'yourEvent');  
    keepAlive();  
end

# \# Avatar

\# Avatar

\- \[name {get}\](/lua-scripting-api/api-reference-and-tips/classes/avatar/name-get.md): API \-  
return function()  
    local avatar \= getAvatar('block\_man');  
    if avatar \== nil then  
        log('the avatar was not found');  
        return;  
    end  
      
    log(avatar.name);  
end

\- \[getGear\](/lua-scripting-api/api-reference-and-tips/classes/avatar/getgear.md): API \-  
return function()  
    local avatar \= getAvatar('block\_man');  
    if avatar \== nil then  
        log('the avatar was not found');  
        return;  
    end  
      
    local gear \= avatar.getGear();   
    \--returns a list of gear that's attached to the avatar  
      
    local str \= '';  
    for key, value in pairs(gear) do  
        str \= str \+ value \+ ', ';  
    end  
    log(avatar.name .. ' has these gear sets available:');  
    log(str);  
end

\- \[getGearPieces\](/lua-scripting-api/api-reference-and-tips/classes/avatar/getgearpieces.md): API \-  
return function()  
    local avatar \= getAvatar('block\_man');  
    if avatar \== nil then  
        log('the avatar was not found');  
        return;  
    end  
      
    local gearPieces \= avatar.getGearPieces('hats');   
    \--returns a list of gear items that's from the gear set  
      
    local str \= '';  
    for key, value in pairs(gearPieces) do  
        str \= str \+ value \+ ', ';  
    end  
    log(avatar.name .. ' has these gear pieces available:');  
    log(str);  
end

\- \[getColors\](/lua-scripting-api/api-reference-and-tips/classes/avatar/getcolors.md): API \-  
return function()  
    local avatar \= getAvatar('block\_man');  
    if avatar \== nil then  
        log('the avatar was not found');  
        return;  
    end  
      
    local colors \= avatar.getColors();   
    \--returns a list of color palettes that's attached to the avatar  
      
    local str \= '';  
    for key, value in pairs(colors) do  
        str \= str \+ value \+ ', ';  
    end  
    log(avatar.name .. ' has these colors palettes available:');  
    log(str);  
end

\- \[getActions\](/lua-scripting-api/api-reference-and-tips/classes/avatar/getactions.md): API \-  
return function()  
    local avatar \= getAvatar('block\_man');  
    if avatar \== nil then  
        log('the avatar was not found');  
        return;  
    end  
      
    local actions \= avatar.getActions();   
    \--returns a list of actions/animations that's attached to the avatar  
      
    local str \= '';  
    for key, value in pairs(actions) do  
        str \= str \+ value \+ ', ';  
    end  
    log(avatar.name .. ' has these actions available:');  
    log(str);  
end

# \# GameObject

\# GameObject

\- \[image {get}\](/lua-scripting-api/api-reference-and-tips/classes/gameobject/image-get.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();  
    applyImage(myObject, 'imageName');  
      
    myObject.image.flipX();  
    wait(1);  
    myObject.image.flipX();  
      
end

\- \[destroy\](/lua-scripting-api/api-reference-and-tips/classes/gameobject/destroy.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();  
    wait(3);  
    myObject.destroy();  
      
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

\- \[setAngle\](/lua-scripting-api/api-reference-and-tips/classes/gameobject/setangle.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();

    myObject.setAngle(90); \--rotates clockwise on it's side 90 degrees.  
      
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

\- \[setPosition\](/lua-scripting-api/api-reference-and-tips/classes/gameobject/setposition.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();  
    wait(3);  
      
    local pos \= app.convertPercentToPosition(0.5, 0.5);  
    myObject.setPosition(pos.x, pos.y);   
    \--places the object in the center of the screen  
      
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

\- \[getPosition\](/lua-scripting-api/api-reference-and-tips/classes/gameobject/getposition.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createObject();  
    wait(3);  
      
    local pos \=  myObject.getPosition(pos.x, pos.y);   
    log(pos.x .. ', ' .. pos.y);  
      
      
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

\- \[adjustPosition\](/lua-scripting-api/api-reference-and-tips/classes/gameobject/adjustposition.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createObject();  
    wait(3);  
      
    local pos \= app.convertPercentToPosition(0, 0.5);  
    myObject.setPosition(pos.x, pos.y);   
    \--places the object in the center-left of the screen  
    local speed \= 5;  
    while true do  
        local deltaTime \= yield(); \--deltaTime is seconds between frames.  
        pos \= myObject.getPosition();  
          
        if pos.x \> 500 then  
            yieldBreak();  
        end  
          
        myObject.adjustPosition(deltaTime \* speed, 0);   
        \--moves the object to the right by 5units per second.  
    end  
      
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

\- \[getScale\](/lua-scripting-api/api-reference-and-tips/classes/gameobject/getscale.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createObject();  
    wait(3);  
      
    local scale \=  myObject.getScale();   
    log(scale.x .. ', ' .. scale.y);  
      
      
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

\- \[setScale\](/lua-scripting-api/api-reference-and-tips/classes/gameobject/setscale.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createObject();  
    wait(3);  
      
    myObject.setScale(2, 2);   
      
      
      
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

\- \[adjustScale\](/lua-scripting-api/api-reference-and-tips/classes/gameobject/adjustscale.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createObject();  
    wait(3);  
      
    myObject.adjustScale(0.5, 0.5);   
    myObject.adjustScale(0.5, 0.5); \--additive  
      
      
      
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

\- \[physics\](/lua-scripting-api/api-reference-and-tips/classes/gameobject/physics.md): API \-  
return function()  
    local app \= getApp();  
    local myObject \= app.createGameObject();  
    wait(3);  
    myObject.physics.hasRigidBody \= true;  
    myObject.physics.addBoxCollider();  
    myObject.physics.setVelocity(0, 100);  
      
    \--as soon as the script ends the object will be destroyed automatically.  
    keepAlive();  
end

# \# Image

\# Image

\- \[playAnimation\](/lua-scripting-api/api-reference-and-tips/classes/image/playanimation.md): API \-  
You must first create an image for it to be applied\! Check applyImage below for examples.return function()  
    local app \= getApp();  
    local ob \= app.createGameObject(); \--create object to attach images to  
    applyImage(ob, 'welcomeImage'); \--add the image titled 'welcome' to the object  
      
    ob.image.anchor('center', true);   
    \--anchors the image to the center of the screen...  
    wait (0.2);  
      
    ob.image.stopAnimation();  
      
    wait(3);  
      
    ob.image.playAnimation();  
    \--if the image is an animated one, it will begin animating.  
    \--animated images play automatically when using applyImage()  
end

\- \[stopAnimation\](/lua-scripting-api/api-reference-and-tips/classes/image/stopanimation.md): API \-  
return function()  
    local app \= getApp();  
    local ob \= app.createGameObject(); \--create object to attach images to  
    applyImage(ob, 'welcomeImage'); \--add the image titled 'welcome' to the object  
      
    ob.image.anchor('center', true);   
    \--anchors the image to the center of the screen...  
      
    ob.image.stopAnimation();  
    \--if the image is an animated one, it will pause animating.  
end

\- \[flipX\](/lua-scripting-api/api-reference-and-tips/classes/image/flipx.md): API \-  
return function()  
    local app \= getApp();  
    local ob \= app.createGameObject(); \--create object to attach images to  
    applyImage(ob, 'welcomeImage'); \--add the image titled 'welcome' to the object  
      
    ob.image.anchor('center', true);   
    \--anchors the image to the center of the screen...  
      
    ob.image.flipX(); \--image should now be flipped on the x Axis  
end

\- \[flipY\](/lua-scripting-api/api-reference-and-tips/classes/image/flipy.md): API \-  
return function()  
    local app \= getApp();  
    local ob \= app.createGameObject(); \--create object to attach images to  
    applyImage(ob, 'welcomeImage'); \--add the image titled 'welcome' to the object  
      
    ob.image.anchor('center', true);   
    \--anchors the image to the center of the screen...  
      
    ob.image.flipY(); \--image should now be flipped on the y Axis  
end

\- \[sorting\](/lua-scripting-api/api-reference-and-tips/classes/image/sorting.md): API \-  
return function()  
    local app \= getApp();  
    local ob \= app.createGameObject(); \--create object to attach images to  
    applyImage(ob, 'welcomeImage'); \--add the image titled 'welcome' to the object  
      
    ob.image.anchor('center', true);   
    \--anchors the image to the center of the screen...  
      
    ob.image.sorting(-1000, 'background');   
    \--sets the image's layer to be on the background (behind everything)  
    \--with the sorting order of \-1000 (behind objects greater than \-1000)  
end

\- \[anchor\](/lua-scripting-api/api-reference-and-tips/classes/image/anchor.md): API \-  
available options are: bottom left, bottom right, top left, top right, center, left, right  
return function()  
    local app \= getApp();  
    local ob \= app.createGameObject(); \--create object to attach images to  
    applyImage(ob, 'welcomeImage'); \--add the image titled 'welcome' to the object  
      
    ob.image.anchor('bottom left', true);   
    \--anchors the image to the bottom left of the screen,   
    \--true refers to accounting for image dimensions  
    \--to make sure it reamins completely on the screen

end

# \# ScriptableBlock

\# ScriptableBlock

\- \[id {get}\](/lua-scripting-api/api-reference-and-tips/classes/scriptableblock/id-get.md): API \-  
function yourEvent(user, block)

    log('block hit by avatar\! block id is:' .. block.id);  
      
end  
   
return function()  
    addEvent('scriptableBlocks', 'yourEvent'); \--attaches the event to yourEvent()  
    keepAlive(); \--this is needed.  
end

\- \[position\](/lua-scripting-api/api-reference-and-tips/classes/scriptableblock/position.md): API \-  
function yourEvent(user, block)

    log('block hit by avatar\! block position is:' .. block.position);  
      
end  
   
return function()  
    addEvent('scriptableBlocks', 'yourEvent'); \--attaches the event to yourEvent()  
    keepAlive(); \--this is needed.  
end

# Tab 12

\# Helper Class

\- \[createCooldown\](/lua-scripting-api/api-reference-and-tips/helper-class/createcooldown.md): API \-  
function tryToUseCooldown()

    local cd\_ready \= helper.checkCooldown('myCd');  \--works with coroutines  
    \--this accounts for the cd variable being from another coroutine.  
      
    local cd\_timeLeft \= helper.cooldownTimeLeft('myCd'); \--works with coroutines  
      
      
    if cd\_ready \== false then  
        log('you can\\'t use this yet... until another ' .. cd\_timeLeft .. ' seconds has passed');  
        return;  
    end  
      
    log('it worked. now consume the cooldown.');  
      
    helper.setCooldown('myCd'); \--works with coroutines  
    \--set it on cooldown for the 15 seconds again...  
end

myCd \= {}; \-- global variable;

return function()

    myCd \= helper.createCooldown(16, true);   
    \--create a new cooldown for 15 seconds, and it starts as ready \= true  
    \--the name of the global variable is   
      
    tryToUseCooldown(); \-- it worked\!  
    tryToUseCooldown(); \-- can't use this yet...  
    wait(16);  
    tryToUseCooldown(); \-- it worked\!  
end

\- \[checkCooldown\](/lua-scripting-api/api-reference-and-tips/helper-class/checkcooldown.md): API \-  
function tryToUseCooldown()

    local cd\_ready \= helper.checkCooldown('myCd');  \--works with coroutines  
    \--this accounts for the cd variable being from another coroutine.  
      
    local cd\_timeLeft \= helper.cooldownTimeLeft('myCd'); \--works with coroutines  
      
      
    if cd\_ready \== false then  
        log('you can\\'t use this yet... until another ' .. cd\_timeLeft .. ' seconds has passed');  
        return;  
    end  
      
    log('it worked. now consume the cooldown.');  
      
    helper.setCooldown('myCd'); \--works with coroutines  
    \--set it on cooldown for the 15 seconds again...  
end

myCd \= {}; \-- global variable;

return function()

    myCd \= helper.createCooldown(16, true);   
    \--create a new cooldown for 15 seconds, and it starts as ready \= true  
    \--the name of the global variable is   
      
    tryToUseCooldown(); \-- it worked\!  
    tryToUseCooldown(); \-- can't use this yet...  
    wait(16);  
    tryToUseCooldown(); \-- it worked\!  
end

\- \[setCooldown\](/lua-scripting-api/api-reference-and-tips/helper-class/setcooldown.md)  
\-   
function tryToUseCooldown()

    local cd\_ready \= helper.checkCooldown('myCd');  \--works with coroutines  
    \--this accounts for the cd variable being from another coroutine.  
      
    local cd\_timeLeft \= helper.cooldownTimeLeft('myCd'); \--works with coroutines  
      
      
    if cd\_ready \== false then  
        log('you can\\'t use this yet... until another ' .. cd\_timeLeft .. ' seconds has passed');  
        return;  
    end  
      
    log('it worked. now consume the cooldown.');  
      
    helper.setCooldown('myCd'); \--works with coroutines  
    \--set it on cooldown for the 15 seconds again...  
end

myCd \= {}; \-- global variable;

return function()

    myCd \= helper.createCooldown(16, true);   
    \--create a new cooldown for 15 seconds, and it starts as ready \= true  
    \--the name of the global variable is   
      
    tryToUseCooldown(); \-- it worked\!  
    tryToUseCooldown(); \-- can't use this yet...  
    wait(16);  
    tryToUseCooldown(); \-- it worked\!  
end  
\[cooldownTimeLeft\](/lua-scripting-api/api-reference-and-tips/helper-class/cooldowntimeleft.md): API \-  
function tryToUseCooldown()

    local cd\_ready \= helper.checkCooldown('myCd');  \--works with coroutines  
    \--this accounts for the cd variable being from another coroutine.  
      
    local cd\_timeLeft \= helper.cooldownTimeLeft('myCd'); \--works with coroutines  
      
      
    if cd\_ready \== false then  
        log('you can\\'t use this yet... until another ' .. cd\_timeLeft .. ' seconds has passed');  
        return;  
    end  
      
    log('it worked. now consume the cooldown.');  
      
    helper.setCooldown('myCd'); \--works with coroutines  
    \--set it on cooldown for the 15 seconds again...  
end

myCd \= {}; \-- global variable;

return function()

    myCd \= helper.createCooldown(16, true);   
    \--create a new cooldown for 15 seconds, and it starts as ready \= true  
    \--the name of the global variable is   
      
    tryToUseCooldown(); \-- it worked\!  
    tryToUseCooldown(); \-- can't use this yet...  
    wait(16);  
    tryToUseCooldown(); \-- it worked\!  
end

\- \[startsWith\](/lua-scripting-api/api-reference-and-tips/helper-class/startswith.md): API \-  
return function  
    local val \= 'hello';  
    val \= helper.startsWith(val, 'he');  
    log(val); \--logs true  
end

\- \[replace\](/lua-scripting-api/api-reference-and-tips/helper-class/replace.md): API \-  
return function  
    local val \= 'hello';  
    val \= helper.replace(val, 'o', '8');  
    log(val); \--logs hell8  
end

\- \[split\](/lua-scripting-api/api-reference-and-tips/helper-class/split.md): API \-  
function yourEvent(user, string\_message)

    local words \= helper.split(string\_message, ' ');   
    \--this is extremely helpful for bots that are trying to read commands\!  
    \--split the message on spaces to get words in an array  
      
    \--check the first word  
    if words\[1\] \~= '\!yourCommand' then \--in LUA... arrays start at index 1, not 0\!  
          
        \--if word\[1\] is not equal to your command, exit.  
        yieldBreak();  
    end  
      
    if words\[2\] \== 'start' then  
        log('the user has typed: \!yourCommand start');  
    end  
end

return function()  
    addEvent('chatMessage', 'yourEvent'); \--attaches the event to yourEvent()  
    keepAlive();  
end

\- \[randomElement\](/lua-scripting-api/api-reference-and-tips/helper-class/randomelement.md): API \-  
return function  
    local values \= { 'word1', 'word2', 'word3'};  
    local test \= helper.randomElement(values);  
    log(test);   
    \--this will log a random string from values. It could be word1, word2, or word3  
end

\- \[hasValue\](/lua-scripting-api/api-reference-and-tips/helper-class/hasvalue.md): API \- useful for checking if an array contains a value  
return function  
    local values \= { 'word1', 'word2', 'word3'};  
      
    local test \= helper.hasValue(values, 'word1');  
      
    if test \== true then  
        log('values does contain word1');  
    else  
        log('values does not contain word1');  
    end

end

\- \[matchRegex\](/lua-scripting-api/api-reference-and-tips/helper-class/matchregex.md): API \- useful for checking if an array contains a value  
return function  
    local msg1 \= 'a.ab';  
    local msg2 \= 'aa.a';  
      
    local pattern \=(?\<=\[a-zA-Z0-9\#%-\_+=\])(\[.\])(?=\[a-zA-Z\]{2,})';  
      
    \--the pattern first checks for a letter or number before a period  
    \--then checks for two consecutive letters after a period  
      
    local match1 \= helper.matchRegex(pattern , msg1);  
    local match2 \= helper.matchRegex(pattern , msg2);  
      
    log(match1); \--true  
    log(match2); \--false

end

