In this document, we will write down each step of the progress we’ve made on the project. 

 

Our plan is to make a website that is accessible through mobile phones. It is a website designed to add a little bit of variety and fun activities to guests and students at the school. We plan to add minigames in between so that kids are encouraged to participate. But it also serves purpose so that admins can see feedback that the students have anonymously written. 

 

Day1 we prompted our plan to the AI and made a demo version of what we want our project to look like so that we can showcase it to Tiina. It has a guest side where the students can play bingo games and other minigames and give feedback. The admin side has the ability to make new events and edit them. They run with Flutter and have a SQLite database. We also made an API folder. 

 

Day3 we had a meeting with Tiina and talked about certain details on the project. For the bingo board, we have to make sure the boxes fit well with mobile phones and that the text is eligible. The quiz questions cannot be abbreviated, and simple words must be used since the demographic is teen kids. The bingo board can still use abbreviations if necessary to fit the boxes. One suggestion for minigames was “connect the words”. Feedback must be emojis only. Where we store the feedback is yet to be determined, since Tiina would like to access them easily and be able to share them around with other staff. We spoke about color themes and will most likely be using SASKYs official colors. Trivia could have pictures too. 

I was thinking maybe the minigames shouldn’t be too attention demanding since she meant the web page to be used simultaneously as she or a different person is presenting.  

 

Day4 we pondered about how the guest side and admin side would communicate and how it would have to be on a server to be able to communicate with each other. We decided to ask Pirkko about it at our next meeting. For now, we worked on the first minigame; memory card flip game. We were having issues with the Agent not doing what we wanted it to do. It claimed to be doing things but in reality, it was doing empty codes. So, we swapped from GPT-4o to Claude Haiku 4.5, and it instantly understood us better and did what we wanted it to do. We also swapped feedback to 5 emojis and not text. Now both the minigame and the feedback emojis work. 

 

Day5 we added a MineSweeper game and win/lose popup screens to all the minigames that direct you to the next step. Also fixed the issue where if you won a game and picked a box that gives you a bingo, it didn't tell you that you got a bingo. 

 

Day6 we added a SpinTheWheel roulette with 2 colors. It asks first the user for their guess on which color the arrow will land on, and then you can spin the wheel. We also added a BottleOrder game, where it gives you 5 bottles, and you must guess the order the AI chooses, within 3 tries.  

 

Day7 We had some issues with the hidden order not being very hidden and the checkmarks on the correct positions being revealed before the guest submits the attempt, but we fixed those. We had to fix the spinning wheel multiple times because the solutions were inverted; you pick red, it lands on red, you lose, and it says it landed on blue. 

 

Day8 We brainstormed how to make the minigames match the sasky theme: dark blue and pink. We came up with some questions to ask Pirkko. Also formatted the guest side to look better on mobile phones. On the admin side, we fixed the box and text sizing for the customizable bingo board, and added a preview for the bingo board. For now it still doesn't save the new bingo boards. 

Did some color searching blue is #3b4b6b pink is #ff9eb3 HEX  

 

Day9 We talked with Pirkko and talked about the where the project would be running. The opinion was that we have enough mini games, and now it would be good to work on running the project on Docker. Allegedly, you can have multiple Dockerfiles in the same project. Another opinion was that the database location would probably be better on the admin side. QR code generator on maybe admin side? We made a dockerfile for both admin and guest side, and containers. No data exchange yet. 

 

Day10 We tried working on the API side. But due to Antigravity having high traffic with their Agents, we weren’t able to make much progress. Since it’s a quite complicated process connecting the logic between the guest side and admin side and we didn’t have AI or a teacher to help, we decided to continue on the next session. 

 

Day11 No progress. We tried fixing the database issue with the admin side, but it didn’t work and AI didn’t help. On some parts it said it’s a Flutter connectivity issue. The database needs to exist as a docker volume so that the data doesn’t get wiped or lost. But so far it hasn’t worked successfully.  

 

