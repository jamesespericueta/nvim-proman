# nvim-proman
<sub>Currently under active development (๑•́ -•̀)</sub>

Neovim project manager plugin made to solve all my related inconveniences

(I know theres project managers out there but they don't do everything I want them to do and the good ones have been abandoned) - https://xkcd.com/927/

Have you ever way too many projects and requently switch between them all the time???

Tired of making aliases or scripts to change to your frequent project directories?

Want to navigate ur projects at the speed a somewhat fit middle aged dude with a mustache?

Well oh boy do I have the potential project for you. (I hope I follow thru w this project)
- If u stumble upon this searching for a project manager with a whole lot of functionality, feel free to request features that aren't listed in the TODO!
- A lot of this description isn't supposed to make a lot of sense, just a way for me to track what i need to do and having fun while doing it. ദ്ദി(ᵔᗜᵔ)

# Overall Goal
Have a centralized means of managing projects. 

I find myself switching between projects quite often and sometimes visiting old projects.

A lot of times I just forget the directories I've put the projects in and just clone the repo to another directory(I know i should be more organized but that would be way too simple of a solution)

I want a project manager within neovim where if I am not in a project already added to the list, the plugin shows me UI that displays my added projects and allows me to immediately change to their directory OR allow me to add the current directory to the projects and continue.

Obviously this would annoy me so I'm going through different configuration possibilities and might just implement all of them so its up to the user how the project manager handles its init (user is always right. I dont make the rules.)
## Added Features
* [x] Project addition with custom name
* [x] Project removal(automatic detection when in existing directory)
* [x] Pop up menus
* [x] Adding directory without needing to "cd" with subdirectory finder
* [x] I've added other features but forgot what they were. I really should be more organized...

## TODO
* [ ] Use plenary for anything Path related
* [ ] Implement plenary confirmation prompts
* [ ] Add github directory detection
* [ ] Whole lot of configuration(user knows best)
* [ ] Add tests!!!! -_-
* [ ] Properly consolidate functions and think about new project structure\
&emsp; - not just dump everything in utils...
* [ ] Figure out how to start setting up with different plugin managers
* [ ] Create an API - properly document it...d( - . - )b
* [ ] Optimize after core functionality had been implemented and properly tested\
* [ ] And um support platforms other than macOS (works on my machine ;D)
* [ ] some other stuff I'm forgetting rn

ᕙ(  •̀ ᗜ •́  )ᕗ
