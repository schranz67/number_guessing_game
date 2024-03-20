#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~~~ The Fabulous Number Guessing Game ~~~~~~~\n"

# LOGIN FUNCTION
LOGIN() {
  # get user name
  echo "Enter your username:"
  read USERNAME
  # get user id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME';")
  # if not found
  if [[ -z $USER_ID ]]
  then
    # insert new user name
    INSERT_USER=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME');")
    # get user id
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME';")
  fi
  # get number of games played
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id='$USER_ID';")
  # if games played
  if [[ $GAMES_PLAYED > 0 ]]
  then
    # get number of guesses of the best game for welcome
    BEST_GAME=$($PSQL "SELECT MAX(number_of_guesses) FROM games WHERE user_id=$USER_ID;")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    # get date for indication in french format
    BEST_GAME_DATE=$($PSQL "SELECT game_date FROM games WHERE user_id=$USER_ID AND number_of_guesses=$BEST_GAME;")
    echo $BEST_GAME_DATE | if IFS="-" read Y M D
    then
      echo "That was the $D/$M/$Y!"
    fi
  # Other message if first game
  else 
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  fi
}

# GAME FUNCTION
GAME() {
  # get secret number
  SECRET_NUMBER=$((RANDOM % 1000 + 1))
  # beginning of the game
  echo -e "\nGuess the secret number between 1 and 1000:"
  NUMBER_OF_GUESSES=0
  USER_GUESS=-1
  # Loop while secret number is not found
  while [[ $USER_GUESS != $SECRET_NUMBER ]]
  do
    # test the guess number after the first guess
    if [[ $NUMBER_OF_GUESSES > 0 ]]
    then
      # verification if number 
      if [[ $USER_GUESS =~ ^[0-9]+$ ]]
      then
        # indication if the secret number is higher than the guess
        if [[ $SECRET_NUMBER > $USER_GUESS ]]
        then
          echo "It's higher than that, guess again:"
        fi
        # indication if the secret number is lower than the guess
        if [[ $SECRET_NUMBER < $USER_GUESS ]]
        then
          echo "It's lower than that, guess again:"
        fi
      # indication if the guess is not a number
      else
          echo "That is not an integer, guess again:"
      fi
    fi
    # get new guess
    read USER_GUESS
    ((NUMBER_OF_GUESSES++))
  done
  # indication of the success
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  # insert the success in the database
  INSERT_N_O_G=$($PSQL "INSERT INTO games(game_date, number_of_guesses, user_id) VALUES(NOW(), $NUMBER_OF_GUESSES, $USER_ID);")
  # ask new game (in comments for the tests)
  #echo -e "\nNew game? Y:Yes/N:No"
  #read new_game
  #if [[ $new_game == "Y" ]]
  #then
  #  GAME
  #fi
}

LOGIN 
GAME