Day12 Still no progress. The database still wipes all the information. We tried doing it from scratch multiple times, even changed to raw SQLite since the AI was doing some ef CORS stuff.  

 

Day 13 No progress. 

 

Day14 After our conversation with Pirkko we tried prompting Mount Binding. We finally got some progress done and now it seems like the data does get stored, and it doesn’t disappear once you reload. 

 

Day15 We tried implementing the same saving logic to the new Bingo boards made, but they don’t persist yet. 

 

Day16 We continued with the bingo board database and api implementation. We got it to work to a point where you can create new boards and also edit already existing ones. Deletion doesn't work yet. 

 

Day17 We worked on our separate branches trying to get the bingo boards to save and persist. In the end, a lot of the issues and roadblocks were because of the browser cache. We got the Arx branch working, but it's still mixed with EF Core Migrations. Meanwhile Veronicas branch is cleaner, but she reached her monthly Agent Quota, and it's still needing a little bit of work. 

 

Day18 Database now works purely on raw SQLite, and the EF Core Migration files were removed. The SQLite lives in its own file called DatabaseInitializer.cs. We also made the Welcome tab, Minigames tab, and Events tab work with the database so now the tabs have functionality. The event packages now have a preview button so that the admin can see what the package looks like. 

 

Day 19 We added question packages aka trivia to the game. They behave the same way mini games do. They appear on the bingo board once you check 3 boxes. You can also create custom ones. 

 

Day20 You can now create custom question packages, with a minimum of 3 questions. At some point in the code, the free pick view on the bingo board became scrollable and cropped, so we adjusted that. 

 

Day 23 We created images in .tar files to transfer the project onto the school server. We fixed an issue we had with the curl command in the docker compose yml, and now the API container is healthy. We need to work further to fix the issue between the admin containers connection with the API container. 

 

Day 24 Second day at school trying to get the API connection to work between the containers. We tried changing the code in the dart files from localhost to the school server IP address, but it didn’t work so we went back to localhost but now it’s using nginx. 

 

Day25 We changed the code so that it doesn’t read any localhost but goes straight to the relevant uri eg. admin and API work now together. The images are pushed into the Docker Hub and the containers read the images from there. 

 

Day26 We swapped colors of the games and the preview UI so that it matches the sasky colors. The memory game emojis have also been swapped for emojis matching the degrees you can study in Tampere. 

 

Day27 Guest side now also communicates. The admin “publishes” event packages, and the guest side only sees that package. The guest feedback now gets sent to the admin feedback tab, and it groups the feedback based on event packages and shows the overall satisfaction with bars and charts. Fixed a minor issue where if the guest failed to answer even the first question of question packages correctly, then it took them back to the board. Now the user must answer 3 questions for educational purpose.  

 

Day28 We added a section to the Event packages, where it shows which package has been published, the date of the publish, and the QR-code that leads you to the guest side. The second thing we added is admin login, so that it’s more secure. 

 

Day29 Had a meeting with Tiina and wrote down things she wanted to change. 

 

Day30 We added a log out button for the admin, and Master admin that can add and delete more admin accounts. Also added 3 more trivia packages per Tiina’s request. Yet to be merged, since the trivia packages cannot be deleted successfully yet. 

 

Day31 We physically went to school to move the project to the school servers using linux putty. The admin works now but it has no connection to the api, since we havent moved that there yet.  

 

Day32 In Veronicas branch, the question packages removal works now. We worked on figuring out how to move the api to the school server. 

 

Day33 Still tried figuring out the api situation but since we can’t test it from home, we have to wait and see until Friday at school if it works or not. 

 

Day34 We continued on the api at school. New hrfd path being /bingo/admin. Next step on monday is to finish downloading the dotnet on linux and running dotnet run –urls “ ip address:5000” in the api folder. 

 

