#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RAND_NUM=$(( RANDOM % 1000 + 1 ))
echo $RAND_NUM

echo -e "\nEnter your username:"

read USERNAME
GET_USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME'")

if [[ -z $GET_USER_INFO ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  ADD_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"

GUESSING_GAME() {
  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    GUESSING_GAME $(($1+1))
  elif [[ $GUESS -lt $RAND_NUM ]]
  then
    echo -e "\nIt's higher than that, guess again:"
    GUESSING_GAME $(($1+1))
  elif [[ $GUESS -gt $RAND_NUM ]]
  then
    echo -e "\nIt's lower than that, guess again:"
    GUESSING_GAME $(($1+1))
  else
    echo -e "\nYou guessed it in $1 tries. The secret number was $RAND_NUM. Nice job!"

    GAMES_PLAYED=$(($GAMES_PLAYED+1))

    GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played = '$GAMES_PLAYED' WHERE username = '$USERNAME' ")

    if [[ $1 -lt $(($BEST_GAME)) ]] || [[ $(($BEST_GAME)) == 0 ]]
    then
      BEST_SCORE_RESULT=$($PSQL "UPDATE users SET best_game = '$1' WHERE username = '$USERNAME' ")
    fi
  fi
}

GUESSING_GAME 1
