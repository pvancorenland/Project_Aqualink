# Aqualink
Aqualink Interface for Processing


## Processing on RPi
### Install Processing
Run the following on the Pi:

	curl https://processing.org/download/install-arm.sh | sudo sh


###Install the controlP5 library:
start Processing from the command line:
	
	processing
	
Go to Sketch --> Import Library --> Add Library

Search for controlP5 and install it (I used version 2.2.5)


## Install Aqualink sketch from github

	mkdir Processing
	cd Processing
	git clone https://github.com/pvancorenland/Project_Aqualink.git
	cd Project_Aqualink/
	mkdir LogFiles

## Update skecth to github
Use Atlassian Sourcetree

Use Commit to remote branch and add tag, push to master

## Update sketch from Github to RPi