Day35 We managed to get dotnet 9.0 and 10.0 installed on the linux, also aspnet. Rebuilt admin and guest to build on /bingo/admin/ and /bingo/guest/. We created a service file so that the api can run in the background. Now all api, admin and guest work. The only issue being that their communication is not working correctly. They’re talking but it’s only doing get, no post. So next is to fix the case-sensitivity on auth_api_service.dart “Auth”, and also perhaps create a /etc/nginx/sites-available/bingo-event with the contents:  

location /api/ { 

    proxy_pass http://localhost:5000; # Keep it simple - no path after 5000 

    proxy_http_version 1.1; 

    proxy_set_header Upgrade $http_upgrade; 

    proxy_set_header Connection keep-alive; 

    proxy_set_header Host $host; 

    proxy_cache_bypass $http_upgrade; 

    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; 

    proxy_set_header X-Forwarded-Proto $scheme; 

} 

 

Once you restart Nginx (sudo systemctl restart nginx), the 404 should disappear and you should be able to log in! 

 

Day36 We fixed the “auth” and a couple of things with the relative paths so that you can login. Fixed scrolling of the bingo boards on the admin side. Made a user manual, partially done.  

The commands to publish/build the sections are: 

Api_folder: dotnet publish -c Release -r linux-x64 --self-contained false -o publish 

Admin: Flutter build web --base-href /bingo/admin/ 

Guest: Flutter build web --base-href /bingo/guest/ 

-r linux-x64: This explicitly targets the x86_64 architecture for Linux. 

--self-contained false: This assumes you have the .NET 9 Runtime already installed on your Linux server. (If you don't have it installed, change this to true to include the runtime in the folder). 

 

This runs the api through the systemd service file created on linux: 

ExecStart=/usr/bin/dotnet /var/www/html/bingo/API_folder/API_folder.dll 

[Service] 

WorkingDirectory=/var/www/bingo-api 

ExecStart=/usr/bin/dotnet /var/www/bingo-api/API_folder.dll 

Restart=always 

# Restart service after 10 seconds if the dotnet service crashes: 

RestartSec=10 

KillSignal=SIGINT 

SyslogIdentifier=bingo-api 

#User=www-data 

Environment=ASPNETCORE_ENVIRONMENT=Production 

Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false 

 

Runs the file with executive permissions: 

Chmod a+x API_folder ./API_folder 

 

Day37 Not a very successful day. After having to download nginx, and making the bingo-event.conf file, and sudo kill port 80, all the other websites stopped working. AI said it might be that other files might share the same server name “_”. Other opinions were that there might be firewall issues. 

 

Day38 We were asked to make a temporary only minigame version for the 8th graders to test out. Arto removed nginx due to the issues it was causing. Now we need to figure out a way for the project to run purely with httpd. 

 

Day39 We modified the user manual a bit more. We applied httpd to the project. Tried to modify so that when creating a new event, it automatically reads the accounts name, but it still needs a little bit of work for this to work. 

 

Day40 Now when creating new event packages, the name of the creator reads from the username of the account. Only the main admin can fully modify everything; other accounts can only modify their own files. Made a small change so that it could read school servers ip-adress when needed. 
 
locally for  
api folder run dotnet run  
admin flutter run -d web-server --web-port 8082 --web-hostname 0.0.0.0  
guest flutter run -d web-server --web-port 8081 --web-hostname 0.0.0.0 

 

Day41 Changed a little bit of the pathing for the api to respond on bingo/api/auth/login for example. Had to make a proxypass for the project so the admin knows where to look for the api. In httpd.conf added these: 

  
Enable proxy modules 

LoadModule proxy_module modules/mod_proxy.so  
LoadModule proxy_http_module modules/mod_proxy_http.so 

Proxy rules for the bingo API 

ProxyPass /bingo/api http://localhost:5000/api  
ProxyPassReverse /bingo/api http://localhost:5000/api 

Add the LoadModule lines near the top with other LoadModule statements. 

Add the ProxyPass lines in the <VirtualHost> section or after your DocumentRoot directive. 

Now all the parts, admin, guest, and api work. Arto tested on phone as well; it works. 

 