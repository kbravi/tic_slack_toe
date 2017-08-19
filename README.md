# Tic Slack Toe

A Tic Tac Toe game played in Slack. This app is hosted on Heroku.

Add to any Slack team by visiting [https://kbravi-tic-slack-toe.herokuapp.com](https://kbravi-tic-slack-toe.herokuapp.com)

![Sample Board 1](http://i.imgur.com/4MSH7VQ.png)
![Sample Board 2](http://i.imgur.com/HEX8DCJ.png)

## Features
* An interactive game board with action buttons.
* Play a game with any member of your slack team. The game board is public to the channel.
* One game per channel.
* Leaderboard (within channel and across the team)
* Supports Board Size customization (App level) - are you ready to play a 9x9 Tic Tac Toe?. Currently, the board size is 3.

## Slack Commands
To start a new game (game board is public), use
```
/ttt new @somebody
```
To view the active game board in a channel, use
```
/ttt current
```
To view the leaders in the current channel, use
```
/ttt leaderboard here
```
To view leaders across the team, use
```
/ttt leaderboard
```

## Technical details

This is a web API application that connects with Slack's API for the Tic Slack Toe App. The application requires `team:read` and `commands` permissions from users on Slack.

### Application Stack
* Ruby on Rails API application (Rails 5.1 on Ruby 2.4.1)
* Postgres database

* OmniAuth gem to provide OAuth support for adding slack to teams
* Rspec-Rails gem for the testing suite

* One additional [public HTML page](https://kbravi-tic-slack-toe.herokuapp.com) that lets users add the app to their Slack teams.

* Heroku to host the application at kbravi-tic-slack-toe.herokuapp.com

### Code structure

#### Entry Points
There are 4 entry points into the application
1. `/auth/slack/callback` is the OAuth redirect URL when a user adds the app to their Slack team
2. `/auth/slack/failure` is the OAuth failure redirect URL when something goes wrong when a user adds the app to their Slack team

3. `/slacker/commands/receive` is the commands endpoint that Slack's API connects with. This endpoint receives requests when the user uses the slack commands such as `/ttt` in their Slack.
4. `/slacker/actions/receive` is the interactive messages endpoint that Slack's API connects with. This endpoint receives requests when the user interacts with the message (e.g. clicking an action button or choosing from a menu) in their Slack.

#### Models
There are three relevant models
1. `Team` model stores relevant information about the team. This record is created (and updated) when a user connects their team with the app.
2. `Game` model stores instances of every Tic Tac Toe game. A team can have multiple games. The Game model also stores the player identifiers and channel identifier.
3. `Move` model stores every move that the user makes on the game board. A game can have multiple moves. Each move stores information about the player and (x,y) position in the board.

#### Controllers
There are three controllers
1. `teams_controller.rb` deals with the OAuth flow and creates (or updated) the team records in our database.
2. `slacker/commands_controller.rb` receives requests from slack when a user triggers one of the supported Slack commands
3. `slacker/actions_controller.rb` receives requests from slack when a user interacts with one of the messages with action buttons or menus.

#### Logic
1. Team T adds the Tic Slack Toe app to their Slack team.
2. The user @jane types `/ttt new @john` to start a game with @john in a channel C.
3. If there isn't any active game in the channel C, then a new game is created.
4. Player1 and Player2 are assigned randomly between the players, and Player1 always plays first.
5. The channel C is publicly provided with a game board with interactive action buttons presented as tiles.
6. The game board also displays who plays next.
7. The player, in their turn, can click on an unclaimed tile to complete their turn.
8. The game board is evaluated after every turn to see if the game is complete, or has been won.
9. The game continues with players playing alternately until one of them wins, or they draw.
10. When the game ends, the game board in the channel declares the result.

At any point, anybody in the channel can
1. Type `/ttt current` to view the currently active game board privately.
2. Type '/ttt leaderboard here' to view the leaders in the channel.
3. Type '/ttt leaderboard' to view the leaders across their Slack team.
4. Type '/ttt help' to view the list of available commands.


### How to run locally
With `Ruby 2.4.1`, `Rails 5.1` and `Postgres` set up locally, just run
```
bundle install
bin/setup
```
#### Slack credentials
The App requires three credentials from the Slack App and these are expected to be stored as Environmental variables.

These are NOT included in this repository for obvious privacy concerns. The application supports `figaro` gem to manage environment variables. So, just add the following to the `config/application.yml` file

You can find these credentials in the App Credentials section of the Slack App page.

```
# in config/applcation.yml
SLACK_CLIENT_ID: <SLACK_CLIENT_ID>
SLACK_CLIENT_SECRET: <SLACK_CLIENT_SECRET>
SLACK_VERIFICATION_TOKEN: <SLACK_VERIFICATION_TOKEN>
```

#### Tests
There are over a hundred unit tests that test most part of the application. To run tests locally, just run
```
bundle exec rspec
```

## Easy Upgrades
* Game level board size customizations: Currently, the app supports App level customization and it is defined in the codebase. But, it is very easy to move to a game level board_size customization

* Multiple players: Although traditional TicTacToe is played between two players, it is easy to scale this to multiple players with some changes.

